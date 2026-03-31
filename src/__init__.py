from pathlib import Path

import PySide6
import shiboken6

_INSTALL_LOCATION = Path(__file__).parent

from .pyside6_qtermwidget import QTermWidget as _QTermWidget


class QTermWidget(_QTermWidget):
    def __init__(self, *args, **kwargs):
        self.addCustomColorSchemeDir(str(_INSTALL_LOCATION / "color_schemes"))
