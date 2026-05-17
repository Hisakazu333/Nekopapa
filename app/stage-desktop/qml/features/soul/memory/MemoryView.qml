import QtQuick
import QtQuick.Layouts

Item {
    MemoryStore { id: memoryStore }
    readonly property var s: memoryStore.state

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Search + filters
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: Theme.radiusMd
                color: Theme.color("surface.sunken")
                border.color: Theme.color("line.soft")
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    ShapeIcon {
                        pathData: Icons.search
                        size: 16
                        iconColor: Theme.color("text.tertiary")
                    }
                    Text {
                        text: "\u641C\u7D22\u8BB0\u5FC6..."
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        color: Theme.color("text.tertiary")
                    }
                    Item { Layout.fillWidth: true }
                }
            }

            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 18
                color: filterMouse.containsMouse ? Theme.alpha("accent.base", 0.08) : "transparent"
                ShapeIcon {
                    anchors.centerIn: parent
                    pathData: Icons.filter
                    size: 16
                    iconColor: Theme.color("text.secondary")
                }
                MouseArea {
                    id: filterMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        // Memory list
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            clip: true

            model: s.memories

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width : 0
                height: 64
                radius: Theme.radiusMd
                color: Theme.color("surface.base")
                border.color: Theme.color("line.soft")
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 4
                        Layout.fillHeight: true
                        radius: 2
                        color: Theme.color("accent.base")
                        opacity: 0.6
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            text: modelData.summary || "\u8BB0\u5FC6\u6458\u8981"
                            font.pixelSize: 14
                            font.family: Theme.fontUi
                            color: Theme.color("text.primary")
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        Text {
                            text: modelData.date || "2026-05-14"
                            font.pixelSize: 11
                            font.family: Theme.fontMono
                            color: Theme.color("text.tertiary")
                        }
                    }

                    ShapeIcon {
                        pathData: Icons.chevronRight
                        size: 16
                        iconColor: Theme.color("text.tertiary")
                    }
                }
            }
        }
    }
}
