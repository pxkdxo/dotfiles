#!/usr/bin/env python3
"""Download, link, and manage colorscheme sources for terminal and editor applications.

Requires Python 3.12+ (PEP 695 generics, ``Path.glob(case_sensitive=...)``,
``Path.relative_to(..., walk_up=True)``, ``typing.override``, ``tomllib``).

This script centralizes colorscheme management so you can pull themes from Git
repositories or local directories, filter them into collections, and expose them
to apps (Alacritty, Foot, Kitty, Neovim, Tmux, etc.) under a unified layout.
Each app sees its themes at $XDG_CONFIG_HOME/colorschemes/<app>/<colorscheme>.

Configuration
-------------
Config is read from $XDG_CONFIG_HOME/colorschemes/config.toml by default, or
from a path given with -c.

Filesystem layout
-----------------
  $XDG_CONFIG_HOME/colorschemes/   (default: ~/.config/colorschemes)
    Application-facing symlinks live here. Each subdirectory is an app name
    (e.g. alacritty, kitty, nvim), containing symlinks to colorschemes.

  $XDG_DATA_HOME/colorschemes/     (default: ~/.local/share/colorschemes)
    Sources are fetched into sources/ and filtered into collections/.

Sources / Collections
---------------------
A *Source* is where themes come from: a Git repository or a local directory.

  - name: Identifier for use in collections (must be a valid directory name)
  - type: 'git' or 'dir'
  - source: Type-specific details:
      For type='git': url (required), ref (branch/tag, optional)
      For type='dir': path (required)

A *Collection* is a filtered view of a source:

  - name: Identifier (must be a valid directory name)
  - source: Name of the source
  - app: Optional app name; when set, matched entries are that app's
      colorschemes rather than per-app directories
  - filter: Optional filter with:
      paths: Paths within the source to scan (default: '.')
      pattern: Glob(s) to include (default: '*')
      exclude: Glob(s) to exclude, matched against basenames of scanned
               entries and of entries inside each app directory
      filetype: 'd' (directories), 'f' (files), or both (default: 'd')
      include_hidden: Include hidden entries, at both levels (default: false)

  Globs are case-sensitive.

Symlink flow
------------
  1. Sources are fetched into $XDG_DATA_HOME/colorschemes/sources/<source>.
  2. Each matched entry of a collection's source is linked as an app
     directory at collections/<collection>/<app>, or, for a collection with
     `app`, as a colorscheme at collections/<collection>/<app>/<colorscheme>.
  3. $XDG_CONFIG_HOME/colorschemes/<app>/<colorscheme> is linked to each file
     or subdirectory of each collection's <app> directory. App names are
     lowercased, so 'Ghostty' and 'ghostty' share one directory. When
     collections provide the same <app>/<colorscheme>, the one listed first
     in the config wins; on a case-insensitive filesystem, names differing
     only in case also collide.

Stale links are removed at every level, along with directories left holding
nothing but symlinks. Existing regular files at link sites are preserved
unless --clobber is passed; existing directories are always preserved.

Example config
--------------

    [sources]
    directory = 'sources'

    [[sources.spec]]
    name = 'iTerm2-Color-Schemes'
    type = 'git'
    source = { url = 'https://github.com/mbadolato/iTerm2-Color-Schemes.git' }

    [[sources.spec]]
    name = 'vivid-themes'
    type = 'dir'
    source = { path = '${XDG_CONFIG_HOME}/vivid/themes' }

    [collections]
    directory = 'collections'

    [[collections.spec]]
    name = 'iTerm2-Color-Schemes'
    source = 'iTerm2-Color-Schemes'
    filter = { exclude = ['gh-pages', 'screenshots', 'tools', '*.md'] }

    [[collections.spec]]
    name = 'vivid-themes'
    source = 'vivid-themes'
    app = 'vivid'
    filter = { filetype = 'f' }
"""

import os
import shutil
import subprocess
import sys
import tomllib
import uuid
from abc import ABC, abstractmethod
from argparse import ArgumentParser, RawDescriptionHelpFormatter
from collections import Counter
from collections.abc import Callable, Iterable, Iterator
from dataclasses import dataclass, field
from fnmatch import fnmatchcase
from pathlib import Path
from typing import Any, ClassVar, Final, Self, cast, override

