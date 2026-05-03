#!/usr/bin/env python3
"""Download, link, and manage colorscheme sources for terminal and editor applications.

This script centralizes colorscheme management so you can pull themes from Git
repositories or local directories, filter them into collections, and expose them
to apps (Alacritty, Foot, Kitty, Neovim, Tmux, etc.) under a unified layout.
Each app sees its themes at $XDG_CONFIG_HOME/colorschemes/<app>/<colorscheme>.

Configuration
-------------
Config is read from $XDG_CONFIG_HOME/colorschemes/config.toml by default, or
from a path given with -c. If the default file does not exist, the script
exits with an error pointing to --help for a sample config.

Filesystem layout
----------------
Two directories are used:

  $XDG_CONFIG_HOME/colorschemes/   (default: ~/.config/colorschemes)
    Application-facing symlinks live here. Each subdirectory is an app name
    (e.g. alacritty, kitty, nvim), containing symlinks to colorscheme files.

  $XDG_DATA_HOME/colorschemes/     (default: ~/.local/share/colorschemes)
    Sources are cloned/fetched here. Collections and symlink targets live under
    sources/ and collections/.

Sources / Collections
---------------------
A *Source* is where themes come from—either a Git repository or a local directory.
Configure it with:

  - name: Identifier for use in collections (must be a valid directory name)
  - type: 'git' or 'dir'
  - source: Type-specific details:
      For type='git': url (required), ref (branch/tag, optional)
      For type='dir': path (required)

A *Collection* is a filtered view of a source. It selects which paths and files
to include. Parameters:

  - source: Name of the source
  - filter: Optional filter with:
      paths: Paths within the source to scan (default: '.')
      pattern: Glob to include (default: '*')
      exclude: Glob(s) to exclude (matched against basename only)
      filetype: 'd' (directories), 'f' (files), or both (default: 'd')
      include_hidden: Include hidden entries (default: false)

Symlink flow
-----------
  1. Sources are fetched into $XDG_DATA_HOME/colorschemes/sources/<name>/
  2. Collections link into those sources under collections/<collection>/<app>/
  3. link_config creates $XDG_CONFIG_HOME/colorschemes/<app>/<colorscheme>
     symlinks that point into the collection layout. Themes must be files;
     directory-shaped themes are linked into collections (step 2) but not
     into the application-facing layout.

Example config
-------------

    [sources]
    directory = 'sources'

    [collections]
    directory = 'collections'

    [[sources.spec]]
    name = 'iTerm2-Color-Schemes'
    type = 'git'
    source = {
      url = 'https://github.com/mbadolato/iTerm2-Color-Schemes.git',
      ref = 'master'
    }

    [[collections.spec]]
    name = 'iTerm2-Color-Schemes'
    source = 'iTerm2-Color-Schemes'
    filter = {
      exclude = ['gh-pages', 'screenshots', 'tools']
    }

Commands
--------
  sync      Fetch sources (clone or pull) and link collections and config.
            Options: --no-update (skip git pull), --dry-run, --clobber

  link      Create collections and link config only (no fetch).
            Options: --dry-run, --clobber

  list      Print configured sources and collections.

Existing regular files at link sites are preserved by default; pass --clobber
to replace them. Existing directories are always preserved.
"""

import os
import subprocess
import sys
import tomllib
from abc import ABC, abstractmethod
from argparse import ArgumentParser, Namespace
from collections.abc import Iterable, Iterator
from dataclasses import dataclass, field
from fnmatch import fnmatch
from pathlib import Path
from typing import Any, Callable, ClassVar, Final, Literal, cast, override

