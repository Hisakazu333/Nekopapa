import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Window {
    id: root

    property var shellRef: null
    property var mainWindowRef: null
    property var companionWindowRef: null

    width: 368
    height: 774
    visible: mainWindowRef && mainWindowRef.visible && shellRef && shellRef.currentPage === 4
    color: "transparent"
    flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    modality: Qt.NonModal

    x: companionWindowRef && companionWindowRef.visible
        ? companionWindowRef.x - width - 28
        : (mainWindowRef ? mainWindowRef.x + mainWindowRef.width + 24 : 980)
    y: mainWindowRef ? mainWindowRef.y + 110 : 120

    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    Rectangle {
        anchors.fill: parent
        radius: 34
        color: Theme.alpha("surface.base", Theme.isDark ? 0.96 : 0.95)
        border.color: Theme.alpha("line.soft", 0.80)
        border.width: 1
    }

    Rectangle {
        width: 56
        height: 6
        radius: 3
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 14
        color: Theme.alpha("line.strong", 0.46)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        anchors.topMargin: 28
        spacing: 14

        RowLayout {
            Layout.fillWidth: true

            Text {
                Layout.fillWidth: true
                text: "Agent \u5DE5\u4F5C\u7A7A\u95F4"
                font.pixelSize: 24
                font.family: Theme.fontUi
                font.weight: Font.Black
                color: Theme.color("text.primary")
            }

            StatusPill {
                labelText: "\u8FD0\u884C\u4E2D"
                accentColor: Theme.color("state.success")
            }

            Rectangle {
                width: 32
                height: 32
                radius: 16
                color: Theme.alpha("surface.sunken", Theme.isDark ? 0.56 : 0.78)
                border.color: Theme.alpha("line.soft", 0.70)
                border.width: 1

                ShapeIcon {
                    anchors.centerIn: parent
                    pathData: Icons.close
                    size: 14
                    iconColor: Theme.color("text.secondary")
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (shellRef) shellRef.currentPage = 0
                }
            }
        }

        ToolCard {
            Layout.fillWidth: true
            titleText: "\u5F53\u524D\u4EFB\u52A1"

            Rectangle {
                width: parent.width
                height: 238
                radius: 22
                color: Theme.alpha("surface.base", Theme.isDark ? 0.74 : 0.92)
                border.color: Theme.alpha("line.soft", 0.70)
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Text {
                        text: "\u67E5\u8BE2\u5929\u6C14"
                        font.pixelSize: 18
                        font.family: Theme.fontUi
                        font.weight: Font.Bold
                        color: Theme.color("text.primary")
                    }

                    Text {
                        text: "\u4E0A\u6D77\u5E02 \u6D66\u4E1C\u65B0\u533A"
                        font.pixelSize: 12
                        font.family: Theme.fontUi
                        color: Theme.color("text.tertiary")
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 94
                        radius: 20
                        color: Theme.alpha("surface.sunken", Theme.isDark ? 0.56 : 0.76)

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 10

                            Rectangle {
                                Layout.preferredWidth: 42
                                Layout.preferredHeight: 42
                                radius: 21
                                color: Theme.alpha("surface.base", Theme.isDark ? 0.18 : 0.74)

                                Text {
                                    anchors.centerIn: parent
                                    text: "\u2601"
                                    font.pixelSize: 24
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: "23\u00B0C  \u591A\u4E91"
                                    font.pixelSize: 18
                                    font.family: Theme.fontUi
                                    font.weight: Font.Bold
                                    color: Theme.color("text.primary")
                                }

                                Text {
                                    text: "\u6E7F\u5EA6 68%  |  \u4E1C\u5357\u98CE 2\u7EA7"
                                    font.pixelSize: 11
                                    font.family: Theme.fontUi
                                    color: Theme.color("text.tertiary")
                                }

                                Text {
                                    text: "\u6570\u636E\u6765\u6E90\uFF1A\u548C\u98CE\u5929\u6C14"
                                    font.pixelSize: 11
                                    font.family: Theme.fontUi
                                    color: Theme.color("text.tertiary")
                                }
                            }
                        }
                    }

                    Text {
                        text: "\u9884\u8BA1\u8017\u65F6\uFF1A5-8 \u79D2"
                        font.pixelSize: 11
                        font.family: Theme.fontUi
                        color: Theme.color("text.tertiary")
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Item { Layout.fillWidth: true }

                        ActionButton {
                            labelText: "\u53D6\u6D88"
                            filled: false
                        }

                        ActionButton {
                            labelText: "\u6279\u51C6\u6267\u884C"
                            filled: true
                        }
                    }
                }
            }
        }

        ToolCard {
            Layout.fillWidth: true
            titleText: "\u5F85\u5BA1\u6279 (2)"

            ApprovalRow {
                titleText: "\u521B\u5EFA\u65E5\u7A0B"
                subtitleText: "\u660E\u5929 10:00 \u56E2\u961F\u4F1A\u8BAE"
            }

            ApprovalRow {
                titleText: "\u641C\u7D22\u8D44\u6599"
                subtitleText: "OpenNeko Engine \u8BBE\u8BA1\u89C4\u8303"
            }
        }

        ToolCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            titleText: "\u6267\u884C\u65E5\u5FD7"

            LogRow {
                timeText: "21:28"
                titleText: "\u67E5\u8BE2\u5929\u6C14 (\u5DF2\u5B8C\u6210)"
                subtitleText: "\u4E0A\u6D77 23\u00B0C \u591A\u4E91"
            }

            LogRow {
                timeText: "21:25"
                titleText: "\u6253\u5F00\u5DF2\u5F52\u6863\u5907\u5FD8 (\u5DF2\u5B8C\u6210)"
                subtitleText: "\u5DF2\u8BFB\u53D6\u56E2\u961F\u5907\u5FD8\u5F55"
            }

            LogRow {
                timeText: "21:22"
                titleText: "\u641C\u7D22\u8D44\u6599 (\u5DF2\u5B8C\u6210)"
                subtitleText: "\u627E\u5230 12 \u6761\u76F8\u5173\u7ED3\u679C"
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "\u67E5\u770B\u5168\u90E8\u65E5\u5FD7"
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.secondary")
                }

                Item { Layout.fillWidth: true }

                ShapeIcon {
                    pathData: Icons.chevronRight
                    size: 14
                    iconColor: Theme.color("text.tertiary")
                }
            }
        }
    }

    component ToolCard: Rectangle {
        property string titleText: ""
        default property alias content: contentColumn.data

        implicitHeight: contentColumn.implicitHeight + 34
        radius: 24
        color: Theme.alpha("surface.raised", Theme.isDark ? 0.84 : 0.94)
        border.color: Theme.alpha("line.soft", 0.74)
        border.width: 1

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: parent.parent.titleText
                font.pixelSize: 12
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: Theme.color("text.tertiary")
            }
        }
    }

    component StatusPill: Rectangle {
        property string labelText: ""
        property color accentColor: Theme.color("accent.base")

        implicitWidth: pillRow.implicitWidth + 22
        implicitHeight: 32
        radius: 16
        color: Theme.alpha("surface.base", Theme.isDark ? 0.78 : 0.92)
        border.color: Theme.alpha("line.soft", 0.70)
        border.width: 1

        Row {
            id: pillRow
            anchors.centerIn: parent
            spacing: 7

            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: parent.parent.accentColor
            }

            Text {
                text: parent.parent.labelText
                font.pixelSize: 11
                font.family: Theme.fontUi
                color: Theme.color("text.secondary")
            }
        }
    }

    component ActionButton: Rectangle {
        property string labelText: ""
        property bool filled: false

        implicitWidth: buttonText.implicitWidth + 26
        implicitHeight: 38
        radius: 19
        color: filled ? Theme.color("state.success") : Theme.alpha("surface.sunken", Theme.isDark ? 0.58 : 0.80)
        border.color: filled ? Theme.alpha("state.success", 0.12) : Theme.alpha("line.soft", 0.70)
        border.width: 1

        Text {
            id: buttonText
            anchors.centerIn: parent
            text: parent.labelText
            font.pixelSize: 12
            font.family: Theme.fontUi
            font.weight: Font.DemiBold
            color: parent.filled ? Theme.color("text.onAccent") : Theme.color("text.secondary")
        }
    }

    component ApprovalRow: Rectangle {
        property string titleText: ""
        property string subtitleText: ""

        Layout.fillWidth: true
        Layout.preferredHeight: 74
        radius: 18
        color: Theme.alpha("surface.base", Theme.isDark ? 0.76 : 0.90)
        border.color: Theme.alpha("line.soft", 0.68)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                radius: 15
                color: Theme.alpha("surface.sunken", Theme.isDark ? 0.54 : 0.76)

                ShapeIcon {
                    anchors.centerIn: parent
                    pathData: Icons.filter
                    size: 14
                    iconColor: Theme.color("text.secondary")
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: parent.parent.parent.titleText
                    font.pixelSize: 13
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.primary")
                }

                Text {
                    text: parent.parent.parent.subtitleText
                    font.pixelSize: 11
                    font.family: Theme.fontUi
                    color: Theme.color("text.tertiary")
                }
            }

            ActionButton {
                labelText: "\u62D2\u7EDD"
                filled: false
            }

            ActionButton {
                labelText: "\u6279\u51C6"
                filled: true
            }
        }
    }

    component LogRow: RowLayout {
        id: logRow
        property string timeText: ""
        property string titleText: ""
        property string subtitleText: ""

        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 8
            Layout.preferredHeight: 8
            radius: 4
            color: Theme.color("state.success")
        }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: logRow.timeText + "    " + logRow.titleText
                    font.pixelSize: 11
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }

                Text {
                    text: logRow.subtitleText
                    font.pixelSize: 11
                    font.family: Theme.fontUi
                    color: Theme.color("text.tertiary")
                }
            }
    }
}
