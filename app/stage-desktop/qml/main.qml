import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    id: root
    width: 1120
    height: 820
    minimumWidth: 680
    minimumHeight: 720
    visible: true
    title: "OpenNeko Engine"
    color: Theme.color("bg.canvas")

    NNAAppShell {
        id: shell
        anchors.fill: parent
    }

    DesktopCompanionWindow {
        id: companionWindow
        mainWindowRef: root
        shellRef: shell
        companionEnabled: appController.desktopCompanionEnabled
    }

    AgentWorkspaceWindow {
        id: agentWindow
        mainWindowRef: root
        companionWindowRef: companionWindow
        shellRef: shell
    }
}
