cmake_minimum_required(VERSION 3.16)
project(qtermwidget_python_bindings)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

include(ExternalProject)

find_package(Python3 COMPONENTS Interpreter Development.Module REQUIRED) # for macos:  Development.Embed

# Qt6 installation directory (pass via -DQT6_INSTALL_DIR=... or set QT6_INSTALL_DIR environment variable)
set(QT6_INSTALL_DIR "" CACHE PATH "Qt6 installation directory")
if(NOT QT6_INSTALL_DIR)
    # Check if QT6_INSTALL_DIR is set as an environment variable
    if(DEFINED ENV{QT6_INSTALL_DIR})
        set(QT6_INSTALL_DIR $ENV{QT6_INSTALL_DIR})
        message(STATUS "Using QT6_INSTALL_DIR from environment: ${QT6_INSTALL_DIR}")
    else()
        message(FATAL_ERROR "QT6_INSTALL_DIR must be set either as a CMake variable (-DQT6_INSTALL_DIR=...) or as an environment variable")
    endif()
endif()

# Add Qt6 to CMAKE_PREFIX_PATH so find_package can locate it
list(APPEND CMAKE_PREFIX_PATH "${QT6_INSTALL_DIR}")
find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets)

# Include component configurations
include(cmake/LXQTBuildTools.cmake)
include(cmake/QTermWidget.cmake)
include(cmake/ShibokenBindings.cmake)