XDG_CONFIG_HOME: Final = Path(os.getenv("XDG_CONFIG_HOME") or Path.home() / ".config")
XDG_DATA_HOME: Final = Path(os.getenv("XDG_DATA_HOME") or Path.home() / ".local/share")
COLORS_CONFIG_HOME: Final = XDG_CONFIG_HOME / "colorschemes"
COLORS_DATA_HOME: Final = XDG_DATA_HOME / "colorschemes"
DEFAULT_CONFIG: Final = COLORS_CONFIG_HOME / "config.toml"

_CONFLICT_CODES: Final = frozenset({"UU", "AA", "DD", "AU", "UA", "DU", "UD"})


class CommandError(Exception):
    """A failure reported to the user without a traceback."""


def warn(msg: str) -> None:
    print(f"Warning: {msg}", file=sys.stderr)


def expand_path(p: str | Path) -> Path:
    return Path(os.path.expandvars(p)).expanduser()


def resolve_data_path(p: str) -> Path:
    """Expand `p` and resolve it, relative to $XDG_DATA_HOME/colorschemes."""
    return (COLORS_DATA_HOME / expand_path(p)).resolve()


def as_tuple[T](x: T | Iterable[T]) -> tuple[T, ...]:
    if isinstance(x, str) or not isinstance(x, Iterable):
        return (cast(T, x),)
    return tuple(cast(Iterable[T], x))


def _holds_only_links(directory: Path) -> bool:
    """Whether everything under `directory` is a symlink or a directory that
    itself holds only symlinks.
    """
    return all(
        p.is_symlink() or (p.is_dir() and _holds_only_links(p))
        for p in directory.iterdir()
    )


def _is_case_insensitive(path: Path) -> bool:
    """Whether the filesystem holding `path`, or its nearest existing
    ancestor, treats names differing only in case as the same entry.
    """
    for p in (path, *path.parents):
        if p.exists() and p.name != p.name.swapcase():
            twin = p.with_name(p.name.swapcase())
            return twin.exists() and os.path.samefile(p, twin)
    return False


@dataclass(frozen=True)
class Linker:
    """Apply filesystem changes, or with `dry_run`, only report them."""

    dry_run: bool = False
    clobber: bool = False

    def heading(self, text: str) -> None:
        print(f"{'[dry-run] ' if self.dry_run else ''}{text}:")

    def report(self, label: str, counts: dict[str, int]) -> None:
        summary = ", ".join(f"{n} {what}" for what, n in counts.items() if n)
        print(
            f"  {'[dry-run] ' if self.dry_run else ''}{label}: {summary or 'up to date'}"
        )

    def symlink(self, link: Path, target: Path) -> bool:
        """Point `link` at `target` with a relative symlink, replacing any
        existing symlink. A real file is kept unless `clobber`; a real
        directory is always kept. Return whether a link was (or would be)
        created.
        """
        rel = target.relative_to(link.parent.resolve(), walk_up=True)
        is_real = link.exists() and not link.is_symlink()
        if is_real and (link.is_dir() or not self.clobber):
            reason = (
                "existing directory"
                if link.is_dir()
                else "existing file; pass --clobber to overwrite"
            )
            warn(f"cannot replace {link} ({reason}); skipping")
            return False
        if link.is_symlink() and os.readlink(link) == os.fspath(rel):
            return False
        if self.dry_run:
            print(f"  would {'clobber' if is_real else 'link'} {link} -> {rel}")
            return True
        link.parent.mkdir(parents=True, exist_ok=True)
        # Create at a sibling temp name, then atomically swap into place.
        tmp = link.with_name(f".{link.name}.{uuid.uuid4().hex}.tmp")
        tmp.symlink_to(rel)
        try:
            os.replace(tmp, link)
        except OSError:
            tmp.unlink(missing_ok=True)
            raise
        return True

    def remove_stale_links(self, directory: Path, keep: Callable[[str], bool]) -> int:
        """Remove symlinks in `directory` whose names `keep` rejects; return how
        many were (or would be) removed.
        """
        if not directory.is_dir():
            return 0
        stale = [p for p in directory.iterdir() if p.is_symlink() and not keep(p.name)]
        for p in stale:
            if self.dry_run:
                print(f"  would remove stale {p}")
            else:
                p.unlink()
        return len(stale)

    def remove_link_dir(self, directory: Path) -> bool:
        """Remove `directory` if it holds nothing but symlinks (at any depth);
        otherwise warn and leave it. Return whether it was (or would be)
        removed.
        """
        if not _holds_only_links(directory):
            warn(
                f"stale directory {directory} has non-symlink entries; leaving in place"
            )
            return False
        if self.dry_run:
            print(f"  would remove stale directory {directory}")
        else:
            shutil.rmtree(directory)
        return True

    def rename(self, src: Path, dst: Path) -> None:
        if self.dry_run:
            print(f"  would rename {src} -> {dst}")
        else:
            _ = src.rename(dst)


