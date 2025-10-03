cmake_minimum_required(VERSION 3.16)

project(HelloWorld)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)


qt_add_executable(HelloWorldApp
    main.cpp
)

qt_add_qml_module(HelloWorldApp
    URI HelloWorld
    VERSION 1.0
    QML_FILES
        Main.qml
)

target_link_libraries(HelloWorldApp
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS HelloWorldApp
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION "/usr/local/bin/"
)
