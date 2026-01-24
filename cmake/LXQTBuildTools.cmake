# LXQT Build Tools Configuration
# This file handles building and installing lxqt-build-tools (required by qtermwidget)

# Set paths for lxqt-build-tools
set(EXT_LXQT_BUILD_TOOLS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/external/lxqt-build-tools")
set(LXQT_BUILD_TOOLS_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/lxqt-build-tools-build")

# Build lxqt-build-tools as an external project (required by qtermwidget)
ExternalProject_Add(lxqt_build_tools_external
    SOURCE_DIR ${EXT_LXQT_BUILD_TOOLS_DIR}
    BINARY_DIR ${LXQT_BUILD_TOOLS_BUILD_DIR}
    CMAKE_ARGS
        -DCMAKE_PREFIX_PATH=${QT6_INSTALL_DIR}
        -DCMAKE_INSTALL_PREFIX=/usr/local
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    BUILD_COMMAND ${CMAKE_COMMAND} --build ${LXQT_BUILD_TOOLS_BUILD_DIR}
    INSTALL_COMMAND ${CMAKE_COMMAND} --install ${LXQT_BUILD_TOOLS_BUILD_DIR}
)
