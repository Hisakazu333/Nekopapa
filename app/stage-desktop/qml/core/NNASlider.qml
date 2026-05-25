import QtQuick
import QtQuick.Controls

Slider {
    id: root

    property int trackHeight: 4
    property int handleSize: 24
    property color accentColor: Theme.color("accent.strong")
    readonly property real trackLeft: leftPadding
    readonly property real trackWidth: availableWidth

    signal valueCommitted(real value)

    implicitHeight: 36
    stepSize: 0.01

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.availableWidth
        height: root.trackHeight
        radius: root.trackHeight / 2
        color: Theme.alpha("line.strong", Theme.isDark ? 0.46 : 0.64)

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: root.accentColor
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * root.availableWidth - width / 2
        y: root.topPadding + root.availableHeight / 2 - height / 2
        width: root.handleSize
        height: root.handleSize
        radius: root.handleSize / 2
        color: root.accentColor
        border.color: Theme.alpha("surface.base", Theme.isDark ? 0.78 : 0.96)
        border.width: 2
    }

    onMoved: root.valueCommitted(root.value)
}
