import QtQuick
import QtQuick.Layouts

Item {
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        Text {
            text: "IoT \u8BBE\u5907"
            font.pixelSize: 20
            font.family: Theme.fontUi
            font.weight: Font.Bold
            color: Theme.color("text.primary")
        }

        Flow {
            Layout.fillWidth: true
            spacing: 12

            Repeater {
                model: [
                    { name: "\u667A\u80FD\u706F\u5E26", connected: true, value: "\u6A59\u8272" },
                    { name: "\u98CE\u6247", connected: true, value: "60%" },
                    { name: "\u6E29\u5EA6\u8BA1", connected: false, value: "--" }
                ]
                delegate: Rectangle {
                    width: 160
                    height: 100
                    radius: Theme.radiusLg
                    color: Theme.color("surface.base")
                    border.color: Theme.color("line.soft")
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        RowLayout {
                            spacing: 6
                            Rectangle {
                                Layout.preferredWidth: 6
                                Layout.preferredHeight: 6
                                radius: 3
                                color: modelData.connected ? Theme.color("state.success") : Theme.color("text.tertiary")
                            }
                            Text {
                                text: modelData.name
                                font.pixelSize: 14
                                font.family: Theme.fontUi
                                font.weight: Font.Bold
                                color: Theme.color("text.primary")
                            }
                        }

                        Text {
                            text: modelData.value
                            font.pixelSize: 20
                            font.family: Theme.fontMono
                            font.weight: Font.Bold
                            color: Theme.color("accent.base")
                        }

                        Text {
                            text: modelData.connected ? "\u5DF2\u8FDE\u63A5" : "\u672A\u8FDE\u63A5"
                            font.pixelSize: 11
                            font.family: Theme.fontUi
                            color: Theme.color("text.tertiary")
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
