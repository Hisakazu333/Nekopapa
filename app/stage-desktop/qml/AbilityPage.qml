import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    property string accent: appController.accentColor
    property int currentTab: 0

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            color: "#FFFAF5"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 4

                Repeater {
                    model: [
                        { label: "\uD83D\uDEE0 ToolCall" },
                        { label: "\uD83C\uDFAE \u6E38\u620F\u4EE3\u7406" },
                        { label: "\uD83E\uDDEC \u8FDB\u5316\u4E0E\u8BAD\u7EC3" }
                    ]

                    delegate: Rectangle {
                        Layout.preferredHeight: 32
                        Layout.preferredWidth: tabText.implicitWidth + 24
                        radius: 16
                        color: root.currentTab === index ? Qt.alpha(root.accent, 0.12) : (tabMouse.containsMouse ? Qt.alpha(root.accent, 0.05) : "transparent")
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            id: tabText
                            anchors.centerIn: parent
                            text: modelData.label
                            font.pixelSize: 12
                            font.family: "Nunito"
                            font.weight: root.currentTab === index ? Font.Bold : Font.Normal
                            color: root.currentTab === index ? root.accent : "#888888"
                        }

                        MouseArea {
                            id: tabMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.currentTab = index
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "#E8E0D8"
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.currentTab

            ToolCallPage {}
            AgentPage {}
            EvolutionPage {}
        }
    }
}
