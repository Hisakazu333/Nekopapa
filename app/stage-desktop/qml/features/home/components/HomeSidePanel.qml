import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    width: open ? 420 : 0
    height: parent ? parent.height : 0
    color: Theme.alpha("bg.canvas", 0.92)
    border.color: Theme.alpha("line.soft", 0.3)
    border.width: open ? 1 : 0
    clip: true

    property bool open: false

    Behavior on width { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: 250 } }

    function openPanel() {
        root.open = true
    }
    function closePanel() {
        root.open = false
    }
    function loadPanel(panelName) {
        currentPanel = panelName
    }

    property string currentPanel: ""

    // Backdrop blur overlay on main content
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        visible: root.open

        MouseArea {
            anchors.fill: parent
            onClicked: root.closePanel()
        }
    }

    // Panel content
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 0
        visible: root.open

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: panelTitle(currentPanel)
                font.pixelSize: 22
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
                    font.pixelSize: 14
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

        Item { Layout.preferredHeight: 20 }

        // Panel content loader
        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            sourceComponent: panelComponent(currentPanel)
        }
    }

    function panelTitle(name) {
        switch(name) {
            case "memory": return "\u2B50 \u8BB0\u5FC6\u661F\u56FE"
            case "status": return "\uD83D\uDCCA \u72B6\u6001\u4EEA\u8868\u76D8"
            case "character": return "\uD83D\uDC3E \u89D2\u8272\u7BA1\u7406"
            case "ability": return "\u26A1 \u80FD\u529B\u4E2D\u5FC3"
            case "world": return "\uD83C\uDF0D \u4E16\u754C\u8FDE\u63A5"
            case "settings": return "\u2699 \u8BBE\u7F6E"
            default: return "\uD83D\uDC31 OpenNeko"
        }
    }

    function panelComponent(name) {
        switch(name) {
            case "memory": return memoryComp
            case "status": return statusComp
            case "character": return characterComp
            case "ability": return abilityComp
            case "world": return worldComp
            case "settings": return settingsComp
            default: return defaultComp
        }
    }

    component PanelCard: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: content.implicitHeight + 32
        radius: Theme.radiusLg
        color: Theme.glass(0.6)
        border.color: Theme.alpha("line.soft", 0.3)
        border.width: 1

        property alias content: content

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8
        }
    }

    Component {
        id: memoryComp
        ColumnLayout {
            spacing: 12
            PanelCard {
                Text {
                    text: "\u8FD9\u91CC\u5C06\u5C55\u793A\u8BB0\u5FC6\u661F\u56FE..."
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }
        }
    }

    Component {
        id: statusComp
        ColumnLayout {
            spacing: 12
            PanelCard {
                Text {
                    text: "PAD: " + appController.pleasure.toFixed(2)
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    color: Theme.color("text.primary")
                }
                Text {
                    text: "\u9971\u98DF\u5EA6: " + Math.round(appController.satiety) + "%"
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    color: Theme.color("text.primary")
                }
                Text {
                    text: "\u6C34\u5206: " + Math.round(appController.hydration) + "%"
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    color: Theme.color("text.primary")
                }
                Text {
                    text: "\u6D3B\u529B: " + Math.round(appController.energy) + "%"
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    color: Theme.color("text.primary")
                }
            }
        }
    }

    Component {
        id: characterComp
        ColumnLayout {
            spacing: 12
            PanelCard {
                Text {
                    text: "\u89D2\u8272: " + appController.characterName
                    font.pixelSize: 16
                    font.family: Theme.fontUi
                    font.weight: Font.Bold
                    color: Theme.color("text.primary")
                }
                Text {
                    text: "\u5FC3\u60C5: " + appController.currentMood
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }
        }
    }

    Component {
        id: abilityComp
        ColumnLayout {
            spacing: 12
            PanelCard {
                Text {
                    text: "\u80FD\u529B\u4E2D\u5FC3\u9762\u677F..."
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }
        }
    }

    Component {
        id: worldComp
        ColumnLayout {
            spacing: 12
            PanelCard {
                Text {
                    text: "\u4E16\u754C\u8FDE\u63A5\u9762\u677F..."
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }
        }
    }

    Component {
        id: settingsComp
        ColumnLayout {
            spacing: 12
            PanelCard {
                Text {
                    text: "\u5916\u89C2\u4E3B\u9898"
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    font.weight: Font.Bold
                    color: Theme.color("text.primary")
                }
                RowLayout {
                    spacing: 8
                    Repeater {
                        model: ["\u6DE1\u6A31", "\u96FE\u7B3A", "\u591C\u6A31"]
                        delegate: Rectangle {
                            Layout.preferredWidth: 64
                            Layout.preferredHeight: 32
                            radius: 16
                            color: index === Theme.mode ? Theme.color("accent.strong") : Theme.glass(0.5)
                            border.color: index === Theme.mode ? "transparent" : Theme.alpha("line.soft", 0.4)
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 12
                                font.family: Theme.fontUi
                                color: index === Theme.mode ? Theme.color("text.onAccent") : Theme.color("text.primary")
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Theme.mode = index
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: defaultComp
        ColumnLayout {
            spacing: 12
            PanelCard {
                Text {
                    text: "\u9009\u62E9\u4E00\u4E2A\u529F\u80FD"
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }
        }
    }
}
