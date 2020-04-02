#!/usr/bin/env python3
"""Initialization script for the interactive Pythhon interpreter (v3.6+)
"""
# pylint: disable=unused-import
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
    """Prompt string metaclass primarily providing descriptors
    """
    try:
        curses.setupterm()
    except curses.error:
        __color = {
            'fg': [''] * 256,
            'bg': [''] * 256,
            'off': '',
        }
    else:
        __color = {
            'fg': [curses.tparm(curses.tigetstr('setaf'), n).decode()
                   for n in range(int(curses.tigetnum('colors')))],
            'bg': [curses.tparm(curses.tigetstr('setab'), n).decode()
                   for n in range(int(curses.tigetnum('colors')))],
            'off': curses.tigetstr('sgr0').decode(),
        }
    __prompt = '% '
    __time_style = os.getenv('TIME_STYLE', '%c').lstrip('+')

    @property
    def user(cls) -> str:
        """Get the login name of the user executing this file
        """
        return os.getlogin()

    @property
    def host(cls) -> str:
        """Get the hostname of the machine executing this file
        """
        return socket.gethostname()

    @property
    def cwd(cls) -> str:
        """Get a path to the current directory as a string
        """
        return os.getcwd()

    @property
    def tty(cls) -> str:
        """Get the name of the terminal attached on stdin
        """
        return os.ttyname(sys.stdin.fileno())

    @property
    def version(cls) -> str:
        """Get the Python version info (i.e. MAJOR.MINOR.MICRO)
        """
        return '.'.join(map(str, sys.version_info[:3]))

    @property
    def line(cls) -> str:
        """Get the prompt string prompt
        """
        return '\u2500' * os.get_terminal_size().columns

    @property
    def time_style(cls) -> str:
        """Get the template used to format dates and times as strings
        """
        return cls.__time_style

    @time_style.setter
    def time_style(cls, value) -> str:
        """Get the template used to format dates and times as strings
        """
        if isinstance(value, str):
            cls.__time_style = value
        else:
            raise ValueError("expected 'str' (got '{}')".format(type(value)))

    @property
    def clock(cls) -> str:
        """Format the current date & time as a string (see TIME_STYLE)
        """
        return datetime.datetime.now().strftime(cls.time_style)

    @property
    def color(cls) -> dict:
        """Use a mapping proxy to get a read-only view of available icons
        """
        return types.MappingProxyType(cls.__color)

    @property
    def prompt(cls) -> str:
        """Get the prompt string prompt
        """
        return cls.__prompt

    @prompt.setter
    def prompt(cls, value: str):
        """Set the prompt string prompt
        """
        if isinstance(value, str):
            cls.__prompt = value
        else:
            raise ValueError("expected 'str' (got '{}')".format(type(value)))

    def __str__(cls) -> str:
        """ Render the prompt string prompt
        """
        return cls.prompt.format(**dict(
            (key, getattr(cls, key)) for key in vars(type(cls))))


sys.ps1 = types.new_class('PS1', bases=(), kwds={'metaclass': PSMeta})
sys.ps2 = types.new_class('PS2', bases=(), kwds={'metaclass': PSMeta})
sys.ps1.prompt = ('{color[fg][2]}{line}{color[off]}\n'
                  '{color[fg][2]}╘|>{color[off]} ')
sys.ps2.prompt = ('{color[fg][5]}╘|>{color[off]} ')