def _git(
    *args: str, cwd: Path | None = None, check: bool = True, quiet: bool = False
) -> subprocess.CompletedProcess[str]:
    """Run git. When `quiet`, output is captured and returned; otherwise git
    inherits this process's stdio so progress streams live to the user.
    """
    cmd = ["git", *args]
    if not quiet:
        print(">", *cmd)
    proc = subprocess.run(cmd, cwd=cwd, capture_output=quiet, text=True, check=False)
    if check and proc.returncode != 0:
        raise subprocess.CalledProcessError(
            proc.returncode, cmd, proc.stdout, proc.stderr
        )
    return proc


@dataclass(kw_only=True)
class Source(ABC):
    kind: ClassVar[str]

    name: str

    @abstractmethod
    def retrieve(self, dest: Path, linker: Linker, *, update: bool) -> None: ...


@dataclass(kw_only=True)
class DirSource(Source):
    kind: ClassVar[str] = "dir"

    path: str

    @override
    def retrieve(self, dest: Path, linker: Linker, *, update: bool) -> None:
        path = expand_path(self.path).resolve()
        if not path.is_dir():
            raise CommandError(f"source '{self.name}': {path} is not a directory")
        _ = linker.symlink(dest, path)


@dataclass(kw_only=True)
class GitSource(Source):
    kind: ClassVar[str] = "git"

    url: str
    ref: str | None = None

    @override
    def retrieve(self, dest: Path, linker: Linker, *, update: bool) -> None:
        if not dest.exists():
            if linker.dry_run:
                print(f"  would clone {self.url} -> {dest}")
                return
            dest.parent.mkdir(parents=True, exist_ok=True)
            _ = _git(
                "clone",
                "--depth=1",
                "--single-branch",
                "--recurse-submodules",
                "--shallow-submodules",
                *(("--branch", self.ref) if self.ref else ()),
                "--",
                self.url,
                str(dest),
            )
            return
        if not (dest / ".git").exists():
            raise CommandError(
                f"{dest} exists but is not a git checkout; move it aside and retry"
            )
        if not update:
            print(f"  skipping update of {self.url} -> {dest}")
        elif linker.dry_run:
            print(f"  would update {self.url} -> {dest}")
        else:
            self._update(dest)

    def _update(self, dest: Path) -> None:
        """Fetch the latest ref into `dest`, stashing local edits around the
        fetch and checkout. If restoring the stash fails, it is left in place
        for the user to resolve.
        """
        restore_hint = (
            f"find it with: git -C {dest} stash list\n"
            + f"then restore with: git -C {dest} stash pop stash@{{N}}"
        )
        status = _git("status", "--porcelain", "-uall", cwd=dest, quiet=True).stdout
        if any(line[:2] in _CONFLICT_CODES for line in status.splitlines()):
            raise CommandError(
                f"unresolved conflicts in {dest} from a previous failed sync; "
                + f"resolve them, then restore the saved stash; {restore_hint}"
            )
        stash_msg = f"colorschemes-sync: {self.url}"
        stashed = False
        if status.strip():
            before = self._stash_head(dest)
            _ = _git(
                "stash", "push", "--include-untracked", "--message", stash_msg, cwd=dest
            )
            # Push saves nothing, yet exits 0, when only submodules differ.
            stashed = self._stash_head(dest) != before
        try:
            _ = _git(
                "fetch",
                "--depth=1",
                "--recurse-submodules=on-demand",
                "origin",
                *(("--", self.ref) if self.ref else ()),
                cwd=dest,
            )
            _ = _git("checkout", "-f", "--detach", "FETCH_HEAD", cwd=dest)
        finally:
            if stashed and _git("stash", "pop", cwd=dest, check=False).returncode:
                msg = f"local changes in {dest} preserved as stash '{stash_msg}'; {restore_hint}"
                # Don't mask an in-flight exception with the stash-pop error.
                if sys.exception() is None:
                    raise CommandError(msg)
                warn(msg)

    @staticmethod
    def _stash_head(dest: Path) -> str:
        """Commit ID of the newest stash in `dest`, or '' if there is none."""
        ref = ("rev-parse", "--quiet", "--verify", "refs/stash")
        return _git(*ref, cwd=dest, check=False, quiet=True).stdout.strip()


