import QtQuick
import QtQuick.Layouts

Item {
    id: root

    SoulStore { id: soulStore }
    readonly property var s: soulStore.state

    Rectangle {
        anchors.fill: parent
        color: Theme.color("bg.canvas")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "\u7075\u9B42\u7A7A\u95F4"
                font.pixelSize: 24
                font.family: Theme.fontUi
                font.weight: Font.Bold
                color: Theme.color("text.primary")
            }

            Text {
                text: "\u8BB0\u5F55\u7740\u4E0E Lumia \u7684\u6BCF\u4E00\u6BB5\u56DE\u5FC6"
                font.pixelSize: 13
                font.family: Theme.fontUi
                color: Theme.color("text.tertiary")
            }

            Item { Layout.fillWidth: true }
        }

        // Tab bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: [
                    { label: "\u8BB0\u5FC6", index: 0 },
                    { label: "\u68A6\u5883", index: 1 },
                    { label: "\u72B6\u6001", index: 2 },
                    { label: "\u89D2\u8272", index: 3 }
                ]
                delegate: Rectangle {
                    Layout.preferredWidth: tabText.implicitWidth + 24
                    Layout.preferredHeight: 36
                    color: s.currentTab === modelData.index
                        ? Theme.alpha("accent.base", 0.08)
                        : tabMouse.containsHover
                            ? Theme.alpha("text.primary", 0.03)
                            : "transparent"

                    Behavior on color { ColorAnimation { duration: 100 } }

                    // Bottom indicator
                    Rectangle {
                        visible: s.currentTab === modelData.index
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - 16
                        height: 2
                        radius: 1
                        color: Theme.color("accent.base")
                    }

                    Text {
                        id: tabText
                        anchors.centerIn: parent
                        text: modelData.label
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        font.weight: s.currentTab === modelData.index ? Font.Bold : Font.Medium
                        color: s.currentTab === modelData.index
                            ? Theme.color("accent.base")
                            : Theme.color("text.secondary")
                    }

                    MouseArea {
                        id: tabMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: soulStore.setTab(modelData.index)
                    }
                }
            }

            Item { Layout.fillWidth: true }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.color("surface.base")
            border.color: Theme.color("line.soft")
            border.width: 1
            radius: Theme.radiusMd

            StackLayout {
                anchors.fill: parent
                anchors.margins: 16
                currentIndex: s.currentTab

                MemoryView {}
                DreamView {}
                StatusView {}
                CharacterView {}
            }
        }
    }
}
