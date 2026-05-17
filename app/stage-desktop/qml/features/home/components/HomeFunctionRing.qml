import QtQuick

Item {
    id: root
    width: 52
    height: 52

    signal panelRequested(string panelName)

    function closeRing() {
        ringOpen = false
    }

    property bool ringOpen: false

    readonly property var menuItems: [
        { name: "memory",    label: "\u8BB0\u5FC6", icon: "\u2B50",    angle: -60 },
        { name: "status",    label: "\u72B6\u6001", icon: "\uD83D\uDCCA",  angle: -30 },
        { name: "character", label: "\u89D2\u8272", icon: "\uD83D\uDC3E",  angle: 0 },
        { name: "ability",   label: "\u80FD\u529B", icon: "\u26A1",      angle: 30 },
        { name: "world",     label: "\u4E16\u754C", icon: "\uD83C\uDF0D",  angle: 60 }
    ]

    Rectangle {
        id: triggerBtn
        anchors.centerIn: parent
        width: 52
        height: 52
        radius: 26
        color: ringOpen ? Theme.color("accent.strong") : Theme.glass(0.8)
        border.color: ringOpen ? "transparent" : Theme.alpha("line.soft", 0.6)
        border.width: 1

        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on rotation { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
        rotation: ringOpen ? 45 : 0

        Text {
            anchors.centerIn: parent
            text: "+"
            font.pixelSize: 24
            font.family: Theme.fontUi
            font.weight: Font.Light
            color: ringOpen ? Theme.color("text.onAccent") : Theme.color("text.primary")
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ringOpen = !ringOpen
        }
    }

    Repeater {
        model: root.menuItems
        delegate: Item {
            id: menuItem
            width: 48
            height: 48
            anchors.centerIn: parent
            opacity: ringOpen ? 1 : 0
            visible: opacity > 0.01

            property real targetAngle: modelData.angle
            property real targetDistance: ringOpen ? 78 : 0

            x: Math.cos((targetAngle - 90) * Math.PI / 180) * targetDistance
            y: Math.sin((targetAngle - 90) * Math.PI / 180) * targetDistance

            Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }
            Behavior on y { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 150 } }

            Rectangle {
                anchors.fill: parent
                radius: 24
                color: itemMouse.containsPressed ? Theme.color("accent.strong")
                     : itemMouse.containsMouse ? Theme.alpha("accent.base", 0.15)
                     : Theme.glass(0.85)
                border.color: Theme.alpha("line.soft", 0.5)
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    font.pixelSize: 18
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.bottom
                    anchors.topMargin: 2
                    text: modelData.label
                    font.pixelSize: 9
                    font.family: Theme.fontUi
                    color: Theme.color("text.primary")
                    opacity: itemMouse.containsMouse ? 1 : 0.7
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.panelRequested(modelData.name)
                        ringOpen = false
                    }
                }
            }
        }
    }
}