SOURCE_TYPES: Final[dict[str, type[Source]]] = {
    cls.kind: cls for cls in (DirSource, GitSource)
}


@dataclass(frozen=True, kw_only=True)
class Filter:
    paths: tuple[str, ...] = (".",)
    pattern: tuple[str, ...] = ("*",)
    exclude: tuple[str, ...] = ()
    filetype: tuple[str, ...] = ("d",)
    include_hidden: bool = False

    @classmethod
    def from_config(cls, data: dict[str, Any]) -> Self:
        """Build from a TOML table, where list options also accept one string."""
        flt = cls(
            **{k: as_tuple(v) for k, v in data.items() if k != "include_hidden"},
            include_hidden=bool(data.get("include_hidden", False)),
        )
        if unknown := set(flt.filetype) - {"d", "f"}:
            raise ValueError(
                f"unknown filetype(s) {sorted(unknown)}; expected 'd' or 'f'"
            )
        return flt

    def excludes(self, name: str) -> bool:
        """Whether basename `name` is hidden (and hidden entries are
        excluded) or matches an `exclude` glob.
        """
        if name.startswith(".") and not self.include_hidden:
            return True
        return any(fnmatchcase(name, ex) for ex in self.exclude)

    def match(self, root: Path) -> Iterator[Path]:
        """Yield the entries under `root` this filter selects."""
        for path in self.paths:
            for pattern in self.pattern:
                for entry in sorted((root / path).glob(pattern, case_sensitive=True)):
                    if self.excludes(entry.name):
                        continue
                    if ("d" in self.filetype and entry.is_dir()) or (
                        "f" in self.filetype and entry.is_file()
                    ):
                        yield entry


@dataclass(frozen=True)
class Colorscheme:
    """One entry of the application-facing layout."""

    app: str
    path: Path
    origin: str


@dataclass(kw_only=True)
class Collection:
    name: str
    source: str
    app: str | None = None
    filter: Filter = field(default_factory=Filter)

    def matched_paths(self, sources_dir: Path) -> dict[str, Path]:
        """Map basename to source path for each entry the filter selects,
        keeping the first on a basename collision.
        """
        source_path = sources_dir / self.source
        if not source_path.is_dir():
            raise CommandError(
                f"source '{self.source}' of collection '{self.name}' not found at "
                + f"{source_path}; run 'sync' first"
            )
        matched: dict[str, Path] = {}
        for path in self.filter.match(source_path):
            kept = matched.setdefault(path.name, path)
            if kept != path:
                warn(
                    f"collection '{self.name}': basename collision '{path.name}' "
                    + f"between {kept} and {path}; keeping first"
                )
        return matched

    def link(
        self, sources_dir: Path, collections_dir: Path, linker: Linker
    ) -> list[Colorscheme]:
        """Link this collection to its source and return the colorschemes it
        provides.
        """
        if linker.dry_run and not (sources_dir / self.source).is_dir():
            print(f"  would link '{self.name}' once source '{self.source}' is fetched")
            return []
        matched = self.matched_paths(sources_dir)
        collection_dir = collections_dir / self.name
        link_dir = collection_dir / self.app if self.app else collection_dir
        linked = sum(linker.symlink(link_dir / n, p) for n, p in matched.items())
        removed = linker.remove_stale_links(link_dir, matched.__contains__)
        if self.app:
            removed += linker.remove_stale_links(collection_dir, lambda _: False)
        # Real directories here are left over from a different `app` setting.
        if collection_dir.is_dir():
            removed += sum(
                linker.remove_link_dir(p)
                for p in collection_dir.iterdir()
                if p.is_dir() and not p.is_symlink() and p.name != self.app
            )
        linker.report(self.name, {"linked": linked, "removed": removed})
        return list(self._colorschemes(matched, link_dir))

    def _colorschemes(
        self, matched: dict[str, Path], link_dir: Path
    ) -> Iterator[Colorscheme]:
        if self.app:
            origin = f"{self.name}/{self.app}"
            for name in matched:
                yield Colorscheme(app=self.app, path=link_dir / name, origin=origin)
            return
        for app_name, app_source in matched.items():
            if not app_source.is_dir():
                warn(
                    f"collection '{self.name}': '{app_name}' is not a directory; "
                    + "set 'app' on the collection if its entries are colorschemes"
                )
                continue
            origin = f"{self.name}/{app_name}"
            for entry in sorted(app_source.iterdir()):
                if entry.exists() and not self.filter.excludes(entry.name):
                    yield Colorscheme(
                        app=app_name.lower(),
                        path=link_dir / app_name / entry.name,
                        origin=origin,
                    )


