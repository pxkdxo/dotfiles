#!/usr/bin/env python3
"""Initialize an interactive Python interpreter."""
# pylint: disable=unused-import,unresolved-import

import ast
import base64
import bisect
import builtins
import collections
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

    def __init__(self, ps=None, color=None, hooks=None, **psvars):
        if ps is not None:
            self.__ps = ps
        if color is None:
            self.__color = os.isatty(2)
        else:
            self.color = color
        if hooks is None:
            self.__hooks = []
        else:
            self.__hooks = hooks
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
        if not isinstance(value, dict):
            raise ValueError(
                f"``psvars'' must be of type ``{dict}''"
            )
        if not all(isinstance(key, str) for key in value):
            raise ValueError(
                f"``psvars'' must be of type ``{dict}'' "
                f"with keys of type ``{str}''"
            )
        self.__psvars = value.copy()

    @property
    def hooks(self) -> list:
        return self.__hooks.copy()

    @hooks.setter
    def hooks(self, value):
        if not isinstance(value, list):
            raise ValueError(
                f"``hooks'' must be of type ``{list}''"
            )
        if not all(map(callable, value)):
            raise ValueError(
                f"``hooks'' must be of type ``{list}'' "
                f"with only callable elements"
            )
        self.__hooks = value.copy()

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
        kwargs = {
            key: value(self) if callable(value) else value
            for key, value in self.__psvars.items()
        }
        return self.__ps.format(**kwargs)


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
