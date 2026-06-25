import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string statusText: ""
    property bool modelReady: appController.currentModelPath !== ""
    property bool syncBusy: appController.syncBusy
    property bool loggedIn: appController.accountLoggedIn

    signal commandPaletteRequested()

    readonly property string clockText: Qt.formatTime(root.currentTime, "hh:mm")
    property date currentTime: new Date()

    height: 32
    color: Theme.color("apple.sidebar")

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Theme.color("apple.hairline")
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 12
        spacing: 10

        Text {
            text: root.clockText
            font.pixelSize: 11
            font.family: Theme.fontUi
            font.weight: Font.Medium
            color: Theme.color("apple.tertiary")
        }

        Rectangle {
            width: 1
            height: 12
            color: Theme.color("apple.hairline")
        }

        Text {
            Layout.fillWidth: true
            elide: Text.ElideRight
            text: root.statusLine()
            font.pixelSize: 11
            font.family: Theme.fontUi
            color: Theme.color("apple.secondary")
        }

        Rectangle {
            Layout.preferredWidth: commandChip.implicitWidth + 16
            Layout.preferredHeight: 22
            radius: 6
            color: commandMouse.containsMouse
                ? Theme.alpha("apple.selection", 0.85)
                : Theme.alpha("apple.selection", 0.55)
            border.color: Theme.color("apple.hairline")
            border.width: 1

            Row {
                id: commandChip
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "\u2318K"
                    font.pixelSize: 10
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("apple.secondary")
                }

                Text {
                    text: "\u641C\u7D22"
                    font.pixelSize: 10
                    font.family: Theme.fontUi
                    color: Theme.color("apple.tertiary")
                }
            }

            MouseArea {
                id: commandMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.commandPaletteRequested()
            }
        }
    }

    Timer {
        interval: 30000
        repeat: true
        running: true
        onTriggered: root.currentTime = new Date()
    }

    function statusLine() {
        var parts = []
        parts.push(root.modelReady ? "\u6A21\u578B\u5DF2\u52A0\u8F7D" : "\u6A21\u578B\u672A\u52A0\u8F7D")
        if (root.syncBusy)
            parts.push("\u540C\u6B65\u4E2D")
        else if (root.loggedIn)
            parts.push("\u540C\u6B65\u7A7A\u95F2")
        else
            parts.push("\u672C\u5730\u6A21\u5F0F")
        if (root.statusText !== "")
            parts.unshift(root.statusText)
        return parts.join(" \u00B7 ")
    }
}
