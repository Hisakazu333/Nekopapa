import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: sidebar
    color: "#FFFAF5"

    property int currentIndex: 0
    property string accentColor: "#FF7AA2"
    property string characterName: "Lumia"
    signal navigated(int index)

    readonly property var navModel: [
        { icon: "\uD83C\uDFE0", label: "\u9996\u9875" },
        { icon: "\uD83D\uDC96", label: "\u7075\u9B42" },
        { icon: "\u26A1",       label: "\u80FD\u529B" },
        { icon: "\uD83C\uDF0D", label: "\u4E16\u754C" },
        { icon: "\u2699",       label: "\u8BBE\u7F6E" }
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 16
        anchors.bottomMargin: 12
        spacing: 6

        // Character avatar
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 48
            Layout.preferredHeight: 56

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 40
                height: 40
                radius: 20
                color: Qt.alpha(sidebar.accentColor, 0.12)

                Text {
                    anchors.centerIn: parent
                    text: "\uD83D\uDC31"
                    font.pixelSize: 20
                }
            }

            Text {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                text: sidebar.characterName
                font.pixelSize: 9
                font.family: "Nunito"
                font.weight: Font.Bold
                color: sidebar.accentColor
            }
        }

        Item { Layout.preferredHeight: 8 }

        // 5 nav items
        Repeater {
            model: sidebar.navModel

            delegate: Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 48
                Layout.preferredHeight: 52

                property bool isActive: sidebar.currentIndex === index
                property bool isHovered: navMouse.containsMouse

                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: isActive ? Qt.alpha(sidebar.accentColor, 0.12)
                         : isHovered ? Qt.alpha(sidebar.accentColor, 0.06)
                         : "transparent"
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutCubic } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 3

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.icon
                            font.pixelSize: 20
                            opacity: isActive ? 1.0 : 0.55
                            scale: isHovered ? 1.15 : 1.0
                            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.label
                            font.pixelSize: 9
                            font.family: "Nunito"
                            font.weight: isActive ? Font.Bold : Font.Normal
                            color: isActive ? sidebar.accentColor : "#888888"
                        }
                    }
                }

                MouseArea {
                    id: navMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sidebar.navigated(index)
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Desktop pet button
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 48
            Layout.preferredHeight: 44

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: desktopMouse.containsMouse ? Qt.alpha(sidebar.accentColor, 0.15) : "transparent"
                border.color: Qt.alpha(sidebar.accentColor, 0.25)
                border.width: 1
                Behavior on color { ColorAnimation { duration: 200 } }

                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "\uD83D\uDC3E"
                        font.pixelSize: 14
                        scale: desktopMouse.containsMouse ? 1.2 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "\u684C\u9762"
                        font.pixelSize: 8
                        font.family: "Nunito"
                        color: sidebar.accentColor
                    }
                }
            }

            MouseArea {
                id: desktopMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }
    }
}
