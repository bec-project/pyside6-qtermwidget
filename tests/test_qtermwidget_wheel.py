def test_import_wheel():
    import pyside6_qtermwidget


def test_module_has_class():
    import pyside6_qtermwidget

    assert hasattr(pyside6_qtermwidget, "QTermWidget")
