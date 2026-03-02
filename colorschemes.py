#!/usr/bin/env python3
"""Download, link, and update colorscheme sources and groupings.

Settings are given by a configuration file at ${XDG_CONFIG_HOME}/colorschemes/config.toml.
XDG_CONFIG_HOME defaults to ~/.config; XDG_DATA_HOME defaults to ~/.local/share.

Symlink layout:
  ${XDG_CONFIG_HOME}/colorschemes/<APP>/<COLORSCHEME>
    -> ${XDG_DATA_HOME}/colorschemes/collections/<COLLECTION>/<APP>/<COLORSCHEME>
  ${XDG_DATA_HOME}/colorschemes/collections/<COLLECTION>/<APP>
    -> ${XDG_DATA_HOME}/colorschemes/sources/<SOURCE>/[<FILTER_PATH>/]<APP>

All symlinks are relative. Directories sources/ and collections/ live under
$XDG_DATA_HOME/colorschemes. Relative paths in config are resolved against that.

Configuration file format:

    [sources]
    directory = 'sources'  # Relative to $XDG_DATA_HOME/colorschemes

    [collections]
    directory = 'collections'

    [[sources.spec]]
    name = 'iTerm2-Color-Schemes'
    type = 'git'  # Downloads and updates from git
    source = {
      url = 'https://github.com/mbadolato/iTerm2-Color-Schemes.git',
      ref = 'master'  # Optional branch or tag
    }

    [[collections.spec]]
    name = 'iTerm2-Color-Schemes'
    source = 'iTerm2-Color-Schemes'
    filter = {
      exclude = ['gh-pages', 'screenshots', 'tools']
    }

A 'Source' is a data source which contains application colorschemes.

A 'Collection' is a projection of source content which requires a Source name
and accepts the following filter parameters:
    1. 'paths', relative to the root of the source, which will be the root of
       the projection.
    2. 'pattern', 'exclude', and 'filetype', which define what to match and
       create a symlink for each match at the top level of the Collection
       directory.
"""

import inspect
import os
import subprocess
import sys
import tomllib
from abc import ABC, abstractmethod
from argparse import ArgumentParser, Namespace
from collections.abc import Iterator
from dataclasses import dataclass, field
from fnmatch import fnmatch
from glob import iglob
from pathlib import Path
from typing import Any, Callable, ClassVar, Final, Literal, cast, override


_IGLOB_HAS_INCLUDE_HIDDEN = "include_hidden" in inspect.signature(iglob).parameters


def _ensure_list[T](x: T | list[T] | tuple[T, ...]) -> list[T]:
    if isinstance(x, list):
        return cast(list[T], x)
    if isinstance(x, tuple):
        return cast(list[T], [*x])
    return [x]


def _from_mapping[T](cls: type[T], data: dict[str, Any]) -> T:
    return cls(**data)



XDG_CONFIG_HOME: Final[Path] = Path(
    os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
)
XDG_DATA_HOME: Final[Path] = Path(
    os.environ.get("XDG_DATA_HOME") or os.path.expanduser("~/.local/share")
)
COLORS_CONFIG_HOME: Final[Path] = XDG_CONFIG_HOME / "colorschemes"
COLORS_DATA_HOME: Final[Path] = XDG_DATA_HOME / "colorschemes"


type _Filetype = Literal["d", "f"]


@dataclass(kw_only=True)
class Filter:
    pattern: str | list[str] = "*"
    exclude: str | list[str] = field(default_factory=list)
    filetype: _Filetype | list[_Filetype] = "d"
    hidden: bool = False
    paths: str | list[str] = "."

    _filetype_test: ClassVar[dict[str, Callable[[Path], bool]]] = {
        "d": lambda p: p.is_dir(),
        "f": lambda p: p.is_file(),
    }

    def match(self, root: Path | str = ".") -> Iterator[Path]:
        root = Path(root)
        patterns = _ensure_list(self.pattern)
        excludes = _ensure_list(self.exclude)
        filetypes = _ensure_list(self.filetype)
        paths = _ensure_list(self.paths)

        if _IGLOB_HAS_INCLUDE_HIDDEN and self.hidden:
            iglob_kwargs = {"include_hidden": self.hidden}
        else:
            iglob_kwargs = {}

        for path in paths:
            base = root / path
            for pattern in patterns:
                for match in iglob(pattern, root_dir=base, **iglob_kwargs):
                    if any(fnmatch(match, ex) for ex in excludes):
                        continue
                    full_path = base / match
                    for ft in filetypes:
                        if self._filetype_test[ft](full_path):
                            yield Path(path) / match
                            break


class _Source(ABC):
    @abstractmethod
    def retrieve(
        self, dest: Path | str, update: bool = True, *, dry_run: bool = False
    ) -> None: ...


