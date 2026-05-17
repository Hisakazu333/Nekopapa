import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: 52
    height: 180

    readonly property var actions: [
        { icon: "\uD83C\uDF54", tooltip: "\u5582\u98DF", action: "feed" },
        { icon: "\uD83D\uDCA7", tooltip: "\u7ED9\u6C34", action: "water" },
        { icon: "\u270B",     tooltip: "\u6478\u5934", action: "touch" },
        { icon: "\uD83D\uDCF8", tooltip: "\u62CD\u7167", action: "photo" }
    ]

    Column {
        anchors.centerIn: parent
        spacing: 12

        Repeater {
            model: root.actions

            delegate: Rectangle {
                width: 44
                height: 44
                radius: 22
                color: btnMouse.containsPressed ? Theme.color("accent.strong")
                     : btnMouse.containsMouse ? Theme.alpha("accent.base", 0.12)
                     : Theme.glass(0.7)
                border.color: Theme.alpha("line.soft", 0.5)
                border.width: 1

                scale: btnMouse.containsPressed ? 0.92 : 1.0
                Behavior on scale { NumberAnimation { duration: 100 } }
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    font.pixelSize: 18
                }

                ToolTip {
                    visible: btnMouse.containsMouse && !btnMouse.containsPressed
                    text: modelData.tooltip
                    font.pixelSize: 11
                    delay: 300
                }

                MouseArea {
                    id: btnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData.action === "feed") appController.feedPet("snack")
                        else if (modelData.action === "water") appController.giveWater()
                        else if (modelData.action === "touch") appController.touchPet(0.5, 0.5, 1.0)
                    }
                }
            }
        }
    }
}
