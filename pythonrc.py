#!/usr/bin/env python3
"""Initialization script for the interactive Pythhon interpreter (v3.6+)
"""
# pylint: disable=invalid-name,unused-import
import abc
import asyncio
import base64
import bisect
import collections
import copy
import curses
import datetime
import fileinput
import functools
import glob
import hashlib
import json
import io
import itertools
import math
import mimetypes
import multiprocessing
import operator
import os
import pathlib
import pipes
import posix
import pprint
import pstats
import pty
import queue
import random
import re
import readline
import rlcompleter
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
import typing
import uuid
import xdg


# pylint: disable=no-member
class PSMeta(type):
    """Prompt string metaclass providing formatting via descriptors"""

    __lineno = 0
    __prompt = '>> '
    __time_style = os.getenv('TIME_STYLE', '%c').lstrip('+')

    @property
    def lineno(cls) -> int:
        """Get the current line number"""
        cls.__lineno += 1
        return cls.__lineno

    @lineno.setter
    def lineno(cls, value):
        """Set the current line number"""
        if isinstance(value, int):
            cls.__lineno = value
        else:
            raise ValueError("expected 'int' (got '{}')".format(type(value)))

    @property
    def prompt(cls) -> str:
        """Get the prompt string"""
        return cls.__prompt

    @prompt.setter
    def prompt(cls, value: str):
        """Set the prompt string"""
        if isinstance(value, str):
            cls.__prompt = value
        else:
            raise ValueError("expected 'str' (got '{}')".format(type(value)))

    @property
    def time_style(cls) -> str:
        """Get the template used to format dates and times as strings"""
        return cls.__time_style

    @time_style.setter
    def time_style(cls, value) -> str:
        """Get the template used to format dates and times as strings"""
        if isinstance(value, str):
            cls.__time_style = value
        else:
            raise ValueError("expected 'str' (got '{}')".format(type(value)))

    @property
    def user(cls) -> str:
        """Get the login name of the user executing this file"""
        return os.getlogin()

    @property
    def host(cls) -> str:
        """Get the hostname of the machine executing this file"""
        return socket.gethostname()

    @property
    def cwd(cls) -> str:
        """Get a path to the current directory as a string"""
        return os.getcwd()

    @property
    def tty(cls) -> str:
        """Get the name of the terminal attached on stdin"""
        return os.ttyname(sys.stdin.fileno())

    @property
    def version(cls) -> str:
        """Get the Python version info (i.e. MAJOR.MINOR.MICRO)"""
        return '.'.join(map(str, sys.version_info[:3]))

    @property
    def line(cls) -> str:
        """Get the prompt string prompt"""
        return '\u2500' * os.get_terminal_size().columns

    @property
    def clock(cls) -> str:
        """Format the current date & time as a string (see TIME_STYLE)"""
        return datetime.datetime.now().strftime(cls.time_style)

    def __str__(cls):
        """Format the prompt string"""
        return cls.prompt.format(
            **dict((key, getattr(cls, key)) for key in vars(type(cls))))


class PS(metaclass=PSMeta):
    """Primary prompt string metaclass"""
    __sister = None

    def __init__(self, sister, prompt='>>> ', **kwgs):
        """Initialize a prompt string instance"""
        self.sister = sister
        self.prompt = prompt

    @property
    def sister(self):
        """Get the corresponding sister class"""
        return self.__sister

    @sister.setter
    def sister(self, value):
        """Set the corresponding sister class"""
        if isinstance(value, type):
            self.__sister = value
        else:
            raise ValueError("expected 'type' (got '{}')".format(type(value)))

    @property
    def prompt(self) -> int:
        """Get the prompt"""
        return type(self).prompt

    @prompt.setter
    def prompt(self, value):
        """Set the current line number"""
        if isinstance(value, str):
            type(self).prompt = value
        else:
            raise ValueError("expected 'str' (got '{}')".format(type(value)))

    def __str__(self) -> str:
        """Render the primary prompt string"""
        return str(type(self))

    @staticmethod
    def new_pair(prompt1: str = '>>> ', prompt2: str = '..> ') -> type:
        """Get a primary prompt string class"""
        if not isinstance(prompt1, str):
            raise ValueError("expected 'str' (got '{}')".format(type(prompt1)))
        if not isinstance(prompt2, str):
            raise ValueError("expected 'str' (got '{}')".format(type(prompt2)))
        # PS1 = types.new_class('PS1', bases=(), kwds={'metaclass': PS1Meta})
        # PS2 = types.new_class('PS2', bases=(), kwds={'metaclass': PS2Meta})
        PS1 = types.new_class('PS1', bases=(PS,), kwds={})
        PS2 = types.new_class('PS2', bases=(PS,), kwds={})
        ps1 = PS1(PS2, prompt=prompt1)
        ps2 = PS2(PS1, prompt=prompt2)
        return (ps1, ps2)


sys.ps1, sys.ps2 = PS.new_pair(prompt1='{line}\n╘)> ',
                               prompt2='╘)> ')