@dataclass(kw_only=True)
class DirSource(_Source):
    path: Path | str

    @override
    def retrieve(
        self, dest: Path | str, update: bool = True, *, dry_run: bool = False
    ) -> None:
        path = Path(self.path).expanduser().resolve()
        dest = Path(dest).expanduser().resolve()
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
        self, dest: Path | str, update: bool = True, *, dry_run: bool = False
    ) -> None:
        dest = Path(dest).expanduser().resolve()

        cmds: list[list[str]]
        if not dest.is_dir():
            cmds = [
                ["git", "clone", "--single-branch", "--depth", "1",
                 "--recurse-submodules", "--shallow-submodules"]
                + (["--branch", self.ref] if self.ref else [])
                + ["--", self.url, str(dest)]
            ]
            cwd = Path.cwd()
        elif update:
            checkout = ["git", "checkout", "-f", "--recurse-submodules"]
            if self.ref:
                checkout.append(self.ref)
            cmds = [
                ["git", "stash", "push", "--include-untracked"],
                checkout,
                ["git", "pull", "--force", "--recurse-submodules=on-demand"],
            ]
            cwd = dest
        else:
            cmds = []
            cwd = Path.cwd()

        if dry_run:
            action = "clone" if not dest.is_dir() else ("pull" if update else "skip")
            print(f"  would {action} {self.url} -> {dest}")
            return

        dest.parent.mkdir(parents=True, exist_ok=True)
        for cmd in cmds:
            proc = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
            if proc.stdout:
                print(proc.stdout, end="")
            if proc.stderr:
                print(proc.stderr, end="", file=sys.stderr)
            # stash can exit 1 when there's nothing to stash—allow that
            if proc.returncode != 0 and cmd[1] != "stash":
                raise subprocess.CalledProcessError(proc.returncode, cmd, proc.stdout, proc.stderr)


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
                f"Source '{self.source}' not found at {source_path}; "
                f"run 'sync' first or check collection '{self.name}' config"
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
            # Use resolved path so symlink targets resolve correctly when the
            # collection directory is reached via symlinks.
            rel = target_path.relative_to(collection_path.resolve(), walk_up=True)
            if dry_run:
                print(f"  would link {link_path} -> {rel}")
                continue
            try:
                link_path.unlink(missing_ok=True)
            except (IsADirectoryError, OSError, PermissionError) as exc:
                print(
                    f"Warning: cannot replace {link_path} ({exc}); skipping",
                    file=sys.stderr,
                )
                continue
            link_path.symlink_to(rel, target_is_directory=target_path.is_dir())
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
    if not expanded.is_absolute():
        return (base / expanded).resolve()
    return expanded.resolve()


def _expand_config_path(s: str) -> Path:
    return Path(s).expanduser()


@dataclass(kw_only=True)
class Sources:
    directory: Path | str
    spec: list[Source]

    def retrieve_all(
        self, update: bool = True, *, dry_run: bool = False
    ) -> None:
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

    def link_all(
        self, sources_root: Path, *, dry_run: bool = False
    ) -> None:
        collections_root = _expand_data_path(self.directory)
        for collection in self.spec:
            collection.link_to_source(
                collections_root, sources_root, dry_run=dry_run
            )


def _project_config(
    collections_root: Path,
    *,
    dry_run: bool = False,
) -> None:
    """Create $XDG_CONFIG_HOME/colorschemes/<APPLICATION>/<COLORSCHEME> symlinks.

    APPLICATION is each unique subdirectory under collections/*/.
    Each colorscheme file is symlinked from config to its collection location.
    Stale symlinks in config are removed.
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
                # Use resolved config path: symlink targets are resolved relative to the
                # actual directory on disk (e.g. ~/.config -> ~/.local/etc), so the
                # relative path must be computed from the resolved location.
                rel = entry.relative_to(config_app_dir.resolve(), walk_up=True)
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
    def run(self) -> None: ...


class SyncCommand(Command):
    @override
    def run(self) -> None:
        update = getattr(self.args, "update", True)
        dry_run = getattr(self.args, "dry_run", False)
        if dry_run:
            print("[dry-run] would fetch sources:")
        self.config.sources.retrieve_all(update=update, dry_run=dry_run)
        sources_root = _expand_data_path(self.config.sources.directory)
        if dry_run:
            print("[dry-run] would link collections:")
        self.config.collections.link_all(
            sources_root=sources_root, dry_run=dry_run
        )
        if dry_run:
            print("[dry-run] would project config:")
        _project_config(
            _expand_data_path(self.config.collections.directory),
            dry_run=dry_run,
        )


class LinkCommand(Command):
    @override
    def run(self) -> None:
        dry_run = getattr(self.args, "dry_run", False)
        sources_root = _expand_data_path(self.config.sources.directory)
        if dry_run:
            print("[dry-run] would link collections:")
        self.config.collections.link_all(
            sources_root=sources_root, dry_run=dry_run
        )
        if dry_run:
            print("[dry-run] would project config:")
        _project_config(
            _expand_data_path(self.config.collections.directory),
            dry_run=dry_run,
        )


class ListCommand(Command):
    @override
    def run(self) -> None:
        print("Sources:")
        for s in self.config.sources.spec:
            print(f"  {s.name} ({s.type})")
        print("\nCollections:")
        for c in self.config.collections.spec:
            print(f"  {c.name} <- {c.source}")


def _parse_source(data: dict[str, Any]) -> Source:
    name = data["name"]
    type_ = data["type"]
    if type_ not in SOURCE_TYPES:
        raise ValueError(
            f"Unknown source type '{type_}' for '{name}'; "
            f"expected one of {list(SOURCE_TYPES)}"
        )
    source_data = data["source"]
    source = _from_mapping(SOURCE_TYPES[type_], source_data)
    return Source(name=name, type=type_, source=source)


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
        "-c", "--config",
        type=_expand_config_path,
        default=COLORS_CONFIG_HOME / "config.toml",
        help=f"Config file (default: {COLORS_CONFIG_HOME / 'config.toml'})",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    sync_parser = subparsers.add_parser("sync", help="Fetch sources and link collections")
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
        cmd.run()
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
