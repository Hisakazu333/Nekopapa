import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ScrollView {
    clip: true
    contentHeight: col.height + 40

    ColumnLayout {
        id: col
        width: parent.width
        spacing: 24

        SettingsGroup {
            title: "\u5173\u4E8E OpenNeko Engine"

            ColumnLayout {
                spacing: 16

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 64
                    height: 64
                    radius: 20
                    color: Theme.color("accent.soft")
                    Text {
                        anchors.centerIn: parent
                        text: "N"
                        font.pixelSize: 28
                        font.family: Theme.fontUi
                        font.weight: Font.Bold
                        color: Theme.color("accent.strong")
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 4
                    Text {
                        text: "OpenNeko Engine"
                        font.pixelSize: 20
                        font.family: Theme.fontUi
                        font.weight: Font.Bold
                        color: Theme.color("text.primary")
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: "v0.1.0 \u00B7 Nekonano-Aether"
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        color: Theme.color("text.secondary")
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                Text {
                    text: "\u5F00\u6E90\u8BB8\u53EF\u4E0E\u8054\u7CFB"
                    font.pixelSize: 13
                    font.family: Theme.fontUi
                    color: Theme.color("accent.base")
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
