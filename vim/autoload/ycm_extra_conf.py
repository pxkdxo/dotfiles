#!/usr/bin/env python3
"""Provide defaults for YCM semantic analysis"""

import os
import sys


class LanguageSettings:

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
    def rust(**kwgs):
        return {
            'ls': {'rust': {'features': [], 'all_targets': False}}
        }
    
    @staticmethod
    def py(**kwgs):
        venv = os.getenv('VIRTUAL_ENV')
        return {
            'interpreter_path': sys.executable if venv is None else
            os.path.join(venv, 'bin', 'python')
        }


def PythonSysPath(**kwgs):
    path = kwgs.get('sys_path') or sys.path
    venv = os.getenv('VIRTUAL_ENV')
    vers = 'python{}.{}'.format(sys.version_info.major, sys.version_info.minor)
    if venv is not None:
        path.append(os.path.join(venv, 'lib', vers, 'site-packages'))
    return path


def Settings(**kwgs):
    """Facilitate semantic completion"""
    extension = os.path.splitext(kwgs.get('filename', ''))[-1].casefold()
    if hasattr(LanguageSettings, extension):
        return getattr(LanguageSettings, extension)(**kwgs)
    return {}
