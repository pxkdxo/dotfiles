#!/usr/bin/env python3

def Settings(**kwargs):
    """Facilitate semantic completion of C code"""
    return {'flags': [ '-x', '-pedantic', '-Wall', '-Werror', '-Wextra' ]}
