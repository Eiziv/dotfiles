# Standalone build of plasma-workspace's xembed-sni-proxy. Replaces the upstream
# CMakeLists.txt in that directory so it builds without the rest of
# plasma-workspace (or extra-cmake-modules, which upstream uses to find XCB and
# to generate debug.h).
cmake_minimum_required(VERSION 3.16)
project(xembedsniproxy LANGUAGES CXX)

set(WORKSPACE_VERSION "0" CACHE STRING "plasma-workspace version being built")

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui DBus)
find_package(KF6CoreAddons REQUIRED)
find_package(KF6Crash REQUIRED)
find_package(KF6DBusAddons REQUIRED)
find_package(KF6WindowSystem REQUIRED)
find_package(X11 REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(XCB REQUIRED IMPORTED_TARGET
    xcb xcb-xfixes xcb-damage xcb-composite xcb-randr xcb-shape xcb-shm xcb-util xcb-image
    xcb-icccm)

# Stand-ins for the headers the full plasma-workspace build generates.
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/config-workspace.h
    "#define WORKSPACE_VERSION_STRING \"${WORKSPACE_VERSION}\"\n")
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/debug.h
    "#pragma once\n#include <QLoggingCategory>\nQ_DECLARE_LOGGING_CATEGORY(SNIPROXY)\n")
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/debug.cpp
    "#include \"debug.h\"\nQ_LOGGING_CATEGORY(SNIPROXY, \"kde.xembedsniproxy\", QtInfoMsg)\n")

set(XEMBED_SNI_PROXY_SOURCES
    main.cpp
    fdoselectionmanager.cpp fdoselectionmanager.h
    snidbus.cpp snidbus.h
    sniproxy.cpp
    xtestsender.cpp xtestsender.h
    ${CMAKE_CURRENT_BINARY_DIR}/debug.cpp
)

qt_add_dbus_adaptor(XEMBED_SNI_PROXY_SOURCES org.kde.StatusNotifierItem.xml
                    sniproxy.h SNIProxy)
qt_add_dbus_interface(XEMBED_SNI_PROXY_SOURCES org.kde.StatusNotifierWatcher.xml
                      statusnotifierwatcher_interface)

add_executable(xembedsniproxy ${XEMBED_SNI_PROXY_SOURCES})

target_link_libraries(xembedsniproxy
    Qt6::Core
    Qt6::Gui
    Qt6::DBus
    KF6::DBusAddons
    KF6::WindowSystem
    KF6::CoreAddons
    KF6::Crash
    PkgConfig::XCB
    X11::Xtst
)

install(TARGETS xembedsniproxy RUNTIME DESTINATION bin)
