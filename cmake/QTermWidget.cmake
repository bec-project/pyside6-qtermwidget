# QTermWidget Configuration
# This file handles building qtermwidget as an external project

# Set paths for qtermwidget
set(EXT_QTERMWIDGET_DIR "${CMAKE_CURRENT_SOURCE_DIR}/external/qtermwidget")
set(QTERMWIDGET_SOURCE_DIR "${EXT_QTERMWIDGET_DIR}")
set(QTERMWIDGET_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/qtermwidget-build")
set(QTERMWIDGET_DIR "${QTERMWIDGET_BUILD_DIR}/install")

# Determine library extension based on platform
if(APPLE)
    set(QTERMWIDGET_LIB "${QTERMWIDGET_DIR}/lib/libqtermwidget6.dylib")
    set(LIBQTW_INSTALL_RPATH "@rpath")
else()
    set(LIBQTW_INSTALL_RPATH "\$ORIGIN/lib")
    set(QTERMWIDGET_LIB "${QTERMWIDGET_DIR}/lib64/libqtermwidget6.so")
endif()



# Build qtermwidget as an external project
externalproject_add(qtermwidget_external
    DEPENDS lxqt_build_tools_external
    SOURCE_DIR ${QTERMWIDGET_SOURCE_DIR}
    BINARY_DIR ${QTERMWIDGET_BUILD_DIR}
    CMAKE_ARGS
    -DCMAKE_PREFIX_PATH=${QT6_INSTALL_DIR}
    -DCMAKE_INSTALL_PREFIX=${QTERMWIDGET_DIR}
    -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    BUILD_COMMAND ${CMAKE_COMMAND} --build ${QTERMWIDGET_BUILD_DIR}
    INSTALL_COMMAND ${CMAKE_COMMAND} --install ${QTERMWIDGET_BUILD_DIR}
    BUILD_BYPRODUCTS ${QTERMWIDGET_LIB}
)

if(APPLE)
    externalproject_add_step(qtermwidget_external fix_install_name
        DEPENDEES install
        COMMAND install_name_tool
        -id @rpath/libqtermwidget6.2.dylib
        ${QTERMWIDGET_DIR}/lib/libqtermwidget6.2.dylib
    )
endif()
