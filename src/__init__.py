import PySide6
import shiboken6

from .pyside6_qtermwidget import QTermWidget

__all__ = ["QTermWidget"]

if __name__ == "__main__":
    import sys

    from PySide6.QtWidgets import QApplication

    app = QApplication(sys.argv)
    widget = QTermWidget()
    widget.show()
    sys.exit(app.exec())
