#!/usr/bin/env python3
"""
Python startup file for interactive shell.
Auto-imports common modules and sets up useful utilities.
"""

import os
import sys
import atexit
import readline
import rlcompleter

# Enable tab completion
readline.parse_and_bind("tab: complete")

# History file
histfile = os.path.join(os.path.expanduser("~"), ".python_history")
try:
    readline.read_history_file(histfile)
    # Default history len is -1 (infinite), which may grow unruly
    readline.set_history_length(1000)
except FileNotFoundError:
    pass

atexit.register(readline.write_history_file, histfile)

# Auto-import common modules
def _import_common():
    """Import commonly used modules"""
    import builtins
    
    # Standard library
    modules = {
        'os': 'os',
        'sys': 'sys', 
        'json': 'json',
        'datetime': 'datetime',
        're': 're',
        'collections': 'collections',
        'itertools': 'itertools',
        'pathlib': 'pathlib',
    }
    
    # Data science modules (if available)
    optional_modules = {
        'np': 'numpy',
        'pd': 'pandas', 
        'plt': 'matplotlib.pyplot',
        'requests': 'requests',
    }
    
    imported = []
    
    # Import standard modules
    for alias, module in modules.items():
        try:
            builtins.__dict__[alias] = __import__(module)
            imported.append(f"{alias} ({module})")
        except ImportError:
            pass
    
    # Import optional modules
    for alias, module in optional_modules.items():
        try:
            if '.' in module:
                mod = __import__(module, fromlist=[''])
            else:
                mod = __import__(module)
            builtins.__dict__[alias] = mod
            imported.append(f"{alias} ({module})")
        except ImportError:
            pass
    
    if imported and os.getenv('PYTHONSTARTUP_QUIET') != '1':
        print(f"Auto-imported: {', '.join(imported)}")

# Only run in interactive mode
if hasattr(sys, 'ps1'):
    _import_common()

# Utility functions
def clear():
    """Clear the screen"""
    os.system('cls' if os.name == 'nt' else 'clear')

def pwd():
    """Print working directory"""
    print(os.getcwd())
    
def ls(path='.'):
    """List directory contents"""
    import os
    for item in sorted(os.listdir(path)):
        print(item)

# Add to builtins so they're available everywhere
import builtins
builtins.clear = clear
builtins.pwd = pwd  
builtins.ls = ls