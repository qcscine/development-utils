__copyright__ = """This code is licensed under the 3-clause BSD license.
Copyright ETH Zurich, Laboratory of Physical Chemistry, Reiher Group.
See LICENSE.txt for details
"""

import os
import sys
import re
import subprocess as sp


def microarch(conanfile):
    """ Determine microarch of compiler and os (CPU chipset family or ISA) """
    cmdlist = None
    regex = None

    # Note that it doesn't matter if gcc or clang have different names for what
    # we call microarchitecture here. Any package ID is a hash convolution of
    # os, compiler, and then the microarch string. Collisions are so unlikely
    # they're impossible.

    if conanfile.settings.compiler == "gcc":
        cmdlist = ["gcc", "-march=native", "-Q", "--help=target"]
        regex = r"-march=\s+(?P<arch>[A-z0-9]+)"

    if conanfile.settings.compiler in ["clang", "apple-clang"]:
        cmdlist = ["clang", "-march=native", "-xc", "-", "-###"]
        regex = r"\"-target-cpu\"\\s+\"(?P<arch>[A-z0-9]+)\""

    if cmdlist is None:
        return None

    result = sp.run(cmdlist, stdout=sp.PIPE,
                    stderr=sp.STDOUT, universal_newlines=True)
    result.check_returncode()
    matcher = re.compile(regex)

    for match in matcher.finditer(result.stdout):
        return match.group("arch")

    for match in matcher.finditer(result.stderr):
        return match.group("arch")

    return None


def python_module_dir(pkg_folder):
    """ Returns the assumed path for a pip installed python package

        Using setuptools and pip to install to a site-packages folder will
        give a path that includes the interpreter major-minor version. We
        infer that path here dynamically.
    """
    python_dir = "python" + str(sys.version_info.major) + \
        "." + str(sys.version_info.minor)
    lib_dirs = ["lib", "lib64"]
    for lib in lib_dirs:
        folder = os.path.join(pkg_folder, lib, python_dir, "site-packages")
        if os.path.exists(folder):
            return folder

    raise RuntimeError("Python module folder not found!")
