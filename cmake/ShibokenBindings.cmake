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
message(STATUS "qtermwidget include: ${EXT_QTERMWIDGET_DIR}/lib")

# print 'ls' of the qtermwidget lib directory for debugging
execute_process(
    COMMAND ls -l ${QTERMWIDGET_DIR}/include/qtermwidget6
    OUTPUT_VARIABLE QTERMWIDGET_INCLUDE_CONTENTS
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
message(STATUS "Contents of qtermwidget include directory:\n${QTERMWIDGET_INCLUDE_CONTENTS}")

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
        ${SHIBOKEN_OUTPUT_DIR}/qtermwidget/qtermwidget_module_wrapper.cpp
        ${SHIBOKEN_OUTPUT_DIR}/qtermwidget/qtermwidget_wrapper.cpp
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
    ${SHIBOKEN_OUTPUT_DIR}/qtermwidget/qtermwidget_module_wrapper.cpp
    ${SHIBOKEN_OUTPUT_DIR}/qtermwidget/qtermwidget_wrapper.cpp
)

# Build the Python extension 
add_library(_qtermwidget MODULE ${SHIBOKEN_SOURCES})

# Ensure qtermwidget is built before the Python extension
add_dependencies(_qtermwidget qtermwidget_external)

# Includes 
target_include_directories(_qtermwidget PRIVATE
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


# Link libraries
if (APPLE)
    # Get the path to the Shiboken and PySide dylibs for macOS
    execute_process(
        COMMAND python3 -c "from pathlib import Path; import shiboken6; print(Path(shiboken6.__file__).parent)"
        OUTPUT_VARIABLE SHIBOKEN_DYLIB_PATH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Find the correct dylib for shiboken6 (e.g., libshiboken6.abi3.6.9.dylib)
    file(GLOB SHIBOKEN_DYLIBS "${SHIBOKEN_DYLIB_PATH}/libshiboken6*.dylib")
    list(GET SHIBOKEN_DYLIBS 0 SHIBOKEN_DYLIB_PATH)  # Take the first match

    message(STATUS "Using Shiboken dylib: ${SHIBOKEN_DYLIB_PATH}")

    # Get the path to the PySide dylib for macOS
    execute_process(
        COMMAND python3 -c "from pathlib import Path; import PySide6; print(Path(PySide6.__file__).parent)"
        OUTPUT_VARIABLE PYSIDE_DYLIB_PATH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    # Find the correct dylib for PySide6 (e.g., libpyside6.abi3.6.9.dylib)
    file(GLOB PYSIDE_DYLIBS "${PYSIDE_DYLIB_PATH}/libpyside6*.dylib")
    list(GET PYSIDE_DYLIBS 0 PYSIDE_DYLIB_PATH)  # Take the first match

    message(STATUS "Using PySide dylib: ${PYSIDE_DYLIB_PATH}")

    # Create imported target for qtermwidget library
    add_library(qtermwidget6 SHARED IMPORTED)
    set_target_properties(qtermwidget6 PROPERTIES
        IMPORTED_LOCATION ${QTERMWIDGET_LIB}
    )
    add_dependencies(qtermwidget6 qtermwidget_external)

    target_link_libraries(_qtermwidget
        Qt6::Core
        Qt6::Gui
        Qt6::Widgets
        qtermwidget6
        Python3::Python
        ${SHIBOKEN_DYLIB_PATH}
        ${PYSIDE_DYLIB_PATH}
    )
else ()
    # Create imported target for qtermwidget library
    add_library(qtermwidget6 SHARED IMPORTED)
    set_target_properties(qtermwidget6 PROPERTIES
        IMPORTED_LOCATION ${QTERMWIDGET_LIB}
    )
    add_dependencies(qtermwidget6 qtermwidget_external)

    target_link_libraries(_qtermwidget
        Qt6::Core
        Qt6::Gui
        Qt6::Widgets
        qtermwidget6
    )
endif()

# RPATH so it finds libqtermwidget6.so in the same folder
set_target_properties(_qtermwidget PROPERTIES
    PREFIX ""
    OUTPUT_NAME "_qtermwidget"
    INSTALL_RPATH "$ORIGIN"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/qtermwidget"
)

# Copy libqtermwidget6 library to qtermwidget package directory
add_custom_command(TARGET _qtermwidget POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<IF:$<PLATFORM_ID:Darwin>,${QTERMWIDGET_DIR}/lib/libqtermwidget6.dylib,${QTERMWIDGET_DIR}/lib/libqtermwidget6.so>
        ${CMAKE_CURRENT_SOURCE_DIR}/qtermwidget/$<IF:$<PLATFORM_ID:Darwin>,libqtermwidget6.dylib,libqtermwidget6.so>
    COMMENT "Copying libqtermwidget6 library to Python package directory"
)
