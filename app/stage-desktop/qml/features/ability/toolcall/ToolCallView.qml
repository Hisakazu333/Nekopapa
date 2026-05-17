import QtQuick
import QtQuick.Layouts

Item {
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        Text {
            text: "ToolCall"
            font.pixelSize: 20
            font.family: Theme.fontUi
            font.weight: Font.Bold
            color: Theme.color("text.primary")
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            clip: true
            model: [
                { name: "Web Search", desc: "\u5728\u7F51\u4E0A\u641C\u7D22\u4FE1\u606F", enabled: true },
                { name: "File Read", desc: "\u8BFB\u53D6\u672C\u5730\u6587\u4EF6", enabled: false },
                { name: "System Info", desc: "\u83B7\u53D6\u7CFB\u7EDF\u4FE1\u606F", enabled: true }
            ]

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width : 0
                height: 60
                radius: Theme.radiusMd
                color: Theme.color("surface.base")
                border.color: Theme.color("line.soft")
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: 10
                        color: Theme.color("surface.sunken")
                        Text {
                            anchors.centerIn: parent
                            text: "\uD83D\uDEE0"
                            font.pixelSize: 16
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: modelData.name
                            font.pixelSize: 14
                            font.family: Theme.fontUi
                            font.weight: Font.Bold
                            color: Theme.color("text.primary")
                        }
                        Text {
                            text: modelData.desc
                            font.pixelSize: 12
                            font.family: Theme.fontUi
                            color: Theme.color("text.secondary")
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 24
                        radius: 12
                        color: modelData.enabled ? Theme.color("accent.strong") : Theme.color("surface.sunken")
                        border.color: modelData.enabled ? "transparent" : Theme.color("line.soft")
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: modelData.enabled ? "ON" : "OFF"
                            font.pixelSize: 10
                            font.family: Theme.fontMono
                            font.weight: Font.Bold
                            color: modelData.enabled ? Theme.color("text.onAccent") : Theme.color("text.tertiary")
                        }
                    }
                }
            }
        }
    }
}
