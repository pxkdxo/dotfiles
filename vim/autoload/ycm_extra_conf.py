#!/usr/bin/env python3
"""Provide defaults for YCM semantic analysis"""

import os
import sys


class LanguageParams:

    @staticmethod
    def c(**kwgs):
        return {
            'flags': ['-x', 'c', '-Wall', '-Werror', '-Wextra', '-pedantic']
        }

    @staticmethod
    def cpp(**kwgs):
        return {
            'flags': ['-x', 'c++', '-Wall', '-Werror', '-Wextra', '-pedantic']
        }

    @staticmethod
    def python(**kwgs):
        if 'VIRTUAL_ENV' in os.environ:
            interp = os.path.join(os.getenv('VIRTUAL_ENV'), 'bin', 'python')
        else:
            interp = sys.executable
        return {
            'interpreter_path': interp
        }

    @staticmethod
    def rust(**kwgs):
        return {
            'ls': {
                'rust': {
                    'features': [],
                    'all_targets': False,
                    'wait_to_build': 1500
                }
            }
        }


LanguageParams.cxx = LanguageParams.cpp
LanguageParams.py = LanguageParams.python
LanguageParams.rs = LanguageParams.rust


def PythonSysPath(**kwgs):
    path = kwgs.get('sys_path') or sys.path
    if 'VIRTUAL_ENV' in os.environ:
        venv = os.getenv('VIRTUAL_ENV')
        vers = 'python{}.{}'.format(*sys.version_info)
        path.append(os.path.join(venv, 'lib', vers, 'site-packages'))
    return path


def Settings(**kwgs):
    """Support semantic completion"""
    filename = kwgs.get('filename', '').casefold()
    language = kwgs.get('language', '').casefold()
    ext = os.path.splitext(filename)[-1][1:]
    obj = getattr(LanguageParams, language, getattr(LanguageParams, ext, None))
    return obj(**kwgs) if callable(obj) else dict()
