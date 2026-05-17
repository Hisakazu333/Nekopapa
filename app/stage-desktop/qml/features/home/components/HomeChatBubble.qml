import QtQuick
import QtQuick.Layouts

Item {
    id: root
    width: Math.min(textLayout.implicitWidth + 28, parent ? parent.width * 0.7 : 400)
    height: textLayout.implicitHeight + 20

    property bool fromUser: false
    property string text: ""
    property real bubbleScale: 1.0
    property real bubbleOpacity: 1.0

    anchors.right: fromUser ? parent.right : undefined
    anchors.left: fromUser ? undefined : parent.left

    // Avatar placeholder
    Rectangle {
        id: avatar
        width: 28
        height: 28
        radius: 14
        color: fromUser ? Theme.alpha("accent.base", 0.1) : Theme.color("surface.sunken")
        anchors.bottom: parent.bottom
        anchors.right: fromUser ? parent.right : undefined
        anchors.left: fromUser ? undefined : parent.left

        Text {
            anchors.centerIn: parent
            text: fromUser ? "U" : "LN"
            font.pixelSize: 10
            font.weight: Font.Bold
            color: fromUser ? Theme.color("accent.base") : Theme.color("text.tertiary")
        }
    }

    // Bubble
    Rectangle {
        id: bubble
        anchors.bottom: parent.bottom
        anchors.right: fromUser ? avatar.left : undefined
        anchors.left: fromUser ? undefined : avatar.right
        anchors.rightMargin: fromUser ? 8 : 0
        anchors.leftMargin: fromUser ? 0 : 8
        width: textLayout.implicitWidth + 20
        height: textLayout.implicitHeight + 14
        radius: Theme.radiusMd
        color: fromUser ? Theme.color("accent.base") : Theme.color("surface.sunken")

        ColumnLayout {
            id: textLayout
            anchors.centerIn: parent
            spacing: 0

            Text {
                text: root.text
                font.pixelSize: 13
                font.family: Theme.fontUi
                color: fromUser ? Theme.color("text.onAccent") : Theme.color("text.primary")
                wrapMode: Text.Wrap
                Layout.maximumWidth: 320
            }
        }

        scale: root.bubbleScale
        opacity: root.bubbleOpacity
    }
}
