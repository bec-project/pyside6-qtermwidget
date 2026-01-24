from pathlib import Path

import PySide6
import shiboken6
import shiboken6_generator

shiboken_root = Path(shiboken6.__file__).parent
pyside_root = Path(PySide6.__file__).parent
shiboken6_generator_root = Path(shiboken6_generator.__file__).parent

print("Shiboken root:", shiboken_root)

shiboken_include = shiboken_root / "include"
print("Shiboken include:", shiboken_include)
print("Shiboken headers:")
for p in shiboken_include.glob("*"):
    print("  ", p.name)

print("\nShiboken6 Generator root:", shiboken6_generator_root)
print("Shiboken6 Generator include:", shiboken6_generator_root / "include")
print("Shiboken6 Generator headers:")
for p in (shiboken6_generator_root / "include").glob("*"):
    print("  ", p.name)

print("\nPySide root:", pyside_root)
print("PySide include:", pyside_root / "include")
print("PySide headers:")
for p in (pyside_root / "include").glob("*"):
    print("  ", p.name)
