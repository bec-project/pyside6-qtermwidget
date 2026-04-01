import sys
import typing
from pathlib import Path

import PySide6
import shiboken6
from PySide6.QtWidgets import QWidget

_INSTALL_LOCATION = Path(__file__).parent

from .pyside6_qtermwidget import QTermWidget as _QTermWidget


class QTermWidget(_QTermWidget):
    @typing.overload
    def __init__(self, parent: QWidget | None = None) -> None: ...

    @typing.overload
    def __init__(self, startnow: int, parent: QWidget | None = None) -> None: ...

    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        self._post_init()

    def _post_init(self):
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
