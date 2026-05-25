import QtQuick
import QtQuick.Effects
import QtQuick.Shapes

Item {
    id: root
    property string pathData: ""
    property real size: 24
    property color iconColor: Theme.color("text.primary")
    property real strokeWidth: 1.8
    property bool fill: false
    readonly property bool svgSource: pathData.indexOf("qrc:/") === 0
        || pathData.indexOf("file:/") === 0
        || pathData.indexOf(".svg") >= 0

    width: size
    height: size

    Shape {
        anchors.fill: parent
        visible: !root.svgSource

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

    Image {
        id: svgImage
        anchors.fill: parent
        visible: root.svgSource
        opacity: Theme.isDark ? 0.42 : 0.34
        source: root.svgSource ? root.pathData : ""
        sourceSize.width: Math.round(root.size * 2)
        sourceSize.height: Math.round(root.size * 2)
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        cache: true
        layer.enabled: true
    }

    MultiEffect {
        anchors.fill: parent
        visible: root.svgSource
        source: svgImage
        colorization: 1.0
        colorizationColor: root.iconColor
        antialiasing: true
    }
}
