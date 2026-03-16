find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)

qt_policy(SET QTP0001 NEW)
qt_policy(SET QTP0004 NEW)

set(CMAKE_AUTOMOC ON)

set(DESKTOP_SOURCES
    src/main.cpp
    src/app_controller.h
    src/app_controller.cpp
)

qt_add_executable(OpenNekoEngine ${DESKTOP_SOURCES})

qt_add_qml_module(OpenNekoEngine
    URI OpenNeko
    VERSION 1.0
    QML_FILES
        qml/main.qml
        qml/NNASidebar.qml
        qml/HomePage.qml
        qml/SoulPage.qml
        qml/AbilityPage.qml
        qml/WorldPage.qml
        qml/ChatPage.qml
        qml/CharacterPage.qml
        qml/MemoryPage.qml
        qml/DreamPage.qml
        qml/StatusPage.qml
        qml/ToolCallPage.qml
        qml/AgentPage.qml
        qml/EvolutionPage.qml
        qml/PerceptionPage.qml
        qml/IoTPage.qml
        qml/SettingsPage.qml
        qml/components/PlaceholderPage.qml
        qml/components/NNAStatusCard.qml
)

# macOS 26+ SDK removed AGL.framework tbd stub
if(APPLE AND TARGET WrapOpenGL::WrapOpenGL)
    get_target_property(_wgl_libs WrapOpenGL::WrapOpenGL INTERFACE_LINK_LIBRARIES)
    if(_wgl_libs)
        list(FILTER _wgl_libs EXCLUDE REGEX "[Aa][Gg][Ll]")
        set_target_properties(WrapOpenGL::WrapOpenGL PROPERTIES INTERFACE_LINK_LIBRARIES "${_wgl_libs}")
    endif()
endif()

target_link_libraries(OpenNekoEngine PRIVATE
    openneko
    Qt6::Quick
    Qt6::QuickControls2
)
