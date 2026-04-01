import logging
import os
import sys
from pathlib import Path
from types import SimpleNamespace

import PySide6
import shiboken6
from shibokensupport.signature.lib.pyi_generator import generate_pyi

pyside_path = Path(PySide6.__file__).parent
shiboken_path = Path(shiboken6.__file__).parent


def _symlink(target, link_name):
    try:
        # in a subsequent build on macos the symlink may already be there
        # or not, we don't care
        os.remove(link_name)
    except FileNotFoundError:
        ...
    os.symlink(target, link_name)


def main():
    # get install dir from script invocation
    os.chdir(sys.argv[1])
    # allow importing the module from there
    sys.path.insert(0, os.getcwd())
    # fake the env of the installed file for loading pyside libs
    _symlink(pyside_path, f"{os.getcwd()}/../PySide6")
    _symlink(shiboken_path, f"{os.getcwd()}/../shiboken6")
    print(os.getcwd())
    print(os.listdir())
    options = SimpleNamespace()
    options.quiet = False
    options.module = "pyside6_qtermwidget"
    options.outpath = sys.argv[1]
    module = options.module
    outpath = options.outpath
    logging.basicConfig(level=logging.DEBUG)
    logger = logging.getLogger("pyi_generator")
    options._pyside_call = True
    options.is_ci = False

    options.logger = logger
    generate_pyi(module, outpath, options=options)


if __name__ == "__main__":
    main()
