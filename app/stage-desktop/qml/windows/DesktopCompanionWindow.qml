import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import NNA.Core 1.0

Window {
    id: root

    property var shellRef: null
    property var mainWindowRef: null
    property bool companionEnabled: false

    width: 260
    height: 560
    visible: companionEnabled && (mainWindowRef ? mainWindowRef.visible : true)
    color: "transparent"
    flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    modality: Qt.NonModal

    x: mainWindowRef ? mainWindowRef.x + mainWindowRef.width + 420 : 1500
    y: mainWindowRef ? mainWindowRef.y + 170 : 200

    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }

    Rectangle {
        width: parent.width * 0.90
        height: width * 1.12
        radius: width / 2
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 84
        color: Theme.alpha("accent.base", Theme.isDark ? 0.12 : 0.12)
    }

    Repeater {
        model: 5

        delegate: Rectangle {
            width: 10 + index * 5
            height: width
            radius: width / 2
            x: 24 + index * 28
            y: 210 + (index % 2) * 26
            color: Theme.alpha("accent.base", 0.16)
        }
    }

    Rectangle {
        width: 172
        height: bubbleColumn.implicitHeight + 24
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 24
        radius: 24
        color: Theme.alpha("surface.base", Theme.isDark ? 0.84 : 0.90)
        border.color: Theme.alpha("line.soft", 0.70)
        border.width: 1

        Column {
            id: bubbleColumn
            anchors.fill: parent
            anchors.margins: 14
            spacing: 4

            Text {
                text: greetingText()
                font.pixelSize: 13
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: Theme.color("text.primary")
            }

            Text {
                width: parent.width
                text: "\u8981\u4E00\u8D77\u804A\u804A\u5929\u5417\uff1F"
                wrapMode: Text.WordWrap
                lineHeight: 1.3
                font.pixelSize: 11
                font.family: Theme.fontUi
                color: Theme.color("text.secondary")
            }
        }
    }

    Rectangle {
        width: 40
        height: 40
        radius: 20
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 126
        anchors.rightMargin: 14
        color: Theme.alpha("surface.base", Theme.isDark ? 0.82 : 0.90)
        border.color: Theme.alpha("line.soft", 0.70)
        border.width: 1

        ShapeIcon {
            anchors.centerIn: parent
            pathData: Icons.close
            size: 15
            iconColor: Theme.color("text.secondary")
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: appController.desktopCompanionEnabled = false
        }
    }

    Item {
        id: stageArea
        anchors.left: parent.left
        anchors.right: actionRail.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 120
        anchors.bottomMargin: 26
        anchors.rightMargin: 12

        Rectangle {
            width: parent.width * 0.76
            height: width
            radius: width / 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 56
            color: Theme.alpha("surface.base", Theme.isDark ? 0.16 : 0.24)
        }

        NNAAvatarCanvas {
            id: miniAvatar
            anchors.fill: parent
            modelPath: appController.currentModelPath
            modelScale: 0.90
            modelOffsetX: 0
            modelOffsetY: 0
            visible: modelLoaded || appController.currentModelPath !== ""
        }

        Item {
            anchors.centerIn: parent
            width: 120
            height: 180
            visible: !miniAvatar.modelLoaded && !appController.currentModelPath

            Rectangle {
                width: 90
                height: 90
                radius: 45
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                color: Theme.alpha("surface.base", Theme.isDark ? 0.18 : 0.36)

                Text {
                    anchors.centerIn: parent
                    text: "LN"
                    font.pixelSize: 30
                    font.family: Theme.fontUi
                    font.weight: Font.Bold
                    color: Theme.color("text.tertiary")
                }
            }
        }
    }

    Column {
        id: actionRail
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 12
        spacing: 10

        MiniActionBubble {
            iconPath: Icons.chat
            onTriggered: if (shellRef) shellRef.openOverlay(0)
        }

        MiniActionBubble {
            iconPath: Icons.heart
            onTriggered: appController.touchPet(0.5, 0.5, 1.0)
        }

        MiniActionBubble {
            iconPath: Icons.memory
            onTriggered: if (shellRef) shellRef.openMineSection("memory")
        }

        MiniActionBubble {
            iconPath: Icons.more
            onTriggered: if (shellRef) shellRef.openMineSection("overview")
        }
    }

    component MiniActionBubble: Rectangle {
        id: bubble
        property string iconPath: Icons.chat
        signal triggered()

        width: 42
        height: 42
        radius: 21
        color: Theme.alpha("surface.base", Theme.isDark ? 0.82 : 0.90)
        border.color: Theme.alpha("line.soft", 0.68)
        border.width: 1

        ShapeIcon {
            anchors.centerIn: parent
            pathData: bubble.iconPath
            size: 16
            iconColor: Theme.color("text.secondary")
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: bubble.triggered()
        }
    }

    function greetingText() {
        var h = new Date().getHours()
        if (h < 6 || h >= 22)
            return "\u591C\u6DF1\u4E86..."
        if (h < 12)
            return "\u65E9\u4E0A\u597D"
        if (h < 18)
            return "\u4E0B\u5348\u597D"
        return "\u665A\u4E0A\u597D"
    }
}
