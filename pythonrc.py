"""Initialization script for the interactive Pythhon interpreter (v3.6+)"""
# pylint: disable=invalid-name,unused-import

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
import parser
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
import readline
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
    class PS(dict):
        """Prompt class providing formatting via descriptors"""
        # pylint: disable=no-member

        def __init__(self, prompt, *args, **kwargs):
            """Initialize a prompt"""
            super(PS, self).__init__(*args, **kwargs)
            self.prompt = prompt
            self.lineno = 0
            self.timefmt = os.getenv('TIME_STYLE', '%c').lstrip('+')

        def __getitem__(self, item):
            if item in self:
                return super().__getitem__(self)
            return eval(parser.compilest(parser.expr(item))) or ""

        @property
        def self(self):
            """Get a reference to the object from which this is called"""
            return self

        @property
        def lineno(self):
            """Get the current line number"""
            return self.__lineno

        @lineno.setter
        def lineno(self, value):
            """Set the current line number"""
            if not isinstance(value, int):
                raise TypeError(
                    "expected an integer (got '{}')".format(type(value)))
            self.__lineno = value

        @property
        def prompt(self):
            """Get the prompt string"""
            return self.__prompt

        @prompt.setter
        def prompt(self, value):
            """Set the prompt string"""
            try:
                if not isinstance(value, (str, unicode)):
                    raise TypeError(
                        "expected a string (got '{}')".format(type(value)))
            except NameError:
                if not isinstance(value, str):
                    raise TypeError(
                        "expected a string (got '{}')".format(type(value)))
            self.__prompt = value

        @property
        def timefmt(self):
            """Get the template used to format dates and times as strings"""
            return self.__timefmt

        @timefmt.setter
        def timefmt(self, value):
            """Get the template used to format dates and times as strings"""
            try:
                if not isinstance(value, (str, unicode)):
                    raise TypeError(
                        "expected a string (got '{}')".format(type(value)))
            except NameError:
                if not isinstance(value, (str)):
                    raise TypeError(
                        "expected a string (got '{}')".format(type(value)))
            self.__timefmt = value

        @property
        def user(self):
            """Get the login name of the user executing this file"""
            return os.getlogin()

        @property
        def host(self):
            """Get the hostname of the machine executing this file"""
            return socket.gethostname()

        @property
        def cwd(self):
            """Get a path to the current directory as a string"""
            return os.getcwd()

        @property
        def tty(self):
            """Get the name of the terminal attached on stdin"""
            return os.ttyname(sys.stdin.fileno())

        @property
        def version(self):
            """Get the Python version info (i.e. MAJOR.MINOR.MICRO)"""
            return '.'.join(map(str, sys.version_info[:3]))

        if hasattr(os, 'get_terminal_size'):
            @property
            def line(self):
                """Get the prompt string prompt"""
                return u'\u2500' * os.get_terminal_size().columns
        else:
            @property
            def line(self):
                """Get the prompt string prompt"""
                return u'\u2500' * os.getenv('COLUMNS', 0)

        @property
        def clock(self):
            """Format the current date & time as a string (see TIME_STYLE)"""
            return datetime.datetime.now().strftime(self.timefmt)

        def __str__(self):
            """Format the prompt string"""
            self.lineno += 1
            return self.prompt.format(
                **dict((key, getattr(self, key)) for key in vars(type(self))))

except SyntaxError:
    if sys.version_info.major >= 3 or sys.version_info.minor >= 6:
        raise


sys.ps1 = PS('{self[setattr(self, "prompt", "> ")]}{clock}\n> ')
sys.ps2 = PS('+ ')