def link_apps(
    colorschemes: Iterable[Colorscheme],
    linker: Linker,
    config_root: Path = COLORS_CONFIG_HOME,
) -> None:
    """Link <config_root>/<app>/<colorscheme> to each of `colorschemes`,
    keeping the first for each name, then remove stale links and app
    directories left with nothing to link.
    """
    fold: Callable[[str], str] = (
        str.casefold
        if _is_case_insensitive(config_root.resolve())
        else (lambda name: name)
    )
    by_app: dict[str, dict[str, Colorscheme]] = {}
    for cs in colorschemes:
        chosen = by_app.setdefault(cs.app, {})
        kept = chosen.setdefault(fold(cs.path.name), cs)
        if kept is not cs:
            reason = (
                ""
                if kept.path.name == cs.path.name
                else " (names differ only in case on a case-insensitive filesystem)"
            )
            warn(
                f"app '{cs.app}': '{cs.path.name}' from {cs.origin} collides with "
                + f"'{kept.path.name}' from {kept.origin}{reason}; keeping {kept.origin}"
            )

    on_disk = (
        {fold(p.name): p for p in config_root.iterdir()} if config_root.is_dir() else {}
    )
    linked = removed = 0
    for app, chosen in sorted(by_app.items()):
        app_dir = config_root / app
        variant = on_disk.get(fold(app))
        if (
            variant is not None
            and variant.name != app
            and variant.is_dir()
            and not variant.is_symlink()
        ):
            linker.rename(variant, app_dir)
        elif linker.dry_run and not app_dir.exists():
            print(f"  would create {app_dir}/ with {len(chosen)} link(s)")
        linked += sum(
            linker.symlink(app_dir / cs.path.name, cs.path) for cs in chosen.values()
        )
        removed += linker.remove_stale_links(app_dir, lambda name: fold(name) in chosen)

    linked_apps = {fold(app) for app in by_app}
    removed_dirs = 0
    if config_root.is_dir():
        for path in sorted(config_root.iterdir()):
            # Dot-prefixed names (e.g. .git) are never apps and may be VCS metadata.
            if (
                path.is_dir()
                and not path.is_symlink()
                and not path.name.startswith(".")
                and fold(path.name) not in linked_apps
            ):
                removed_dirs += linker.remove_link_dir(path)
    linker.report(
        f"{len(by_app)} apps",
        {"linked": linked, "removed": removed, "app dirs removed": removed_dirs},
    )


@dataclass(kw_only=True)
class Config:
    sources_dir: Path
    sources: list[Source]
    collections_dir: Path
    collections: list[Collection]

    @classmethod
    def load(cls, path: Path) -> Self:
        with path.open("rb") as f:
            data = tomllib.load(f)
        sources_data = data.get("sources", {})
        collections_data = data.get("collections", {})
        sources = [_parse_source(s) for s in sources_data.get("spec", [])]
        collections = [_parse_collection(c) for c in collections_data.get("spec", [])]
        _check_unique_names([s.name for s in sources], "source")
        _check_unique_names([c.name for c in collections], "collection")
        source_names = {s.name for s in sources}
        for c in collections:
            if c.source not in source_names:
                raise ValueError(
                    f"collection '{c.name}' names unknown source '{c.source}'"
                )
        return cls(
            sources_dir=resolve_data_path(sources_data.get("directory", "sources")),
            sources=sources,
            collections_dir=resolve_data_path(
                collections_data.get("directory", "collections")
            ),
            collections=collections,
        )


