# Shiboken Python Bindings Configuration
# This file handles generation and building of Python bindings using Shiboken6

# Shiboken
execute_process(
    COMMAND python3 -c "from pathlib import Path; import shiboken6; print(Path(shiboken6.__file__).parent / 'include')"
    OUTPUT_VARIABLE SHIBOKEN_INCLUDE
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Shiboken generator
execute_process(
    COMMAND python3 -c "from pathlib import Path; import shiboken6_generator; print(Path(shiboken6_generator.__file__).parent / 'include')"
    OUTPUT_VARIABLE SHIBOKEN_GENERATOR_INCLUDE
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# PySide
execute_process(
    COMMAND python3 -c "from pathlib import Path; import PySide6; print(Path(PySide6.__file__).parent / 'include')"
    OUTPUT_VARIABLE PYSIDE_INCLUDE
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Python include 
execute_process(
    COMMAND python3 -c "import sysconfig; print(sysconfig.get_path('include'))"
    OUTPUT_VARIABLE PYTHON_INCLUDE
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

message(STATUS "Shiboken include: ${SHIBOKEN_INCLUDE}")
message(STATUS "Shiboken Generator include: ${SHIBOKEN_GENERATOR_INCLUDE}")
message(STATUS "PySide include: ${PYSIDE_INCLUDE}")
message(STATUS "Build output: ${CMAKE_BINARY_DIR}")
message(STATUS "qtermwidget include: ${EXT_QTERMWIDGET_DIR}/lib")

# Get PySide6 typesystem path
execute_process(
    COMMAND python3 -c "from pathlib import Path; import PySide6; print(Path(PySide6.__file__).parent / 'typesystems')"
    OUTPUT_VARIABLE PYSIDE_TYPESYSTEM
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Find shiboken6 executable
execute_process(
    COMMAND python3 -c "from pathlib import Path; import shiboken6_generator; print(Path(shiboken6_generator.__file__).parent / 'shiboken6')"
    OUTPUT_VARIABLE SHIBOKEN6_EXECUTABLE
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

message(STATUS "PySide typesystem: ${PYSIDE_TYPESYSTEM}")
message(STATUS "Shiboken6 executable: ${SHIBOKEN6_EXECUTABLE}")

# Build include paths for shiboken6
set(SHIBOKEN_INCLUDE_PATHS
    "/usr/lib64/llvm20/include"
    "${SYSTEM_CLANG_RESOURCE_DIR}/include"
    "${QTERMWIDGET_DIR}/include"
    "${QTERMWIDGET_DIR}/include/qtermwidget6"
    "${QT6_INSTALL_DIR}/include"
    "${QT6_INSTALL_DIR}/include/QtCore"
    "${QT6_INSTALL_DIR}/include/QtGui"
    "${QT6_INSTALL_DIR}/include/QtWidgets"
)

# On macOS, add framework paths
if(APPLE)
    list(APPEND SHIBOKEN_INCLUDE_PATHS
        "${QT6_INSTALL_DIR}/lib"
        "${QT6_INSTALL_DIR}/lib/QtCore.framework/Headers"
        "${QT6_INSTALL_DIR}/lib/QtGui.framework/Headers"
        "${QT6_INSTALL_DIR}/lib/QtWidgets.framework/Headers"
    )
endif()

# Convert list to colon-separated string
string(REPLACE ";" ":" SHIBOKEN_INCLUDE_PATHS_STR "${SHIBOKEN_INCLUDE_PATHS}")

# Shiboken flags
set(SHIBOKEN_FLAGS
    --generator-set=shiboken
    --enable-parent-ctor-heuristic
    --enable-pyside-extensions
    --enable-return-value-heuristic
    --use-isnull-as-nb_nonzero
    --avoid-protected-hack
)

# Add framework-include-paths on macOS
if(APPLE)
    list(APPEND SHIBOKEN_FLAGS --framework-include-paths=${QT6_INSTALL_DIR}/lib)
endif()

# Output directory for generated bindings
set(SHIBOKEN_OUTPUT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/build_bindings")

# Custom command to generate Python bindings with Shiboken6
add_custom_command(
    OUTPUT
    ${SHIBOKEN_OUTPUT_DIR}/pyside6_qtermwidget/pyside6_qtermwidget_module_wrapper.cpp
    ${SHIBOKEN_OUTPUT_DIR}/pyside6_qtermwidget/qtermwidget_wrapper.cpp
    COMMAND ${CMAKE_COMMAND} -E make_directory ${SHIBOKEN_OUTPUT_DIR}
    COMMAND ${SHIBOKEN6_EXECUTABLE}
    ${SHIBOKEN_FLAGS}
    --output-directory=${SHIBOKEN_OUTPUT_DIR}
    --include-paths=${SHIBOKEN_INCLUDE_PATHS_STR}
    --typesystem-paths=${PYSIDE_TYPESYSTEM}
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qtermwidget_bindings.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/typesystem_qtermwidget.xml
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/src
    DEPENDS
    qtermwidget_external
    ${CMAKE_CURRENT_SOURCE_DIR}/src/qtermwidget_bindings.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/typesystem_qtermwidget.xml
    COMMENT "Generating Python bindings with Shiboken6"
    VERBATIM
)

# Shiboken-generated sources
set(SHIBOKEN_SOURCES
    ${SHIBOKEN_OUTPUT_DIR}/pyside6_qtermwidget/pyside6_qtermwidget_module_wrapper.cpp
    ${SHIBOKEN_OUTPUT_DIR}/pyside6_qtermwidget/qtermwidget_wrapper.cpp
)

# Build the Python extension 
add_library(pyside6_qtermwidget MODULE ${SHIBOKEN_SOURCES})

# Ensure qtermwidget is built before the Python extension
add_dependencies(pyside6_qtermwidget qtermwidget_external)

# Includes 
target_include_directories(pyside6_qtermwidget PRIVATE
    ${SYSTEM_CLANG_RESOURCE_DIR}/include
    ${SHIBOKEN_INCLUDE}
    ${SHIBOKEN_GENERATOR_INCLUDE}
    ${PYSIDE_INCLUDE}
    ${PYSIDE_INCLUDE}/QtCore
    ${PYSIDE_INCLUDE}/QtGui
    ${PYSIDE_INCLUDE}/QtWidgets
    ${PYTHON_INCLUDE}
    ${SHIBOKEN_OUTPUT_DIR}/qtermwidget
    ${QTERMWIDGET_DIR}/include
    ${QTERMWIDGET_DIR}/include/qtermwidget6
)

# Get the path to the Shiboken and PySide libs
execute_process(
    COMMAND python3 -c "from pathlib import Path; import shiboken6; print(Path(shiboken6.__file__).parent)"
    OUTPUT_VARIABLE SHIBOKEN_PYTHON_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND python3 -c "from pathlib import Path; import PySide6; print(Path(PySide6.__file__).parent)"
    OUTPUT_VARIABLE PYSIDE_PYTHON_DIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

if(APPLE)
    set_target_properties(pyside6_qtermwidget PROPERTIES
        PREFIX ""
        OUTPUT_NAME "pyside6_qtermwidget"
        INSTALL_RPATH "@loader_path;@loader_path/lib;@loader_path/../PySide6/;@loader_path/../PySide6/Qt/lib;@loader_path/../shiboken6"
        INSTALL_NAME_DIR "@rpath"
    )
    set(MACOSX_RPATH TRUE)
    file(GLOB SHIBOKEN_DYLIBS
        "${SHIBOKEN_PYTHON_DIR}/libshiboken6*.dylib"
    )
    file(GLOB PYSIDE_LIBS
        "${PYSIDE_PYTHON_DIR}/libpyside6*.dylib"
    )
else()
    set_target_properties(pyside6_qtermwidget PROPERTIES
        PREFIX ""
        OUTPUT_NAME "pyside6_qtermwidget"
        INSTALL_RPATH "\$ORIGIN:\$ORIGIN/lib:\$ORIGIN/../PySide6/:\$ORIGIN/../PySide6/Qt/lib:\$ORIGIN/../shiboken6"
        INSTALL_NAME_DIR "\$ORIGIN"
    )
    file(GLOB SHIBOKEN_LIBS
        "${SHIBOKEN_PYTHON_DIR}/libshiboken6*.so*"
    )
    file(GLOB PYSIDE_LIBS
        "${PYSIDE_PYTHON_DIR}/libpyside6*.so*"
    )
endif()

message(STATUS "Using Shiboken lib: ${SHIBOKEN_LIBS}")
message(STATUS "Using PySide libs: ${PYSIDE_LIBS}")

# Create imported target for qtermwidget library
add_library(qtermwidget6 SHARED IMPORTED)
set_target_properties(qtermwidget6 PROPERTIES
    IMPORTED_LOCATION ${QTERMWIDGET_LIB}
    INSTALL_NAME_DIR ${LIBQTW_INSTALL_RPATH}
)
if(APPLE)
    set_target_properties(qtermwidget6 PROPERTIES
        IMPORTED_SONAME "@rpath/libqtermwidget6.2.dylib"
    )
endif()
add_dependencies(qtermwidget6 qtermwidget_external)

target_link_libraries(pyside6_qtermwidget
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    qtermwidget6
    Python3::Module
    ${PYSIDE_LIBS}
    ${SHIBOKEN_LIBS}
)

install(TARGETS pyside6_qtermwidget
    DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/pyside6_qtermwidget/
)
install(FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/__init__.py
    DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/pyside6_qtermwidget/
)
add_custom_command(TARGET pyside6_qtermwidget POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    $<IF:$<PLATFORM_ID:Darwin>,${QTERMWIDGET_DIR}/lib/libqtermwidget6.dylib,${QTERMWIDGET_DIR}/lib64/libqtermwidget6.so.2>
    ${CMAKE_CURRENT_SOURCE_DIR}/pyside6_qtermwidget/lib/$<IF:$<PLATFORM_ID:Darwin>,libqtermwidget6.2.dylib,libqtermwidget6.so.2>
    COMMENT "Copying libqtermwidget6 library to Python package directory"
)
install(CODE
    "execute_process(COMMAND shiboken6-genpyi ${CMAKE_CURRENT_SOURCE_DIR}/pyside6_qtermwidget/pyside6_qtermwidget.so)"
)

# add_custom_command(TARGET pyside6_qtermwidget POST_BUILD
#     COMMAND sleep 10000
#     COMMENT "wait for inspection"
# )
