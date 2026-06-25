import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property bool checked: false
    signal toggled(bool checked)

    implicitWidth: 48
    implicitHeight: 28
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    radius: height / 2
    color: checked ? Theme.color("apple.action") : Theme.color("apple.selection")
    border.color: checked
        ? Theme.alpha("apple.action", 0.3)
        : Theme.color("apple.hairline")
    border.width: 1

    Behavior on color { ColorAnimation { duration: 140 } }

    Rectangle {
        id: knob
        width: 24
        height: 24
        radius: 12
        x: root.checked ? root.width - width - 2 : 2
        y: 2
        color: "#FFFFFF"
        border.color: Qt.rgba(0, 0, 0, 0.06)
        border.width: 1

        Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
