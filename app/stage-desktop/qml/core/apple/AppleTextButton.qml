import QtQuick

Text {
    id: root

    property bool enabled: true
    signal triggered()

    font.pixelSize: 13
    font.family: Theme.fontUi
    font.weight: Font.Medium
    color: enabled
        ? (linkMouse.pressed ? Theme.color("apple.actionHover") : Theme.color("apple.action"))
        : Theme.color("apple.tertiary")
    opacity: enabled ? 1.0 : 0.45

    MouseArea {
        id: linkMouse
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.triggered()
    }
}
