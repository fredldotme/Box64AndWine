cmake_minimum_required(VERSION 3.0.0)
project(wineboxwrappers C CXX)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -marm")

set(
    SRC_BOX86
    box86.cpp
)
add_executable(box86wrapper ${SRC_BOX86})
target_link_libraries(box86wrapper -static)
install(TARGETS box86wrapper RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX})

set(
    SRC_WINE
    wine.cpp
)
add_executable(winewrapper ${SRC_WINE})
target_link_libraries(winewrapper -static)
install(TARGETS winewrapper RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX})
