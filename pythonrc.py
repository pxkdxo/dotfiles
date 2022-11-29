#!/usr/bin/env python3
"""Initialize an interactive Python interpreter."""
# pylint: disable=unused-import

import ast
import base64
import bisect
import collections
import copy
import datetime
import dis
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
import pipes
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
import socket
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
    import jedi
    import jedi.utils
except ImportError:
    print("'jedi' is not installed; falling back to 'readline'...")
    try:
        import readline
        readline.parse_and_bind("tab: complete")
    except ImportError:
        print("'readline' is not installed; completion is unavailable.")
else:
    try:
        jedi.utils.setup_readline(fuzzy=False)
    except TypeError:
        jedi.utils.setup_readline()

# try:
#     class PS:
#         """Provide a dynamic prompt allowing formatting via descriptors."""
# 
#         __old_prompt = ''
# 
#         def __init__(self, prompt):
#             """Initialize a prompt instance."""
#             self.prompt = prompt
#             self.lineno = 0
# 
#         def __str__(self):
#             """Format the prompt."""
#             self.lineno += 1
#             return self.prompt.format(
#                 **dict((key, getattr(self, key)) for key in dir(self)))
# 
#         def __getitem__(self, key):
#             """Evaluate an expression within the namespace of the instance."""
#             return self.eval(key)
# 
#         def eval(self, expression):
#             """Evaluate an expression within the namespace of the instance."""
#             # pylint: disable=eval-used,no-self-use
#             return eval(parser.compilest(parser.expr(expression))) or ""
# 
#         @property
#         def self(self):
#             """Get a reference to the invoking instance."""
#             return self
# 
#         @property
#         def prompt(self):
#             """Get the prompt format string."""
#             return self.__prompt
# 
#         @prompt.setter
#         def prompt(self, value):
#             """Set the prompt format string."""
#             try:
#                 if not isinstance(value, (str, unicode)):
#                     raise TypeError(
#                         "expected a string (got '{}')".format(type(value)))
#             except NameError:
#                 if not isinstance(value, str):
#                     raise TypeError(
#                         "expected a string (got '{}')".format(type(value)))
#             self.__old_prompt = getattr(self, '__prompt', '')
#             self.__prompt = value
# 
#         @property
#         def old_prompt(self):
#             """Get the previous prompt format string."""
#             return self.__old_prompt
# 
#         @property
#         def lineno(self):
#             """Get the current line number."""
#             return self.__lineno
# 
#         @lineno.setter
#         def lineno(self, value):
#             """Set the current line number."""
#             if not isinstance(value, int):
#                 raise TypeError(
#                     "expected an integer (got '{}')".format(type(value)))
#             self.__lineno = value
# 
#         @property
#         def user(self):
#             """Get the login name of the user."""
#             return os.getlogin()
# 
#         @property
#         def host(self):
#             """Get the hostname of the machine."""
#             return socket.gethostname()
# 
#         @property
#         def cwd(self):
#             """Get the current working directory of the process."""
#             return os.getcwd()
# 
#         @property
#         def tty(self):
#             """Get a path to terminal device attached on stdin."""
#             return os.ttyname(sys.stdin.fileno())
# 
#         @property
#         def time(self):
#             """Format the current date and time."""
#             return datetime.datetime.now().strftime(
#                 os.getenv('TIME_STYLE', '%c').lstrip('+'))
# 
#         @property
#         def version(self):
#             """Get Python version info (i.e. MAJOR.MINOR.MICRO)."""
#             return '.'.join(map(str, sys.version_info[:3]))
# 
#         if sys.version_info[0] < 3:
#             @property
#             def line(self):
#                 """Get a horizontal line spanning the width of the terminal."""
#                 cols = int(os.getenv('COLUMNS', '0'))
#                 return '{}\n'.format('=' * cols) if cols > 0 else ""
#         else:
#             @property
#             def line(self):
#                 """Get a horizontal line spanning the width of the terminal."""
#                 cols = os.get_terminal_size().columns
#                 return '{}\n'.format('\u2500' * cols) if cols > 0 else ""
# 
# except SyntaxError:
#     if sys.version_info.major >= 3 or sys.version_info.minor >= 6:
#         raise
# 
# 
# sys.ps1 = PS('{self[setattr(self, "prompt", ">> ")]}{line}>> ')
# sys.ps2 = PS('.> ')
