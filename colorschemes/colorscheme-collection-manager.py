#!/usr/bin/env python3
"""
Download, link, and update colorschemes - all manged by a simple config file.
"""

from abc import ABC, abstractmethod
from collections.abc import Iterator
from argparse import ArgumentParser
from dataclasses import dataclass, field
from glob import iglob
from fnmatch import fnmatch
import os
from pathlib import Path
import tomllib
import subprocess
import sys
import textwrap
from typing import Callable, ClassVar, Literal, Self, override


type RawTypeDef = dict[str, str | int | float | bool | RawTypeDef | list[RawTypeDef] | None]


HERE = Path(__file__).parent.resolve()

XDG_DATA_HOME = Path(
    os.getenv("XDG_DATA_HOME") or
    os.path.expanduser('~/.local/share'))
XDG_CONFIG_HOME = Path(
    os.getenv("XDG_CONFIG_HOME") or
    os.path.expanduser('~/.config'))

COLORS_CONFIG_HOME = XDG_CONFIG_HOME / "colorschemes"


@dataclass(kw_only=True)
class Filter:
    type _Filetype = Literal["d","f"]

    pattern: str | list[str] = "*"
    exclude: str | list[str] = field(default_factory=list)
    filetype: _Filetype | list[_Filetype] = "d"
    hidden: bool = False
    paths: str | list[str] = "."

    _filetype_test: ClassVar[dict[str, Callable[[Path], bool]]] = {
        "d": os.path.isdir,
        "f": os.path.isfile,
    }

    @classmethod
    def from_raw(cls, **kwargs) -> Self:
        return cls(**kwargs)

    def match(self, root: Path | str = ".") -> Iterator[Path]:
        root = Path(root)
        patterns = self.pattern
        if not isinstance(patterns, list):
            patterns = [patterns]
        excludes = self.exclude
        if not isinstance(excludes, list):
            excludes = [excludes]
        filetypes = self.filetype
        if not isinstance(filetypes, list):
            filetypes = [filetypes]
        paths = self.paths
        if not isinstance(paths, list):
            paths = [paths]


        for path in paths:
            for pattern in patterns:
                for match in iglob(
                    pattern, root_dir=root / path, include_hidden=self.hidden
                ):
                    for exclude in excludes:
                        if fnmatch(match, exclude):
                            break
                    else:
                        for filetype in filetypes:
                            if self._filetype_test[filetype](Path(match)):
                                 yield Path(path) / match


class _Source(ABC):
    @classmethod
    @abstractmethod
    def from_raw(cls, **kwargs) -> Self: ...

    @abstractmethod
    def retrieve(self, dest: Path | str, update: bool = True) -> None: ...


@dataclass(kw_only=True)
class DirSource(_Source):
    path: Path | str

    @classmethod
    def from_raw(cls, **kwargs) -> Self:
        return cls(**kwargs)

    @override
    def retrieve(self, dest: Path | str, update: bool = True) -> None:
        path = Path(self.path)
        dest = Path(dest).absolute()
        if dest.is_dir():
            dest = dest / path.name
        dest.symlink_to(path, target_is_directory=path.is_dir())


@dataclass(kw_only=True)
class GitSource(_Source):
    url: str
    ref: str | None = None

    @classmethod
    def from_raw(cls, **kwargs) -> Self:
        return cls(**kwargs)

    @override
    def retrieve(self, dest: Path | str, update: bool = True) -> None:
        dest = Path(dest).absolute()
        cmds: list[list[str]]
        if not dest.is_dir():
            cmddir = os.getcwd()
            one: list[str] = [
                "git", "clone", "--single-branch", "--depth", "1", "--recurse-submodules", "--shallow-submodules"
            ]
            if self.ref is not None:
                one.extend(["--branch", self.ref])
            one.extend(["--", self.url, str(dest)])
            cmds = [one]
        elif update:
            cmddir = str(dest)
            cmds = [
                ["git", "stash", "push", "--include-untracked"],
                ["git", "checkout", "-f", "--recurse-submodules"],
                ["git", "pull", "--force", "--recurse-submodules=on-demand"],
            ]
            if self.ref is not None:
                cmds[1].append(str(self.ref))
        else:
            cmddir = os.getcwd()
            cmds = []
        for command in cmds:
            proc = subprocess.run(
                command,
                cwd=cmddir,
                capture_output=True,
                check=False,
            )
            print(proc.stdout.decode())
            print(proc.stderr.decode(), file=sys.stderr)


