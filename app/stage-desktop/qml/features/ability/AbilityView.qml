import QtQuick
import QtQuick.Layouts

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "\u80FD\u529B\u4E2D\u5FC3"
                font.pixelSize: 24
                font.family: Theme.fontUi
                font.weight: Font.Bold
                color: Theme.color("text.primary")
            }

            Text {
                text: "Lumia \u53EF\u4EE5\u4F7F\u7528\u7684\u5404\u79CD\u80FD\u529B\u548C\u5DE5\u5177"
                font.pixelSize: 13
                font.family: Theme.fontUi
                color: Theme.color("text.tertiary")
            }

            Item { Layout.fillWidth: true }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: [
                    { label: "ToolCall", index: 0 },
                    { label: "\u6E38\u620F\u4EE3\u7406", index: 1 },
                    { label: "\u8FDB\u5316", index: 2 }
                ]
                delegate: Rectangle {
                    Layout.preferredWidth: tabText.implicitWidth + 24
                    Layout.preferredHeight: 36
                    color: abilityTab.currentIndex === modelData.index
                        ? Theme.alpha("accent.base", 0.08)
                        : tabMouse.containsHover
                            ? Theme.alpha("text.primary", 0.03)
                            : "transparent"

                    Behavior on color { ColorAnimation { duration: 100 } }

                    Rectangle {
                        visible: abilityTab.currentIndex === modelData.index
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
                        font.weight: abilityTab.currentIndex === modelData.index ? Font.Bold : Font.Medium
                        color: abilityTab.currentIndex === modelData.index
                            ? Theme.color("accent.base")
                            : Theme.color("text.secondary")
                    }

                    MouseArea {
                        id: tabMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: abilityTab.currentIndex = modelData.index
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
                id: abilityTab
                anchors.fill: parent
                anchors.margins: 16
                currentIndex: 0

                ToolCallView {}
                AgentView {}
                EvolutionView {}
            }
        }
    }
}
