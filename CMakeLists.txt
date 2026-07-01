cmake_minimum_required(VERSION 3.16)

project(QtWeather VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Graphs)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appQtWeather
    main.cpp
)

qt_add_qml_module(appQtWeather
    URI QtWeather
    QML_FILES
        Main.qml
        QML_FILES
        QML_FILES
        SOURCES
        QML_FILES WeatherIcons.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appQtWeather PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appQtWeather
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appQtWeather
    PRIVATE Qt6::Quick
    Qt6::Graphs
)

include(GNUInstallDirs)
install(TARGETS appQtWeather
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
