cmake_minimum_required(VERSION 3.21)
project(OpenNekoEngine VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Build options
option(NNA_BUILD_APP "Build Qt6 desktop application" ON)

add_subdirectory(engine)

if(NNA_BUILD_APP)
    add_subdirectory(app/stage-desktop)
endif()
