#!/usr/bin/env python3
"""Initialize an interactive Python interpreter."""
# pylint: disable=unused-import,unresolved-import
# ruff: noqa: F401

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
    from jedi.utils import setup_readline
except ImportError:
    print("* Failed to import 'jedi' - falling back to 'readline' *")
    # Fallback to the stdlib readline completer if it is installed.
    # Taken from http://docs.python.org/2/library/rlcompleter.html
    try:
        import readline
        import rlcompleter
    except ImportError:
        print("* Failed to import 'readline' - completion is unavailable *")
    else:
        readline.parse_and_bind("tab: complete")
else:
    setup_readline()

