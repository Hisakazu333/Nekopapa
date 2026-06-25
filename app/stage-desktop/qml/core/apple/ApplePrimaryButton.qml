import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string text: ""
    property bool filled: true
    signal triggered()

    implicitWidth: label.implicitWidth + 28
    implicitHeight: 32
    radius: height / 2
    color: {
        if (!enabled)
            return Theme.alpha("apple.selection", 0.6)
        if (!filled)
            return "transparent"
        return buttonMouse.pressed ? Theme.color("apple.actionHover") : Theme.color("apple.action")
    }
    border.color: filled ? "transparent" : Theme.color("apple.action")
    border.width: filled ? 0 : 1
    opacity: enabled ? 1.0 : 0.45

    Behavior on color { ColorAnimation { duration: 100 } }
    scale: buttonMouse.pressed ? 0.98 : 1.0
    Behavior on scale { NumberAnimation { duration: 80 } }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: 13
        font.family: Theme.fontUi
        font.weight: Font.Medium
        color: filled ? "#FFFFFF" : Theme.color("apple.action")
    }

    MouseArea {
        id: buttonMouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.triggered()
    }
}