@dataclass(kw_only=True)
class Source:
    name: str
    type: Literal['dir', 'git']
    source: _Source

    _source_types: ClassVar[dict[str, type[_Source]]] = {
        "dir": DirSource,
        "git": GitSource,
    }

    @classmethod
    def from_raw(cls, *, source: RawTypeDef, **kwargs) -> Self:
        return cls(source=cls._source_types[kwargs["type"]].from_raw(**source), **kwargs)


@dataclass(kw_only=True)
class Collection:
    name: str
    source: str
    filter: Filter

    @classmethod
    def from_raw(cls, *, filter: RawTypeDef, **kwargs) -> Self:
        return cls(filter=Filter.from_raw(**filter), **kwargs)

    def filter_names(self, sources_root: Path) -> Iterator[Path]:
        for name in self.filter.match(sources_root / self.source):
            yield sources_root / self.source / name

    def link_to_source(self, collections_root: Path, sources_root: Path):
        collection_path = collections_root / self.name
        collection_path.mkdir(parents=True, exist_ok=True)
        for target_path in self.filter_names(sources_root):
            link_path = collection_path / target_path.name
            try:
                link_path.unlink(missing_ok=True)
            except IsADirectoryError, OSError, PermissionError:
                continue
            link_path.symlink_to(
                target_path.relative_to(collection_path, walk_up=True),
                target_is_directory=target_path.is_dir()
            )


@dataclass(kw_only=True)
class Sources:
    directory: Path | str
    spec: list[Source]

    @classmethod
    def from_raw(cls, *, spec: list[RawTypeDef], directory: str | Path = COLORS_CONFIG_HOME / 'Sources') -> Self:
        return cls(
            spec=[Source.from_raw(**source) for source in spec],
            directory=XDG_CONFIG_HOME / Path(directory).expanduser()
        )

    @property
    def sources(self) -> list[Source]:
        return self.spec

    def retrieve_all(self, update: bool = True) -> None:
        directory = Path(self.directory)
        directory.mkdir(parents=True, exist_ok=True)
        for source in self.sources:
            dest = directory / source.name
            source.source.retrieve(dest, update=update)


@dataclass(kw_only=True)
class Collections:
    directory: Path
    spec: list[Collection]

    @classmethod
    def from_raw(cls, *, spec: list[RawTypeDef], directory: str | Path = COLORS_CONFIG_HOME / 'Collections') -> Self:
        return cls(
            spec=[Collection.from_raw(**collection) for collection in spec],
            directory=XDG_CONFIG_HOME / Path(directory).expanduser()
        )

    @property
    def collections(self) -> list[Collection]:
        return self.spec

    def link_all(self, sources_root: Path) -> None:
        for collection in self.collections:
            collection.link_to_source(self.directory, sources_root)


@dataclass(kw_only=True)
class Config:
    sources: Sources
    collections: Collections

    @classmethod
    def from_raw(cls, *, sources: RawTypeDef, collections: RawTypeDef) -> Self:
        return cls(sources=Sources.from_raw(**sources), collections=Collections.from_raw(**collections))


def parse_and_execute():
    doc = (__doc__ or "").strip()
    parser = ArgumentParser(
        description=textwrap.fill(doc[:doc.find("\n") % (len(doc) + 1)])
    )

    _ = parser.add_argument(
        "--no-update",
        dest="update",
        action="store_false",
        help="Do not update existing sources",
    )
    _ = parser.add_argument(
        "-c", "--config",
        type=lambda s: Path(s).expanduser(),
        nargs="?",
        default=COLORS_CONFIG_HOME / "config.toml",
        help=f"Path to config file (default: {COLORS_CONFIG_HOME / 'config.toml'})",
    )
    args = parser.parse_args()
    try: 
        with open(args.config, "rb") as istream:
            data = tomllib.load(istream)
        print(data)
    except (FileNotFoundError, OSError, PermissionError, TypeError, ValueError) as exc:
        print(exc, file=sys.stderr)
        return 1
    config = Config.from_raw(**data)
    config.sources.retrieve_all(update=bool(args.update))
    config.collections.link_all(sources_root=Path(config.sources.directory))
    return 0


def main():
    return parse_and_execute()


if __name__ == "__main__":
    sys.exit(main())
