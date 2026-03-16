add_library(openneko SHARED
    src/engine_stub.cpp
)

target_include_directories(openneko PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

target_compile_definitions(openneko PRIVATE NNA_BUILDING_LIB)

set_target_properties(openneko PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION 0
    OUTPUT_NAME openneko
)
