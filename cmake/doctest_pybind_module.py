__copyright__ = """This code is licensed under the 3-clause BSD license.
Copyright Department of Chemistry and Applied Biosciences, Reiher Group.
See LICENSE.txt for details.
"""

"""

This script has a simple problem to solve: doctest.testmod(m) on a binary
Python module generated with pybind only tests classes and functions in the
base module, and does not traverse into submodules. The doctest functionality
is geared towards file and directory-level Python modules and submodules, not
binary modules.

This script collects all submodules recursively and executes doctest.testmod on
each of them, collecting the results and returning an error code if there are
failures.

"""

import doctest
import importlib
import inspect
import os
import sys


def direct_module_submodules(module):
    """ List the submodules of a module, non-recursively """
    return [v for v in module.__dict__.values() if inspect.ismodule(v)]


def module_submodules(module):
    """ List all submodules of a module, traversing recursively, and the module itself """
    return submodule_recursion(module, [module])


def submodule_recursion(module, known_modules):
    """ Recursion function for unique module search """
    direct_submodules = direct_module_submodules(module)
    for mod in direct_submodules:
        if mod not in known_modules:
            known_modules.append(mod)
            known_modules = submodule_recursion(mod, known_modules)
    return known_modules
    

if __name__ == "__main__":
    assert len(sys.argv) == 2
    module_name = sys.argv[1]
    sys.path.append(os.getcwd())
    module_to_test = importlib.import_module(module_name)

    # Use the top-level module dict as execution context for all modules
    # This allows access to all levels of the module for doctests, but requires
    # submodule member doctest references to be prefixed with the submodule
    globs = module_to_test.__dict__
    modules = module_submodules(module_to_test)

    results = [doctest.testmod(m, globs=globs) for m in modules]
    failures = sum(map(lambda tup: tup[0], results))
    sys.exit(failures > 0)
