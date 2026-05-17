import QtQuick
import QtQuick.Controls
import NNA.Core 1.0

Item {
    id: root

    property alias modelScale: avatarCanvas.modelScale
    property alias modelOffsetX: avatarCanvas.modelOffsetX
    property alias modelOffsetY: avatarCanvas.modelOffsetY
    property alias projectionWidthHint: avatarCanvas.projectionWidthHint
    property alias projectionHeightHint: avatarCanvas.projectionHeightHint

    // Live2D model canvas
    NNAAvatarCanvas {
        id: avatarCanvas
        anchors.fill: parent
        modelPath: appController.currentModelPath
        modelScale: 1.0
        modelOffsetX: 0.0
        modelOffsetY: 0.0
        projectionWidthHint: 0.0
        projectionHeightHint: 0.0
        visible: avatarCanvas.modelLoaded || appController.currentModelPath !== ""
        z: 2
    }

    // Touch area for model interaction
    MouseArea {
        anchors.fill: parent
        z: 1
        enabled: avatarCanvas.modelLoaded
        onClicked: function(mouse) {
            avatarCanvas.onTouchAt(mouse.x, mouse.y)
        }
    }

    // Placeholder when no model loaded
    Item {
        anchors.centerIn: parent
        width: 200
        height: 200
        z: 3
        visible: !avatarCanvas.modelLoaded && !appController.currentModelPath

        Rectangle {
            anchors.centerIn: parent
            width: 120
            height: 120
            radius: 60
            color: Theme.color("surface.sunken")

            Text {
                anchors.centerIn: parent
                text: "LN"
                font.pixelSize: 40
                font.family: Theme.fontUi
                font.weight: Font.Bold
                color: Theme.color("text.tertiary")
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            anchors.topMargin: 70
            text: "Live2D / VRM"
            font.pixelSize: 12
            font.family: Theme.fontUi
            color: Theme.color("text.tertiary")
        }
    }
}
