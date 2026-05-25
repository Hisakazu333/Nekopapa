import QtQuick

Rectangle {
    id: root

    property color fillColor: Theme.color("surface.base")
    property color strokeColor: Theme.alpha("line.soft", Theme.isDark ? 0.70 : 0.96)
    property real panelRadius: 12

    radius: panelRadius
    color: fillColor
    border.color: strokeColor
    border.width: 1
    antialiasing: true
    clip: true
}
