#!/usr/bin/env python3
"""Initialize an interactive Python interpreter.

Modules and names below are pre-imported so common things are one word away in
the REPL. Kept deliberately to the ones actually reached for during quick
testing; niche/stdlib-internal modules (bisect, posix, pty, signal, ...) were
dropped -- import them on demand.
"""
# pylint: disable=unused-import
# ruff: noqa: F401

# Frequently reached-for standard-library modules.
import base64
import collections
import contextlib
import copy
import dataclasses
import datetime
import functools
import hashlib
import inspect
import io
import itertools
import json
import math
import operator
import os
import pathlib
import pprint
import random
import re
import shlex
import shutil
import statistics
import string
import subprocess
import sys
import tempfile
import textwrap
import time
import timeit
import typing
import uuid

# Handy names imported directly so they need no module prefix in the REPL.
from collections import ChainMap, Counter, defaultdict, deque, namedtuple
from dataclasses import dataclass, field
from datetime import date, datetime, timedelta
from functools import cache, lru_cache, partial, reduce
from itertools import (
    accumulate,
    chain,
    combinations,
    count,
    cycle,
    groupby,
    islice,
    permutations,
    product,
    repeat,
)
from pathlib import Path
from pprint import pprint as pp


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
