cmake_minimum_required(VERSION 3.21)

project(tst_example LANGUAGES CXX)

enable_testing()

find_package(Qt6 REQUIRED COMPONENTS QuickTest Qml)

add_executable(qmltestrunner
    tst_main.cpp
)

add_definitions(-DQUICK_TEST_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}")

target_link_libraries(qmltestrunner
    PRIVATE
    Qt6::QuickTest
    Qt6::Qml
)

add_test(NAME qmltests COMMAND qmltestrunner)
