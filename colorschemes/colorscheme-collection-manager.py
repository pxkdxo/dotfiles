#!/usr/bin/env python3
"""Manage colorscheme sources and collections"""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from glob import iglob
from fnmatch import fnmatch
import os
from pathlib import Path
import tomlib
import subprocess
import sys
from typing import Iterator, Literal


HERE = Path(__file__).parent.resolve()

XDG_DATA_HOME = Path(
    os.getenv("XDG_DATA_HOME") or
    os.path.expanduser('~/.local/share'))
XDG_CONFIG_HOME = Path(
    os.getenv("XDG_CONFIG_HOME") or
    os.path.expanduser('~/.config'))

COLORSCHEMES_DIR = XDG_CONFIG_HOME / "colorschemes"
COLORSCHEMES_CONFIG = COLORSCHEMES_DIR / "config.toml"


@dataclass
class Filter:
    type _Filetype = Literal["d","f"]

    pattern: str | list[str] = "*"
    exclude: str | list[str] = [] 
    filetype: _Filetype | list[_Filetype] = "d"
    hidden: bool = False
    search_path: str | list[str] = "."

    _filetype_test = {
        "d": os.path.isdir,
        "f": os.path.isfile,
    }

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
        search_paths = self.search_paths
        if not isinstance(search_paths, list):
            search_paths = [search_paths]

        for search_path in map(root.joinpath, search_paths):
            for pattern in patterns:
                for match in iglob(self.pattern, root=search_path, include_hidden=self.hidden):
                    for exclude in excludes:
                        if fnmatch(match, exclude):
                            break
                    else:
                        for filetype in filetypes:
                            if self._filetype_test[filetype](match):
                                yield match


class _Source(ABC):
    @abstractmethod
    def retrieve(self, dest: Path | str, update: bool = True) -> None:
        pass


@dataclass
class DirSource(_Source):
    path: Path | str
    def retrieve(self, dest: Path | str, update: bool = True) -> None:
        path = Path(self.path)
        dest = Path(dest).absolute()
        if dest.is_dir():
            dest = dest / path.name
        dest.symlink_to(path, target_is_directory=path.is_dir())


@dataclass
class GitSource(_Source):
    url: str
    ref: str | None = None
    def retrieve(self, dest: Path | str, update: bool = True) -> None:
        dest = Path(dest).absolute()
        if dest.is_dir() and update:
            cmds = [
                ["git", "stash", "push"],
                ["git", "checkout", self.ref],
                ["git", "pull", "--force"],
            ]
        else:
            cmds = [["git", "clone"]]
            if self.ref is not None:
                cmds[0].extend(
                    ["--branch", self.ref]
                )
            cmds[0].append(str(dest))
        for cmd in cmds:
            proc = subprocess.run(
                cmd,
                cwd=dest.parent(),
                capture_output=True,
                check=False,
            )
            print(proc.stdout)
            try:
                proc.check_returncode()
            except subprocess.CalledProcessError as exc:
                print(f"[* error *] -> {proc.stderr}", file=sys.stderr)
                raise RuntimeError(": ".join([
                    str(proc.args[0]),
                    "command exited with a non-zero status code",
                    str(exc.returncode)
                ]))


@dataclass
class Source:
    name: str
    type: Literal['dir', 'git']
    source: _Source


@dataclass
class Collection:
    name: str
    source: Source
    filter: Filter

    def filter_source(self):
        return list(self.filter.match(self.source))


@dataclass
class Sources:
    directory: Path | str
    sources: list[_Source]

    def retrieve_all(self, update: bool = True) -> None:
        directory = Path(self.directory)
        directory.mkdir(parents=True, exist_ok=True)
        for source in self.sources:
            dest = directory / source.name
            source.source.retrieve(dest, update=update)


@dataclass
class Collections:
    directory: Path
    collections: list[Collection]


@dataclass
class Config:
    sources: Source
    collections: Collections



def main():
    with open(COLORSCHEMES_CONFIG, "r") as istream:
        _ = Config(**tomlib.load(istream))


if __name__ == "__main__":
    sys.exit(main())
