import QtQuick
import QtQuick.Shapes

Shape {
    id: root
    property string pathData: ""
    property real size: 24
    property color iconColor: Theme.color("text.primary")
    property real strokeWidth: 1.8
    property bool fill: false

    width: size
    height: size

    ShapePath {
        strokeWidth: root.strokeWidth
        strokeColor: root.iconColor
        fillColor: root.fill ? root.iconColor : "transparent"
        capStyle: ShapePath.RoundCap
        joinStyle: ShapePath.RoundJoin
        scale: Qt.size(root.size / 24, root.size / 24)
        PathSvg { path: root.pathData }
    }
}
