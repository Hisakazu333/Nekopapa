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
            title: "\u5916\u89C2"
            description: "\u9009\u62E9\u9002\u5408\u4F60\u7684\u89C6\u89C9\u98CE\u683C"

            Row {
                spacing: 8
                Repeater {
                    model: ["\u6DE1\u6A31", "\u96FE\u7B3C", "\u591C\u6A31"]
                    delegate: Rectangle {
                        width: 72
                        height: 36
                        radius: 18
                        color: settingsStore.state.themeMode === index
                            ? Theme.color("accent.strong")
                            : Theme.color("surface.base")
                        border.color: settingsStore.state.themeMode === index
                            ? "transparent"
                            : Theme.color("line.soft")
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 13
                            font.family: Theme.fontUi
                            font.weight: settingsStore.state.themeMode === index ? Font.Bold : Font.Normal
                            color: settingsStore.state.themeMode === index
                                ? Theme.color("text.onAccent")
                                : Theme.color("text.primary")
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: settingsStore.setTheme(index)
                        }
                    }
                }
            }
        }

        SettingsGroup {
            title: "\u542F\u52A8"
            SettingsRow {
                label: "\u5F00\u673A\u81EA\u542F"
                description: "\u7CFB\u7EDF\u542F\u52A8\u65F6\u81EA\u52A8\u8FD0\u884C OpenNeko"
                Switch {
                    checked: settingsStore.state.autoStart
                    onCheckedChanged: settingsStore.state.autoStart = checked
                }
            }
        }

        SettingsGroup {
            title: "\u684C\u9762"
            SettingsRow {
                label: "\u5E38\u9A7B\u60AC\u6D6E\u7A97"
                description: "\u624B\u52A8\u5F00\u542F\u540E\u624D\u5728\u684C\u9762\u4E0A\u663E\u793A\u89D2\u8272\u5C0F\u7A97"
                Switch {
                    checked: appController.desktopCompanionEnabled
                    onCheckedChanged: appController.desktopCompanionEnabled = checked
                }
            }
        }
    }
}
