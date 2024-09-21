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
    print("'jedi' is not installed; falling back to 'readline'")
    try:
        import readline
    except ImportError:
        print("'readline' is not installed; completion is unavailable")
    else:
        readline.parse_and_bind("tab: complete")
else:
    try:
        jedi.utils.setup_readline(fuzzy=False)
    except TypeError:
        jedi.utils.setup_readline()
