#!/usr/bin/env python3
"""Initialize an interactive Python interpreter."""
# pylint: disable=unused-import,unresolved-import

import ast
import base64
import bisect
import builtins
import collections
import collections.abc
import copy
import datetime
import fileinput
import functools
import glob
import hashlib
import json
import importlib
import inspect
import io
import itertools
import locale
import math
import mimetypes
import operator
import os
try:
    import pathlib
except ImportError:
    pass
import posix
import pprint
import pstats
import pty
try:
    import queue
except ImportError:
    pass
import random
import re
import shlex
import shutil
import signal
import string
import subprocess
import sys
import tempfile
import time
import timeit
import tty
import types
try:
    import typing
except ImportError:
    pass
import uuid

try:
    from jedi.utils import setup_readline # ty: ignore unresolved-import
except ImportError:
    print("> unable to import 'jedi' - falling back to 'readline'")
    # Fallback to the stdlib readline completer if it is installed.
    # Taken from http://docs.python.org/2/library/rlcompleter.html
    try:
        import readline
        import rlcompleter
    except ImportError:
        print("> unable to import 'readline' - completion is unavailable")
    else:
        readline.parse_and_bind("tab: complete")
else:
    setup_readline()


class Prompt:
    __ps: str = '>>> '
    __color: bool
    __psvars: dict
    __hooks: list

    def __init__(self, ps=None, color=None, hooks=None, **psvars):
        if ps is not None:
            self.ps = ps
        if color is not None:
            self.color = color
        else:
            self.__color = os.isatty(2)
        if hooks is not None:
            self.hooks = hooks
        else:
            self.__hooks = []
        self.__psvars = psvars

    @property
    def ps(self) -> str:
        return self.__ps

    @ps.setter
    def ps(self, value):
        if not isinstance(value, str):
            raise ValueError(
                f"``ps'' must be of type ``{str}''"
            )
        self.__ps = value

    @property
    def color(self) -> bool:
        return self.__color

    @color.setter
    def color(self, value):
        if not isinstance(value, bool):
            raise ValueError(
                f"``color'' must be of type ``{bool}''"
            )
        self.__color = value

    @property
    def psvars(self) -> dict:
        return self.__psvars.copy()

    @psvars.setter
    def psvars(self, value):
        if not isinstance(value, collections.abc.Mapping):
            raise ValueError(
                f"``psvars'' must be a mapping"
            )
        psvars = dict(value)
        if not all(isinstance(key, str) for key in psvars):
            raise ValueError(
                f"``psvars'' must be a mapping with keys of type ``{str}''"
            )
        self.__psvars = psvars

    @property
    def hooks(self) -> list:
        return self.__hooks.copy()

    @hooks.setter
    def hooks(self, value):
        if not isinstance(value, collections.abc.Iterable):
            raise ValueError(
                f"``hooks'' must be an iterable"
            )
        hooks = list(value)
        if not all(map(callable, hooks)):
            raise ValueError(
                f"``hooks'' must be an iterable of callable elements"
            )
        self.__hooks = hooks

    def __repr__(self) -> str:
        kwargs = {
            'ps': self.__ps,
            'color': self.__color,
            'hooks': list(map(repr, self.__hooks)),
            **self.__psvars
        }
        return (
            f'''{type(self).__name__}({", ".join(
                f"{key}={repr(value)}" for key, value in kwargs.items()
            )})'''
        )

    def __str__(self) -> str:
        for hook in self.__hooks:
            hook(self)
        return self.__ps.format(**{
            key: value(self) if callable(value) else value
            for key, value in self.__psvars.items()
        })


sys.ps1 = Prompt(
    ps='{reset}{black}[{reset}{dim}{ts}{reset}{black}]{reset} {bold}{red}>{reset} ',
    hooks=[],
    ts=lambda p: datetime.datetime.now().astimezone().strftime('%a %H:%M'),
    reset='\033[0m',
    bold='\033[1m',
    dim='\033[2m',
    italic='\033[3m',
    black='\033[30m',
    white='\033[37m',
    red='\033[31m',
    green='\033[32m',
    yellow='\033[33m',
    blue='\033[34m',
    magenta='\033[35m',
    cyan='\033[36m',
)

sys.ps2 = Prompt(
    ps='{reset}{dim}.{fill}.{reset} {bold}{red}>{reset} ',
    hooks=[],
    ts=lambda p: datetime.datetime.now().astimezone().strftime('%a %H:%M'),
    fill=lambda p: '.' * len(p.psvars['ts'](p)),
    reset='\033[0m',
    bold='\033[1m',
    dim='\033[2m',
    italic='\033[3m',
    black='\033[30m',
    white='\033[37m',
    red='\033[31m',
    green='\033[32m',
    yellow='\033[33m',
    blue='\033[34m',
    magenta='\033[35m',
    cyan='\033[36m',
)


try:
    from pydantic.alias_generators import to_snake
except ImportError:
    # Implementation from pydantic~=2.11.0
    def to_snake(camel: str) -> str:
        """Convert a PascalCase, camelCase, or kebab-case string to snake_case"""
        # Handle the sequence of uppercase letters followed by a lowercase letter
        snake = re.sub(r'([A-Z]+)([A-Z][a-z])', lambda m: f'{m.group(1)}_{m.group(2)}', camel)
        # Insert an underscore between a lowercase letter and an uppercase letter
        snake = re.sub(r'([a-z])([A-Z])', lambda m: f'{m.group(1)}_{m.group(2)}', snake)
        # Insert an underscore between a digit and an uppercase letter
        snake = re.sub(r'([0-9])([A-Z])', lambda m: f'{m.group(1)}_{m.group(2)}', snake)
        # Insert an underscore between a lowercase letter and a digit
        snake = re.sub(r'([a-z])([0-9])', lambda m: f'{m.group(1)}_{m.group(2)}', snake)
        # Replace hyphens with underscores to handle kebab-case
        return snake.replace('-', '_').lower()


def kwargs_to_annotated_attributes(**kwargs):
    return dict(map(lambda k, v: (to_snake(k), type(v).__name__), *zip(*kwargs.items())))

def attributes_fmt_annotations(**attrs):
    return [f"{name}: {annotation}" for (name, annotation) in attrs.items()]
