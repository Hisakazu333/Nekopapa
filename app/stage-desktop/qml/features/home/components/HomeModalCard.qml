import QtQuick
import QtQuick.Layouts

Item {
    id: root
    visible: opacity > 0.01
    opacity: currentPanel !== "" ? 1 : 0

    property string currentPanel: ""

    Behavior on opacity { NumberAnimation { duration: 250 } }

    function loadPanel(name) {
        currentPanel = name
    }
    function closePanel() {
        currentPanel = ""
    }

    // Backdrop
    Rectangle {
        anchors.fill: parent
        color: Theme.alpha("overlay.scrim", 0.35)

        MouseArea {
            anchors.fill: parent
            onClicked: root.closePanel()
        }
    }

    // Card container
    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(900, parent.width * 0.85)
        height: Math.min(680, parent.height * 0.82)
        radius: Theme.radiusXl
        color: Theme.glass(0.88)
        border.color: Theme.alpha("line.soft", 0.4)
        border.width: 1

        scale: root.currentPanel !== "" ? 1.0 : 0.92
        opacity: root.currentPanel !== "" ? 1.0 : 0.0

        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 250 } }

        // Header
        RowLayout {
            id: cardHeader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 20
            anchors.leftMargin: 28
            anchors.rightMargin: 20
            height: 40
            spacing: 12

            Text {
                text: panelTitle(root.currentPanel)
                font.pixelSize: 20
                font.family: Theme.fontUi
                font.weight: Font.Bold
                color: Theme.color("text.primary")
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: 16
                color: closeMouse.containsMouse ? Theme.alpha("accent.base", 0.1) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "\u2715"
                    font.pixelSize: 16
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closePanel()
                }
            }
        }

        // Content
        Loader {
            id: contentLoader
            anchors.top: cardHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 20
            anchors.topMargin: 12
            sourceComponent: panelComponent(root.currentPanel)
        }
    }

    function panelTitle(name) {
        switch(name) {
            case "chat":    return "\uD83D\uDCAC \u804A\u5929"
            case "soul":    return "\u2764\uFE0F \u7075\u9B42\u7A7A\u95F4"
            case "ability": return "\u26A1 \u80FD\u529B\u4E2D\u5FC3"
            case "world":   return "\uD83C\uDF0D \u4E16\u754C\u8FDE\u63A5"
            case "settings":return "\u2699 \u8BBE\u7F6E"
            default:        return ""
        }
    }

    function panelComponent(name) {
        switch(name) {
            case "chat":    return chatComp
            case "soul":    return soulComp
            case "ability": return abilityComp
            case "world":   return worldComp
            case "settings":return settingsComp
            default:        return emptyComp
        }
    }

    component GlassCard: Rectangle {
        radius: Theme.radiusLg
        color: Theme.glass(0.5)
        border.color: Theme.alpha("line.soft", 0.25)
        border.width: 1
    }

    Component { id: emptyComp; Item {} }

    Component {
        id: chatComp
        ChatView {}
    }

    Component {
        id: soulComp
        ColumnLayout {
            spacing: 16
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                GlassCard {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    Text {
                        anchors.centerIn: parent
                        text: "\u8BB0\u5FC6"
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        color: Theme.color("text.primary")
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: soulStack.currentIndex = 0
                    }
                }
                GlassCard {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    Text {
                        anchors.centerIn: parent
                        text: "\u68A6\u5883"
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        color: Theme.color("text.primary")
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: soulStack.currentIndex = 1
                    }
                }
                GlassCard {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    Text {
                        anchors.centerIn: parent
                        text: "\u72B6\u6001"
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        color: Theme.color("text.primary")
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: soulStack.currentIndex = 2
                    }
                }
                GlassCard {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    Text {
                        anchors.centerIn: parent
                        text: "\u89D2\u8272"
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        color: Theme.color("text.primary")
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: soulStack.currentIndex = 3
                    }
                }
            }
            StackLayout {
                id: soulStack
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0
                MemoryView {}
                DreamView {}
                StatusView {}
                CharacterView {}
            }
        }
    }

    Component {
        id: abilityComp
        ColumnLayout {
            spacing: 16
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                GlassCard {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    Text {
                        anchors.centerIn: parent
                        text: "ToolCall"
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        color: Theme.color("text.primary")
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: abilityStack.currentIndex = 0
                    }
                }
                GlassCard {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    Text {
                        anchors.centerIn: parent
                        text: "\u6E38\u620F\u4EE3\u7406"
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        color: Theme.color("text.primary")
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: abilityStack.currentIndex = 1
                    }
                }
                GlassCard {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    Text {
                        anchors.centerIn: parent
                        text: "\u8FDB\u5316"
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        color: Theme.color("text.primary")
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: abilityStack.currentIndex = 2
                    }
                }
            }
            StackLayout {
                id: abilityStack
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0
                ToolCallView {}
                AgentView {}
                EvolutionView {}
            }
        }
    }

    Component {
        id: worldComp
        ColumnLayout {
            spacing: 16
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                GlassCard {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    Text {
                        anchors.centerIn: parent
                        text: "\u611F\u77E5"
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        color: Theme.color("text.primary")
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: worldStack.currentIndex = 0
                    }
                }
                GlassCard {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 40
                    Text {
                        anchors.centerIn: parent
                        text: "IoT"
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        color: Theme.color("text.primary")
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: worldStack.currentIndex = 1
                    }
                }
            }
            StackLayout {
                id: worldStack
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0
                PerceptionView {}
                IoTView {}
            }
        }
    }

    Component {
        id: settingsComp
        SettingsView {}
    }
}
