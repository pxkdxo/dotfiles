#!/usr/bin/env python3
"""Provide defaults for YCM semantic analysis"""
# pylint: disable=invalid-name,missing-function-docstring

import os
import sys


def c(**kwargs):
    return {
        'flags': ['-x', 'c', '-Wall', '-Werror', '-Wextra', '-pedantic']
    }


def cpp(**kwargs):
    return {
        'flags': ['-x', 'c++', '-Wall', '-Werror', '-Wextra', '-pedantic']
    }


def python(**kwargs):
    if 'VIRTUAL_ENV' in os.environ:
        interpreter = os.path.join(os.getenv('VIRTUAL_ENV'), 'bin', 'python')
    else:
        interpreter = sys.executable
    return {
        'interpreter_path': interpreter
    }


SETTINGS = {
    'c': c,
    'cpp': cpp,
    'cxx': cpp,
    'py': python,
    'python': python,
}


def Settings(**kwgs):
    """Support semantic completion"""
    filename = kwgs.get('filename', '').casefold()
    language = kwgs.get('language', '').casefold()
    extension = os.path.splitext(filename)[-1][1:]
    settings = SETTINGS.get(language) or SETTINGS.get(extension)
    return settings(**kwgs) if callable(settings) else {}


def PythonSysPath(**kwgs):
    path = kwgs.get('sys_path') or sys.path
    if 'VIRTUAL_ENV' in os.environ:
        venv = os.getenv('VIRTUAL_ENV')
        vers = 'python{}.{}'.format(*sys.version_info)
        path.append(os.path.join(venv, 'lib', vers, 'site-packages'))
    return path
