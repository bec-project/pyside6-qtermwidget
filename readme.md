## PySide 6 Bindings for QTermWidget

Packages [QTermWidget](https://github.com/lxqt/qtermwidget), a terminal emulator for Qt, with PySide6-compatible
python bindings. This repository contains mainly CMake scripts and CI workflows to achieve this, and just pulls the
upstream QTermWidget source for building.

Installations from wheels are recommended - installation from sdist may not work properly without a specific build
environment which is for now not documented here, but relies at least on a Qt source installation, llvm/clang,
mesa/libGL, and others - see `.github/workflows/ci.yml` and `pyproject.toml.jinja` for details.

For notes on working with `cibuildwheel` with this package see `development.md`