import platform
import sys
from pathlib import Path

import PySide6
import shiboken6

_INSTALL_LOCATION = Path(__file__).parent

from .pyside6_qtermwidget import QTermWidget as _QTermWidget


class QTermWidget(_QTermWidget):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.addCustomColorSchemeDir(str(_INSTALL_LOCATION / "color-schemes"))
        self.setCustomKeyBindingsDir(str(_INSTALL_LOCATION / "kb-layouts"))
        match sys.platform:
            case "linux":
                platform = "linux"
            case "darwin":
                platform = "macbook"
            case _:
                platform = "default"
        self.setKeyBindings(platform)
