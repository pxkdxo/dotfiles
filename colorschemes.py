#!/usr/bin/env python3
"""Download, link, and manage colorscheme sources for terminal and editor applications.

This script centralizes colorscheme management so you can pull themes from Git
repositories or local directories, filter them into collections, and expose them
to apps (Alacritty, Foot, Kitty, Neovim, Tmux, etc.) under a unified layout.
Each app sees its themes at $XDG_CONFIG_HOME/colorschemes/<app>/<colorscheme>.

Configuration
-------------
Config is read from $XDG_CONFIG_HOME/colorschemes/config.toml by default, or
from a path given with -c. If the default file does not exist, it is created
with sample content.

Filesystem layout
----------------
Two directories are used:

  $XDG_CONFIG_HOME/colorschemes/   (default: ~/.config/colorschemes)
    Application-facing symlinks live here. Each subdirectory is an app name
    (e.g. alacritty, kitty, nvim), containing symlinks to colorscheme files.

  $XDG_DATA_HOME/colorschemes/     (default: ~/.local/share/colorschemes)
    Sources are cloned/fetched here. Collections and symlink targets live under
    sources/ and collections/.

Concept: Sources and Collections
--------------------------------
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
      exclude: Glob(s) to exclude
      filetype: 'd' (directories), 'f' (files), or both (default: 'd')
      include_hidden: Include hidden entries (default: false)

Symlink flow
-----------
  1. Sources are fetched into $XDG_DATA_HOME/colorschemes/sources/<name>/
  2. Collections link into those sources under collections/<collection>/<app>/
  3. _project_config creates $XDG_CONFIG_HOME/colorschemes/<app>/<colorscheme>
     symlinks that point into the collection layout

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
            Options: --no-update (skip git pull), --dry-run

  link      Link collections and project config only (no fetch).
            Options: --dry-run

  list      Print configured sources and collections.
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


def tolist[T](x: T | Iterable[T]) -> Iterable[T]:
    if isinstance(x, str):
        return cast(list[T], [x])
    if isinstance(x, Iterable):
        return cast(Iterable[T], x)
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

    @staticmethod
    def _is_not_hidden(path: Path) -> bool:
        return not path.name.startswith(".")

    def match(self, root: Path | str = ".") -> Iterator[Path]:
        root = Path(root)
        patterns = tolist(self.pattern)
        excludes = tolist(self.exclude)
        filetypes = tolist(self.filetype)
        paths = tolist(self.paths)

        for path in paths:
            base = root / path
            for pattern in patterns:
                matches = base.glob(pattern, case_sensitive=False)
                if not self.include_hidden:
                    matches = filter(self._is_not_hidden, matches)
                for match in matches:
                    if any(fnmatch(match.name, ex) for ex in excludes):
                        continue
                    fullpath = base / match
                    if any(self._filetype_test[ft](fullpath) for ft in filetypes):
                        yield Path(path) / match


class _Source(ABC):
    @abstractmethod
    def retrieve(
        self, dest: Path | str, *, update: bool = True, dry_run: bool = False
    ) -> None: ...


@dataclass(kw_only=True)
class DirSource(_Source):
    path: Path | str

    @override
    def retrieve(
        self, dest: Path | str, *, update: bool = True, dry_run: bool = False
    ) -> None:
        path = Path(os.path.expandvars(self.path)).expanduser().resolve()
        dest = Path(os.path.expandvars(dest)).expanduser().resolve()
        if dest.is_dir():
            dest = dest / path.name
        if dry_run:
            print(f"  would symlink {dest} -> {path}")
            return
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.unlink(missing_ok=True)
        dest.symlink_to(path, target_is_directory=path.is_dir())


@dataclass(kw_only=True)
class GitSource(_Source):
    url: str
    ref: str | None = None

    @override
    def retrieve(
        self, dest: Path | str, *, update: bool = True, dry_run: bool = False
    ) -> None:
        dest = Path(os.path.expandvars(dest)).expanduser().resolve()

        commands: list[list[str]]
        if not dest.is_dir():
            clone = [
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
            commands = [clone]
            cwd = Path.cwd()
            if dry_run:
                print(f"  would clone {self.url} -> {dest}")
                return None
        elif update:
            stash = ["git", "stash", "push", "--include-untracked"]
            checkout = [
                "git",
                "checkout",
                "-f",
                "--recurse-submodules",
                *((self.ref,) if self.ref else ()),
            ]
            pull = ["git", "pull", "--force", "--recurse-submodules=on-demand"]
            commands = [stash, checkout, pull]
            cwd = dest
            if dry_run:
                print(f"  would update {self.url} -> {dest}")
                return None
        else:
            commands = []
            cwd = Path.cwd()
            if dry_run:
                print(f"  would skip {self.url} -> {dest}")
                return None

        if len(commands) == 0:
            return None

        dest.parent.mkdir(parents=True, exist_ok=True)
        for cmd in commands:
            print(">", *cmd)
            proc = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
            if proc.stdout:
                print(proc.stdout, end="")
            if proc.stderr:
                print(proc.stderr, end="", file=sys.stderr)
            # stash can exit 1 when there's nothing to stash—allow that
            if proc.returncode != 0 and cmd[1] != "stash":
                raise subprocess.CalledProcessError(
                    proc.returncode, cmd, proc.stdout, proc.stderr
                )


SOURCE_TYPES: dict[str, type[_Source]] = {
    "dir": DirSource,
    "git": GitSource,
}


@dataclass(kw_only=True)
class Source:
    name: str
    type: Literal["dir", "git"]
    source: _Source


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
        for target_path in target_paths:
            link_path = collection_path / target_path.name
            # Relative from parent of resolved link to resolved target
            link_target = target_path.resolve().relative_to(
                link_path.resolve().parent,
                walk_up=True
            )
            if dry_run:
                print(f"  would link {link_path} -> {link_target}")
                continue
            try:
                link_path.unlink(missing_ok=True)
            except (IsADirectoryError, OSError, PermissionError) as exc:
                print(
                    f"Warning: cannot replace {link_path} ({exc}); skipping",
                    file=sys.stderr,
                )
                continue
            link_path.symlink_to(
                link_target,
                target_is_directory=target_path.is_dir()
            )
        if collection_path.exists():
            for entry in collection_path.iterdir():
                if entry.is_symlink() and entry.name not in current_names:
                    if dry_run:
                        print(f"  would remove stale {entry}")
                    else:
                        entry.unlink(missing_ok=True)


def _expand_data_path(p: Path | str, base: Path = COLORS_DATA_HOME) -> Path:
    """Resolve path; if relative, resolve against base ($XDG_DATA_HOME/colorschemes)."""
    expanded = Path(os.path.expanduser(str(p)))
    if expanded.is_absolute():
        return expanded.resolve()
    return (base / expanded).resolve()


def _expand_config_path(s: str) -> Path:
    return Path(s).expanduser()


@dataclass(kw_only=True)
class Sources:
    directory: Path | str
    spec: list[Source]

    def retrieve_all(self, *, update: bool = True, dry_run: bool = False) -> None:
        directory = _expand_data_path(self.directory)
        if not dry_run:
            directory.mkdir(parents=True, exist_ok=True)
        for source in self.spec:
            source.source.retrieve(
                directory / source.name, update=update, dry_run=dry_run
            )


@dataclass(kw_only=True)
class Collections:
    directory: Path | str
    spec: list[Collection]

    def link_all(self, sources_root: Path, *, dry_run: bool = False) -> None:
        collections_root = _expand_data_path(self.directory)
        for collection in self.spec:
            collection.link_to_source(collections_root, sources_root, dry_run=dry_run)


def _project_config(
    collections_root: Path,
    *,
    dry_run: bool = False,
) -> None:
    """Create $XDG_CONFIG_HOME/colorschemes/<application>/<colorscheme> symlinks.
    Link each colorscheme file from its collection location.
    Also remove stale symlinks.
    """
    if not collections_root.is_dir():
        if dry_run:
            print("[dry-run] would project config (collections not yet linked)")
        return
    app_names: set[str] = set()
    for coll_dir in collections_root.iterdir():
        if coll_dir.is_dir():
            for entry in coll_dir.iterdir():
                if entry.is_dir() or entry.is_symlink():
                    app_names.add(entry.name)
    for app in sorted(app_names):
        config_app_dir = COLORS_CONFIG_HOME / app
        linked_files: set[str] = set()
        for coll_dir in sorted(collections_root.iterdir()):
            if not coll_dir.is_dir():
                continue
            app_dir = coll_dir / app
            if not app_dir.exists():
                continue
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
                    link_path.resolve().parent,
                    walk_up=True
                )
                if dry_run:
                    print(f"  would link {link_path} -> {rel}")
                    continue
                config_app_dir.mkdir(parents=True, exist_ok=True)
                try:
                    link_path.unlink(missing_ok=True)
                except (IsADirectoryError, OSError, PermissionError) as exc:
                    print(
                        f"Warning: cannot replace {link_path} ({exc}); skipping",
                        file=sys.stderr,
                    )
                    continue
                link_path.symlink_to(rel, target_is_directory=False)
        if config_app_dir.exists():
            for entry in config_app_dir.iterdir():
                if entry.is_symlink() and entry.name not in linked_files:
                    if dry_run:
                        print(f"  would remove stale {entry}")
                    else:
                        entry.unlink(missing_ok=True)
        elif dry_run and linked_files:
            print(f"  would create {config_app_dir}/ with {len(linked_files)} link(s)")


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
        if dry_run:
            print("[dry-run] would fetch sources:")
        self.config.sources.retrieve_all(update=update, dry_run=dry_run)
        sources_root = _expand_data_path(self.config.sources.directory)
        if dry_run:
            print("[dry-run] would link collections:")
        self.config.collections.link_all(sources_root=sources_root, dry_run=dry_run)
        if dry_run:
            print("[dry-run] would project config:")
        _project_config(
            _expand_data_path(self.config.collections.directory),
            dry_run=dry_run,
        )


class LinkCommand(Command):
    @override
    def __call__(self) -> None:
        dry_run = getattr(self.args, "dry_run", False)
        sources_root = _expand_data_path(self.config.sources.directory)
        if dry_run:
            print("[dry-run] would link collections:")
        self.config.collections.link_all(sources_root=sources_root, dry_run=dry_run)
        if dry_run:
            print("[dry-run] would project config:")
        _project_config(
            _expand_data_path(self.config.collections.directory),
            dry_run=dry_run,
        )


class ListCommand(Command):
    @override
    def __call__(self) -> None:
        print("Sources:")
        for s in self.config.sources.spec:
            print(f"  {s.name} ({s.type})")
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
    return Source(name=source_name, type=source_type, source=source)


def _parse_collection(data: dict[str, Any]) -> Collection:
    name = data["name"]
    source = data["source"]
    filter_data = data.get("filter")
    filter_obj = Filter(**filter_data) if filter_data else Filter()
    return Collection(name=name, source=source, filter=filter_obj)


def _parse_sources(data: dict[str, Any]) -> Sources:
    directory = data.get("directory", "sources")
    spec = [_parse_source(s) for s in data.get("spec", [])]
    return Sources(directory=directory, spec=spec)


def _parse_collections(data: dict[str, Any]) -> Collections:
    directory = data.get("directory", "collections")
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
        type=_expand_config_path,
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
    sync_parser.set_defaults(cmd_cls=SyncCommand)

    link_parser = subparsers.add_parser("link", help="Link collections only (no fetch)")
    link_parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without making changes",
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
        return 1
    except (TypeError, ValueError) as exc:
        print(f"Config error: {exc}", file=sys.stderr)
        return 1
    except subprocess.CalledProcessError as exc:
        print(f"Git failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
