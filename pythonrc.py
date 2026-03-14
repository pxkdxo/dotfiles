#!/usr/bin/env python3
"""Initialize an interactive Python interpreter."""
# pylint: disable=unused-import,unresolved-import
# ruff: noqa: F401

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


def __load_readline_setup():
    try:
        _jedi = __import__("jedi.utils", fromlist=("jedi",))

        def _setup_readline() -> None:
            print("* > Setting up Jedi - long live the Republic.")
            return _jedi.setup_readline()

        return _setup_readline
    except (ImportError, ModuleNotFoundError):
        print("> * Failed to import 'jedi' - falling back to 'readline'...")
        try:
            _rl = __import__("readline")

            def _setup_readline() -> None:
                print("* > Setting up RL <Tab> completion.")
                return _rl.parse_and_bind("tab: complete")

            return _setup_readline
        except ImportError:
            print("* > Failed to import 'readline' - completion is not available.")

    return lambda: None


def __load_pretty_setup():
    try:
        _rich = __import__("rich.pretty")

        def __setup_pretty():
            print("$ > Loaded 'rich' - now output will be fancy")
            return _rich.pretty.install()

        return __setup_pretty
    except (ImportError, ModuleNotFoundError):
        print("* > Failed to import 'rich' - no fancy output this time.")

    return lambda: None


_ = __load_readline_setup()()
_ = __load_pretty_setup()()