XDG_CONFIG_HOME: Final[Path] = Path(
    os.getenv("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
)
XDG_DATA_HOME: Final[Path] = Path(
    os.getenv("XDG_DATA_HOME") or os.path.expanduser("~/.local/share")
)
COLORS_CONFIG_HOME: Final[Path] = XDG_CONFIG_HOME / "colorschemes"
COLORS_DATA_HOME: Final[Path] = XDG_DATA_HOME / "colorschemes"


def as_list[T](x: T | Iterable[T]) -> list[T]:
    if isinstance(x, str):
        return cast(list[T], [x])
    if isinstance(x, Iterable):
        return list(cast(Iterable[T], x))
    return [x]


@dataclass(kw_only=True)
class Filter:
    type _Filetype = Literal["d", "f"]

    paths: str | list[str] = "."
    pattern: str | list[str] = "*"
    exclude: str | list[str] = field(default_factory=list)
    filetype: _Filetype | list[_Filetype] = "d"
    include_hidden: bool = False

    _filetype_test: ClassVar[dict[str, Callable[[Path], bool]]] = {
        "d": lambda p: p.is_dir(),
        "f": lambda p: p.is_file(),
    }

    def match(self, root: Path | str = ".") -> Iterator[Path]:
        """Yield matched paths, expressed relative to `root`."""
        root = Path(root)
        patterns = as_list(self.pattern)
        excludes = as_list(self.exclude)
        filetypes = as_list(self.filetype)
        paths = as_list(self.paths)

        for path in paths:
            base = root / path
            for pattern in patterns:
                for entry in base.glob(pattern, case_sensitive=False):
                    if not self.include_hidden and entry.name.startswith("."):
                        continue
                    if any(fnmatch(entry.name, ex) for ex in excludes):
                        continue
                    if any(self._filetype_test[ft](entry) for ft in filetypes):
                        yield entry.relative_to(root)


def _replace_with_symlink(
    link_path: Path,
    target: Path | str,
    *,
    target_is_directory: bool = False,
    clobber: bool = False,
    dry_run: bool = False,
) -> bool:
    """Symlink link_path -> target, replacing any existing symlink (live or
    broken). Real files are skipped unless clobber=True; real directories are
    always skipped. Returns True if a link was (or would be) created.
    """
    blocking: str | None = None
    if link_path.exists() and not link_path.is_symlink():
        if link_path.is_dir():
            blocking = "existing directory"
        elif not clobber:
            blocking = "existing file; pass --clobber to overwrite"

    if blocking:
        if dry_run:
            print(f"  would skip {link_path} ({blocking})", file=sys.stderr)
        else:
            print(
                f"Warning: cannot replace {link_path} ({blocking}); skipping",
                file=sys.stderr,
            )
        return False

    if dry_run:
        action = (
            "would clobber"
            if link_path.exists() and not link_path.is_symlink()
            else "would link"
        )
        print(f"  {action} {link_path} -> {target}")
        return True
    link_path.parent.mkdir(parents=True, exist_ok=True)
    link_path.unlink(missing_ok=True)
    link_path.symlink_to(target, target_is_directory=target_is_directory)
    return True


def _git(
    cmd: list[str],
    *,
    cwd: Path | None = None,
    check: bool = True,
    quiet: bool = False,
) -> subprocess.CompletedProcess[str]:
    """Run git, echoing the command and its output unless quiet=True."""
    if not quiet:
        print(">", *cmd)
    proc = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if not quiet and proc.stdout:
        print(proc.stdout, end="")
    if not quiet and proc.stderr:
        print(proc.stderr, end="", file=sys.stderr)
    if check and proc.returncode != 0:
        raise subprocess.CalledProcessError(
            proc.returncode, cmd, proc.stdout, proc.stderr
        )
    return proc


class SourceBackend(ABC):
    @abstractmethod
    def retrieve(
        self,
        dest: Path | str,
        *,
        update: bool = True,
        dry_run: bool = False,
        clobber: bool = False,
    ) -> None: ...


@dataclass(kw_only=True)
class DirSource(SourceBackend):
    path: Path | str

    @override
    def retrieve(
        self,
        dest: Path | str,
        *,
        update: bool = True,
        dry_run: bool = False,
        clobber: bool = False,
    ) -> None:
        path = Path(os.path.expandvars(self.path)).expanduser().resolve()
        dest = Path(os.path.expandvars(dest)).expanduser()
        _replace_with_symlink(
            dest,
            path,
            target_is_directory=path.is_dir(),
            clobber=clobber,
            dry_run=dry_run,
        )


@dataclass(kw_only=True)
class GitSource(SourceBackend):
    url: str
    ref: str | None = None

    @override
    def retrieve(
        self,
        dest: Path | str,
        *,
        update: bool = True,
        dry_run: bool = False,
        clobber: bool = False,  # unused: git owns its workspace
    ) -> None:
        dest = Path(os.path.expandvars(dest)).expanduser().resolve()
        if not dest.is_dir():
            if dry_run:
                print(f"  would clone {self.url} -> {dest}")
                return
            dest.parent.mkdir(parents=True, exist_ok=True)
            _git(
                [
                    "git",
                    "clone",
                    "--depth",
                    "1",
                    "--single-branch",
                    "--recurse-submodules",
                    "--shallow-submodules",
                    *(("--branch", self.ref) if self.ref else ()),
                    "--",
                    self.url,
                    str(dest),
                ]
            )
            return
        if not (dest / ".git").exists():
            raise FileExistsError(
                f"{dest} exists but is not a git checkout; "
                "remove or move it aside before retrying"
            )
        if not update:
            print(f"  {'would skip' if dry_run else 'skipping'} {self.url} -> {dest}")
            return
        if dry_run:
            print(f"  would update {self.url} -> {dest}")
            return
        self._update(dest)

    def _update(self, dest: Path) -> None:
        """Fetch the latest ref into `dest`, stashing local edits around the
        fetch/checkout. If the post-fetch `git stash pop` fails (typically a
        merge conflict against the new HEAD), the stash entry is left in
        place and the caller must resolve it manually.
        """
        status = _git(["git", "status", "--porcelain", "-uall"], cwd=dest, quiet=True)
        stashed = bool(status.stdout.strip())
        if stashed:
            _git(["git", "stash", "push", "--include-untracked"], cwd=dest)

        try:
            fetch = [
                "git",
                "fetch",
                "--depth",
                "1",
                "--recurse-submodules=on-demand",
                "origin",
                *(("--", self.ref) if self.ref else ()),
            ]
            _git(fetch, cwd=dest)
            _git(["git", "checkout", "-f", "--detach", "FETCH_HEAD"], cwd=dest)
        finally:
            if stashed:
                pop = _git(["git", "stash", "pop"], cwd=dest, check=False)
                if pop.returncode != 0:
                    print(
                        f"Local changes preserved as a stash entry in {dest}; "
                        f"resolve manually with: git -C {dest} stash pop",
                        file=sys.stderr,
                    )
                    raise subprocess.CalledProcessError(
                        pop.returncode,
                        ["git", "stash", "pop"],
                        pop.stdout,
                        pop.stderr,
                    )


SOURCE_TYPES: dict[str, type[SourceBackend]] = {
    "dir": DirSource,
    "git": GitSource,
}

_SOURCE_TYPE_LABELS: dict[type[SourceBackend], str] = {
    DirSource: "dir",
    GitSource: "git",
}


@dataclass(kw_only=True)
class Source:
    name: str
    source: SourceBackend


@dataclass(kw_only=True)
class Collection:
    name: str
    source: str
    filter: Filter = field(default_factory=Filter)

    def filter_names(self, sources_root: Path) -> Iterator[Path]:
        source_path = sources_root / self.source
        if not source_path.is_dir():
            raise FileNotFoundError(
                " ".join(
                    (
                        f"Source '{self.source}' not found at {source_path};",
                        f"run 'sync' first or check collection '{self.name}' config",
                    )
                )
            )
        for name in self.filter.match(source_path):
            yield source_path / name

    def link_to_source(
        self,
        collections_root: Path,
        sources_root: Path,
        *,
        dry_run: bool = False,
        clobber: bool = False,
    ) -> None:
        source_path = sources_root / self.source
        if dry_run and not source_path.is_dir():
            print(
                f"  would link collection '{self.name}' (source '{self.source}' not yet fetched)"
            )
            return
        collection_path = collections_root / self.name
        target_paths = list(self.filter_names(sources_root))
        current_names = {p.name for p in target_paths}
        if not dry_run:
            collection_path.mkdir(parents=True, exist_ok=True)
        n_linked = 0
        n_stale = 0
        for target_path in target_paths:
            link_path = collection_path / target_path.name
            # Relative from parent of resolved link to resolved target
            link_target = target_path.resolve().relative_to(
                link_path.parent.resolve(), walk_up=True
            )
            if _replace_with_symlink(
                link_path,
                link_target,
                target_is_directory=target_path.is_dir(),
                clobber=clobber,
                dry_run=dry_run,
            ):
                n_linked += 1
        if collection_path.exists():
            for entry in collection_path.iterdir():
                if entry.is_symlink() and entry.name not in current_names:
                    if dry_run:
                        print(f"  would remove stale {entry}")
                    else:
                        entry.unlink(missing_ok=True)
                    n_stale += 1
        parts = [f"{n_linked} linked"]
        if n_stale:
            parts.append(f"{n_stale} stale removed")
        prefix = "[dry-run] " if dry_run else ""
        print(f"  {prefix}{self.name}: {', '.join(parts)}")


def expand_data_path(p: Path | str, base: Path = COLORS_DATA_HOME) -> Path:
    """Resolve path; if relative, resolve against base ($XDG_DATA_HOME/colorschemes)."""
    expanded = Path(os.path.expandvars(str(p))).expanduser()
    if expanded.is_absolute():
        return expanded.resolve()
    return (base / expanded).resolve()


def expand_config_path(s: str) -> Path:
    return Path(os.path.expandvars(s)).expanduser()


@dataclass(kw_only=True)
class Sources:
    directory: Path
    spec: list[Source]

    def retrieve_all(
        self, *, update: bool = True, dry_run: bool = False, clobber: bool = False
    ) -> None:
        if not dry_run:
            self.directory.mkdir(parents=True, exist_ok=True)
        for source in self.spec:
            source.source.retrieve(
                self.directory / source.name,
                update=update,
                dry_run=dry_run,
                clobber=clobber,
            )


@dataclass(kw_only=True)
class Collections:
    directory: Path
    spec: list[Collection]

    def link_all(
        self, sources_root: Path, *, dry_run: bool = False, clobber: bool = False
    ) -> None:
        for collection in self.spec:
            collection.link_to_source(
                self.directory, sources_root, dry_run=dry_run, clobber=clobber
            )


def link_config(
    collections_root: Path,
    *,
    config_root: Path = COLORS_CONFIG_HOME,
    dry_run: bool = False,
    clobber: bool = False,
) -> None:
    """Create <config_root>/<application>/<colorscheme> symlinks.

    Link each colorscheme file from its collection location, remove stale
    per-colorscheme symlinks, and remove per-app directories whose app no
    longer appears in any collection (only if the directory contains
    nothing but symlinks; otherwise warn and leave it alone).
    """
    if not collections_root.is_dir():
        if dry_run:
            print("[dry-run] would link config (collections not yet created)")
        return
    app_to_dirs: dict[str, list[Path]] = {}
    for coll_dir in sorted(collections_root.iterdir()):
        if not coll_dir.is_dir():
            continue
        for entry in coll_dir.iterdir():
            if entry.is_dir() or entry.is_symlink():
                app_to_dirs.setdefault(entry.name, []).append(entry)
    n_apps = 0
    n_linked = 0
    n_stale = 0
    n_stale_apps = 0
    for app in sorted(app_to_dirs):
        config_app_dir = config_root / app
        linked_files: set[str] = set()
        for app_dir in app_to_dirs[app]:
            if not app_dir.is_dir() and not app_dir.is_symlink():
                continue
            try:
                entries = list(app_dir.iterdir())
            except OSError:
                continue
            for entry in entries:
                if not entry.is_file():
                    continue
                linked_files.add(entry.name)
                link_path = config_app_dir / entry.name
                # Relative from parent of resolved link to resolved target
                rel = entry.resolve().relative_to(
                    link_path.parent.resolve(), walk_up=True
                )
                if _replace_with_symlink(
                    link_path, rel, clobber=clobber, dry_run=dry_run
                ):
                    n_linked += 1
        if config_app_dir.exists():
            for entry in config_app_dir.iterdir():
                if entry.is_symlink() and entry.name not in linked_files:
                    if dry_run:
                        print(f"  would remove stale {entry}")
                    else:
                        entry.unlink(missing_ok=True)
                    n_stale += 1
        elif dry_run and linked_files:
            print(f"  would create {config_app_dir}/ with {len(linked_files)} link(s)")
        if linked_files:
            n_apps += 1

    # Skip dot-prefixed names (e.g. .git, .github) -- never valid app names,
    # and may be VCS metadata for the parent dir.
    if config_root.is_dir():
        for app_dir in sorted(config_root.iterdir()):
            if (
                not app_dir.is_dir()
                or app_dir.is_symlink()
                or app_dir.name.startswith(".")
                or app_dir.name in app_to_dirs
            ):
                continue
            try:
                contents = list(app_dir.iterdir())
            except OSError:
                continue
            if not all(p.is_symlink() for p in contents):
                print(
                    f"Warning: stale app dir {app_dir} has non-symlink "
                    "entries; leaving in place",
                    file=sys.stderr,
                )
                continue
            if dry_run:
                print(f"  would remove stale app dir {app_dir}")
            else:
                for p in contents:
                    p.unlink(missing_ok=True)
                app_dir.rmdir()
            n_stale_apps += 1

    parts = [f"{n_apps} apps", f"{n_linked} links"]
    if n_stale:
        parts.append(f"{n_stale} stale removed")
    if n_stale_apps:
        parts.append(f"{n_stale_apps} stale app dirs removed")
    prefix = "[dry-run] " if dry_run else ""
    print(f"  {prefix}{', '.join(parts)}")


@dataclass(kw_only=True)
class Config:
    sources: Sources
    collections: Collections


class Command(ABC):
    """Base class for subcommands."""

    config: Config
    args: Namespace

    def __init__(self, config: Config, args: Namespace) -> None:
        self.config = config
        self.args = args

    @abstractmethod
    def __call__(self) -> None: ...


class SyncCommand(Command):
    @override
    def __call__(self) -> None:
        update = getattr(self.args, "update", True)
        dry_run = getattr(self.args, "dry_run", False)
        clobber = getattr(self.args, "clobber", False)
        prefix = "[dry-run] would fetch" if dry_run else "Fetching"
        print(f"{prefix} sources:")
        self.config.sources.retrieve_all(
            update=update, dry_run=dry_run, clobber=clobber
        )
        prefix = "[dry-run] would create" if dry_run else "Creating"
        print(f"{prefix} collections:")
        self.config.collections.link_all(
            sources_root=self.config.sources.directory,
            dry_run=dry_run,
            clobber=clobber,
        )
        prefix = "[dry-run] would link" if dry_run else "Linking"
        print(f"{prefix} config:")
        link_config(self.config.collections.directory, dry_run=dry_run, clobber=clobber)


class LinkCommand(Command):
    @override
    def __call__(self) -> None:
        dry_run = getattr(self.args, "dry_run", False)
        clobber = getattr(self.args, "clobber", False)
        prefix = "[dry-run] would create" if dry_run else "Creating"
        print(f"{prefix} collections:")
        self.config.collections.link_all(
            sources_root=self.config.sources.directory,
            dry_run=dry_run,
            clobber=clobber,
        )
        prefix = "[dry-run] would link" if dry_run else "Linking"
        print(f"{prefix} config:")
        link_config(self.config.collections.directory, dry_run=dry_run, clobber=clobber)


class ListCommand(Command):
    @override
    def __call__(self) -> None:
        print("Sources:")
        for s in self.config.sources.spec:
            print(f"  {s.name} ({_SOURCE_TYPE_LABELS[type(s.source)]})")
        print("\nCollections:")
        for c in self.config.collections.spec:
            print(f"  {c.name} <- {c.source}")


def _parse_source(data: dict[str, Any]) -> Source:
    source_name = data["name"]
    source_type = data["type"]
    if source_type not in SOURCE_TYPES:
        raise ValueError(
            " ".join(
                (
                    f"Unknown type '{source_type}' for source '{source_name}';",
                    f"expected one of {list(SOURCE_TYPES)}",
                )
            )
        )
    source_data = data["source"]
    source = SOURCE_TYPES[source_type](**source_data)
    return Source(name=source_name, source=source)


def _parse_collection(data: dict[str, Any]) -> Collection:
    name = data["name"]
    source = data["source"]
    filter_data = data.get("filter")
    filter_obj = Filter(**filter_data) if filter_data else Filter()
    return Collection(name=name, source=source, filter=filter_obj)


def _parse_sources(data: dict[str, Any]) -> Sources:
    directory = expand_data_path(data.get("directory", "sources"))
    spec = [_parse_source(s) for s in data.get("spec", [])]
    return Sources(directory=directory, spec=spec)


def _parse_collections(data: dict[str, Any]) -> Collections:
    directory = expand_data_path(data.get("directory", "collections"))
    spec = [_parse_collection(c) for c in data.get("spec", [])]
    return Collections(directory=directory, spec=spec)


def _load_config(config_path: Path) -> Config:
    with open(config_path, "rb") as f:
        data: dict[str, Any] = tomllib.load(f)
    return Config(
        sources=_parse_sources(data.get("sources", {})),
        collections=_parse_collections(data.get("collections", {})),
    )


def main() -> int:
    parser = ArgumentParser(
        description=(__doc__ or "").strip().partition("\n")[0],
    )
    parser.add_argument(
        "-c",
        "--config",
        type=expand_config_path,
        default=COLORS_CONFIG_HOME / "config.toml",
        help=f"Config file (default: {COLORS_CONFIG_HOME / 'config.toml'})",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    sync_parser = subparsers.add_parser(
        "sync", help="Fetch sources and link collections"
    )
    sync_parser.add_argument(
        "--no-update",
        dest="update",
        action="store_false",
        help="Skip updating existing git sources",
    )
    sync_parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without making changes",
    )
    sync_parser.add_argument(
        "--clobber",
        action="store_true",
        help="Overwrite existing regular files at link sites (directories are still preserved)",
    )
    sync_parser.set_defaults(cmd_cls=SyncCommand)

    link_parser = subparsers.add_parser("link", help="Link collections only (no fetch)")
    link_parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without making changes",
    )
    link_parser.add_argument(
        "--clobber",
        action="store_true",
        help="Overwrite existing regular files at link sites (directories are still preserved)",
    )
    link_parser.set_defaults(cmd_cls=LinkCommand)

    list_parser = subparsers.add_parser(
        "list", help="List configured sources and collections"
    )
    list_parser.set_defaults(cmd_cls=ListCommand)

    args = parser.parse_args()

    try:
        config = _load_config(args.config)
        cmd: Command = args.cmd_cls(config=config, args=args)
        cmd()
        return 0
    except (FileNotFoundError, OSError, PermissionError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        if (
            isinstance(exc, FileNotFoundError)
            and args.config == COLORS_CONFIG_HOME / "config.toml"
        ):
            print(
                f"Hint: see --help for an example config to place at {args.config}",
                file=sys.stderr,
            )
        return 1
    except (TypeError, ValueError, KeyError) as exc:
        print(f"Config error: {exc}", file=sys.stderr)
        return 1
    except subprocess.CalledProcessError as exc:
        print(f"Git failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
