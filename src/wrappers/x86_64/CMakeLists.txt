cmake_minimum_required(VERSION 3.0.0)
project(wineboxwrappers C CXX)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(
    SRC_BOX64
    box64.cpp
)
add_executable(box64wrapper ${SRC_BOX64})
target_link_libraries(box64wrapper -static)
install(TARGETS box64wrapper RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX})

set(
    SRC_WINE64
    wine64.cpp
)
add_executable(wine64wrapper ${SRC_WINE64})
target_link_libraries(wine64wrapper -static)
install(TARGETS wine64wrapper RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX})
