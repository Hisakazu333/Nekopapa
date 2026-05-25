import QtQuick

Rectangle {
    id: root

    property bool checked: false
    signal toggled(bool checked)

    implicitWidth: 46
    implicitHeight: 26
    width: implicitWidth
    height: implicitHeight
    radius: height / 2
    color: checked ? Theme.color("accent.strong") : Theme.alpha("line.strong", Theme.isDark ? 0.52 : 0.42)
    border.color: checked ? Theme.alpha("accent.strong", 0.20) : Theme.alpha("line.strong", Theme.isDark ? 0.45 : 0.56)
    border.width: 1
    opacity: enabled ? 1.0 : 0.48

    Behavior on color { ColorAnimation { duration: 140 } }
    Behavior on border.color { ColorAnimation { duration: 140 } }

    Rectangle {
        id: knob
        width: 22
        height: 22
        radius: 11
        x: root.checked ? root.width - width - 2 : 2
        y: 2
        color: "#FFFFFF"
        border.color: Qt.rgba(0, 0, 0, 0.05)
        border.width: 1

        Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}