def _parse_source(data: dict[str, Any]) -> Source:
    kind = data["type"]
    cls = SOURCE_TYPES.get(kind)
    if cls is None:
        raise ValueError(
            f"unknown type '{kind}' for source '{data['name']}'; "
            + f"expected one of {sorted(SOURCE_TYPES)}"
        )
    return cls(name=data["name"], **data["source"])


def _parse_collection(data: dict[str, Any]) -> Collection:
    app = data.get("app")
    return Collection(
        name=data["name"],
        source=data["source"],
        app=app.lower() if app else None,
        filter=Filter.from_config(data.get("filter", {})),
    )


def _check_unique_names(names: list[str], kind: str) -> None:
    if dups := sorted(n for n, c in Counter(names).items() if c > 1):
        raise ValueError(f"duplicate {kind} name(s): {dups}")


def link(config: Config, linker: Linker) -> None:
    linker.heading("Linking collections")
    colorschemes = [
        cs
        for collection in config.collections
        for cs in collection.link(config.sources_dir, config.collections_dir, linker)
    ]
    names = {c.name for c in config.collections}
    if config.collections_dir.is_dir():
        removed = sum(
            linker.remove_link_dir(path)
            for path in sorted(config.collections_dir.iterdir())
            if path.is_dir()
            and not path.is_symlink()
            and not path.name.startswith(".")
            and path.name not in names
        )
        if removed:
            linker.report("unconfigured collections", {"removed": removed})
    linker.heading("Linking apps")
    link_apps(colorschemes, linker)


def sync(config: Config, linker: Linker, *, update: bool) -> None:
    linker.heading("Fetching sources")
    for source in config.sources:
        source.retrieve(config.sources_dir / source.name, linker, update=update)
    link(config, linker)


def show(config: Config) -> None:
    print("Sources:")
    for s in config.sources:
        print(f"  {s.name} ({s.kind})")
    print("\nCollections:")
    for c in config.collections:
        app = f" (app: {c.app})" if c.app else ""
        print(f"  {c.name} <- {c.source}{app}")


def main() -> int:
    summary, _, details = (__doc__ or "").partition("\n")
    parser = ArgumentParser(
        description=summary,
        epilog=details,
        formatter_class=RawDescriptionHelpFormatter,
    )
    _ = parser.add_argument(
        "-c",
        "--config",
        type=expand_path,
        default=DEFAULT_CONFIG,
        help=f"Config file (default: {DEFAULT_CONFIG})",
    )
    commands = parser.add_subparsers(dest="command", required=True)
    sync_parser = commands.add_parser(
        "sync", help="Fetch sources, then link collections and apps"
    )
    _ = sync_parser.add_argument(
        "--no-update",
        dest="update",
        action="store_false",
        help="Skip updating existing git sources",
    )
    link_parser = commands.add_parser(
        "link", help="Link collections and apps without fetching"
    )
    for linking in (sync_parser, link_parser):
        _ = linking.add_argument(
            "--dry-run",
            action="store_true",
            help="Show what would be done without making changes",
        )
        _ = linking.add_argument(
            "--clobber",
            action="store_true",
            help="Overwrite existing regular files at link sites (directories are still preserved)",
        )
    _ = commands.add_parser("list", help="List configured sources and collections")
    args = parser.parse_args()

    try:
        config = Config.load(args.config)
    except FileNotFoundError:
        print(
            f"Error: config file {args.config} not found; see --help for an example",
            file=sys.stderr,
        )
        return 1
    except KeyError as exc:
        print(f"Config error in {args.config}: missing key {exc}", file=sys.stderr)
        return 1
    except (OSError, TypeError, ValueError) as exc:
        print(f"Config error in {args.config}: {exc}", file=sys.stderr)
        return 1

    try:
        match args.command:
            case "sync":
                sync(config, Linker(args.dry_run, args.clobber), update=args.update)
            case "link":
                link(config, Linker(args.dry_run, args.clobber))
            case _:
                show(config)
    except subprocess.CalledProcessError as exc:
        print(f"Git failed: {exc}", file=sys.stderr)
        return 1
    except (CommandError, OSError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
