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
                text: "\u4E16\u754C\u8FDE\u63A5"
                font.pixelSize: 24
                font.family: Theme.fontUi
                font.weight: Font.Bold
                color: Theme.color("text.primary")
            }

            Text {
                text: "Lumia \u611F\u77E5\u5230\u7684\u5468\u56F4\u4E16\u754C"
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
                    { label: "\u611F\u77E5", index: 0 },
                    { label: "IoT", index: 1 }
                ]
                delegate: Rectangle {
                    Layout.preferredWidth: tabText.implicitWidth + 24
                    Layout.preferredHeight: 36
                    color: worldTab.currentIndex === modelData.index
                        ? Theme.alpha("accent.base", 0.08)
                        : tabMouse.containsHover
                            ? Theme.alpha("text.primary", 0.03)
                            : "transparent"

                    Behavior on color { ColorAnimation { duration: 100 } }

                    Rectangle {
                        visible: worldTab.currentIndex === modelData.index
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
                        font.weight: worldTab.currentIndex === modelData.index ? Font.Bold : Font.Medium
                        color: worldTab.currentIndex === modelData.index
                            ? Theme.color("accent.base")
                            : Theme.color("text.secondary")
                    }

                    MouseArea {
                        id: tabMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: worldTab.currentIndex = modelData.index
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
                id: worldTab
                anchors.fill: parent
                anchors.margins: 16
                currentIndex: 0

                PerceptionView {}
                IoTView {}
            }
        }
    }
}
