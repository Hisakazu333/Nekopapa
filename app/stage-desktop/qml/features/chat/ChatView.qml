import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property real dockClearance: 104

    ChatStore { id: chatStore }
    readonly property var s: chatStore.state
    readonly property bool compactLayout: width < 980 || height < 720
    readonly property real outerMargin: compactLayout ? 18 : 26
    readonly property real stageMaxWidth: 1240
    readonly property real stageWidth: Math.max(640, Math.min(width - outerMargin * 2, stageMaxWidth))
    readonly property real leftRailWidth: compactLayout ? 252 : 272
    readonly property real chatLeftInset: compactLayout ? 22 : 34
    readonly property real chatRightInset: compactLayout ? 22 : 34

    Rectangle {
        anchors.fill: parent
        color: Theme.color("bg.canvas")
    }

    Item {
        id: pageStage
        width: root.stageWidth
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.dockClearance + (compactLayout ? 8 : 14)
        anchors.horizontalCenter: parent.horizontalCenter

        Item {
            id: contentPage
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            Rectangle {
                id: leftRail
                width: root.leftRailWidth
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: Theme.alpha("surface.sunken", Theme.isDark ? 0.82 : 0.48)

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: compactLayout ? 14 : 18
                    anchors.rightMargin: compactLayout ? 14 : 18
                    anchors.topMargin: compactLayout ? 12 : 16
                    anchors.bottomMargin: compactLayout ? 12 : 16
                    spacing: compactLayout ? 10 : 12

                    ProfileHeader {
                        Layout.fillWidth: true
                        companionName: appController.characterName
                    }

                    SideCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: compactLayout ? 80 : 84

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            anchors.topMargin: 12
                            anchors.bottomMargin: 12
                            spacing: 12

                            ShapeIcon {
                                pathData: Icons.heart
                                size: 30
                                iconColor: Theme.color("accent.strong")
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3

                                Text {
                                    text: "亲密度 PAD"
                                    font.pixelSize: 13
                                    font.family: Theme.fontUi
                                    font.weight: Font.DemiBold
                                    color: Theme.color("text.secondary")
                                }

                                RowLayout {
                                    spacing: 8

                                    Text {
                                        text: "84"
                                        font.pixelSize: 25
                                        font.family: Theme.fontUi
                                        font.weight: Font.Black
                                        color: Theme.color("text.primary")
                                    }

                                    Text {
                                        text: "亲密"
                                        font.pixelSize: 12
                                        font.family: Theme.fontUi
                                        color: Theme.color("text.tertiary")
                                    }
                                }
                            }

                            ShapeIcon {
                                pathData: Icons.chevronRight
                                size: 16
                                iconColor: Theme.color("text.tertiary")
                            }
                        }
                    }

                    SideCard {
                        Layout.fillWidth: true
                        Layout.preferredHeight: compactLayout ? 166 : 176

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 14
                            spacing: 9

                            RowLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.fillWidth: true
                                    text: "情绪状态"
                                    font.pixelSize: 13
                                    font.family: Theme.fontUi
                                    font.weight: Font.DemiBold
                                    color: Theme.color("text.secondary")
                                }

                                StatusChip {
                                    labelText: "愉悦"
                                    accentColor: Theme.color("state.warning")
                                }
                            }

                            StatBar {
                                Layout.fillWidth: true
                                labelText: "饱食"
                                valueText: formatPercent(appController.satiety)
                                progress: appController.satiety / 100
                                accentColor: Theme.color("state.success")
                            }

                            StatBar {
                                Layout.fillWidth: true
                                labelText: "水分"
                                valueText: formatPercent(appController.hydration)
                                progress: appController.hydration / 100
                                accentColor: Theme.color("state.danger")
                            }

                            StatBar {
                                Layout.fillWidth: true
                                labelText: "活力"
                                valueText: formatPercent(appController.energy)
                                progress: appController.energy / 100
                                accentColor: Theme.color("state.warning")
                            }
                        }
                    }

                    SideCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: compactLayout ? 136 : 164
                        clip: true

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 1
                            radius: parent.radius - 1
                            color: Theme.alpha("surface.float", Theme.isDark ? 0.40 : 0.74)
                        }

                        CompanionPortrait {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            width: parent.width * 0.96
                            height: parent.height * 1.02
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        radius: 18
                        color: Theme.color("surface.float")
                        border.color: Theme.alpha("line.soft", 0.86)
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 8

                            ShapeIcon {
                                pathData: Icons.search
                                size: 14
                                iconColor: Theme.color("text.tertiary")
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "轻声拍桌"
                                font.pixelSize: 13
                                font.family: Theme.fontUi
                                font.weight: Font.DemiBold
                                color: Theme.color("text.secondary")
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: 1
                anchors.left: leftRail.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: Theme.alpha("line.soft", 0.86)
            }

            Rectangle {
                id: chatPane
                anchors.left: leftRail.right
                anchors.leftMargin: 1
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                color: Theme.alpha("surface.float", Theme.isDark ? 0.50 : 0.64)

                Rectangle {
                    id: dateStrip
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: compactLayout ? 58 : 66
                    color: Theme.color("surface.float")

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: root.chatLeftInset
                        anchors.rightMargin: root.chatRightInset
                        spacing: 14

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: Theme.alpha("line.soft", 0.82)
                        }

                        Text {
                            text: "5月16日  今天"
                            font.pixelSize: 13
                            font.family: Theme.fontUi
                            font.weight: Font.DemiBold
                            color: Theme.color("text.tertiary")
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: Theme.alpha("line.soft", 0.82)
                        }
                    }
                }

                ListView {
                    id: messageList
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: dateStrip.bottom
                    anchors.bottom: inputDock.top
                    clip: true
                    model: s.messages
                    spacing: compactLayout ? 12 : 18
                    boundsBehavior: Flickable.StopAtBounds
                    leftMargin: root.chatLeftInset
                    rightMargin: root.chatRightInset
                    topMargin: compactLayout ? 20 : 28
                    bottomMargin: 18

                    delegate: MessageRow {
                        width: messageList.width - messageList.leftMargin - messageList.rightMargin
                        messageText: modelData.text
                        fromUser: modelData.isUser
                        timeText: modelData.time || ""
                        liked: modelData.liked || false
                    }

                    onCountChanged: Qt.callLater(positionViewAtEnd)

                    add: Transition {
                        NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: 160 }
                        NumberAnimation { properties: "y"; from: 12; duration: 160; easing.type: Easing.OutCubic }
                    }
                }

                Rectangle {
                    id: inputDock
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: compactLayout ? 72 : 82
                    color: Theme.color("surface.float")

                    Rectangle {
                        anchors.top: parent.top
                        width: parent.width
                        height: 1
                        color: Theme.alpha("line.soft", 0.78)
                    }

                    HomeInputBar {
                        anchors.fill: parent
                        anchors.leftMargin: root.chatLeftInset
                        anchors.rightMargin: root.chatRightInset
                        anchors.topMargin: 12
                        anchors.bottomMargin: 12
                        store: chatStore
                    }
                }
            }
        }
    }

    function formatPercent(value) {
        return Math.round(value) + "%"
    }

    component SideCard: Rectangle {
        default property alias content: contentLayer.data

        radius: 18
        color: Theme.alpha("surface.float", Theme.isDark ? 0.72 : 0.84)
        border.color: Theme.alpha("line.soft", 0.82)
        border.width: 1

        Item {
            id: contentLayer
            anchors.fill: parent
        }
    }

    component ProfileHeader: Rectangle {
        property string companionName: "Lumia"

        implicitHeight: 54
        radius: 18
        color: "transparent"

        RowLayout {
            anchors.fill: parent
            spacing: 12

            CompanionAvatar {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 42
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: companionName
                    font.pixelSize: 17
                    font.family: Theme.fontUi
                    font.weight: Font.Black
                    color: Theme.color("text.primary")
                }

                RowLayout {
                    spacing: 6

                    Rectangle {
                        Layout.preferredWidth: 7
                        Layout.preferredHeight: 7
                        radius: 3.5
                        color: Theme.color("state.success")
                    }

                    Text {
                        text: "在线"
                        font.pixelSize: 12
                        font.family: Theme.fontUi
                        color: Theme.color("text.secondary")
                    }
                }
            }

            ShapeIcon {
                pathData: Icons.chevronRight
                size: 16
                iconColor: Theme.color("text.tertiary")
            }
        }
    }

    component StatusChip: Rectangle {
        property string labelText: ""
        property color accentColor: Theme.color("accent.base")

        implicitWidth: chipLabel.implicitWidth + 24
        implicitHeight: 26
        radius: 13
        color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, Theme.isDark ? 0.20 : 0.16)

        Text {
            id: chipLabel
            anchors.centerIn: parent
            text: parent.labelText
            font.pixelSize: 11
            font.family: Theme.fontUi
            font.weight: Font.DemiBold
            color: parent.accentColor
        }
    }

    component StatBar: Item {
        property string labelText: ""
        property string valueText: ""
        property real progress: 0
        property color accentColor: Theme.color("accent.base")

        implicitHeight: 26

        Text {
            id: statLabel
            anchors.left: parent.left
            anchors.top: parent.top
            text: parent.labelText
            font.pixelSize: 12
            font.family: Theme.fontUi
            color: Theme.color("text.secondary")
        }

        Text {
            anchors.right: parent.right
            anchors.top: parent.top
            text: parent.valueText
            font.pixelSize: 12
            font.family: Theme.fontUi
            color: Theme.color("text.secondary")
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 5
            radius: 2.5
            color: Theme.alpha("line.soft", 0.70)

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, progress))
                height: parent.height
                radius: parent.radius
                color: accentColor
            }
        }
    }

    component MessageRow: Item {
        property string messageText: ""
        property bool fromUser: false
        property string timeText: ""
        property bool liked: false
        readonly property real maxBubbleWidth: fromUser ? Math.min(width * 0.50, 420) : Math.min(width * 0.56, 470)
        readonly property real bubbleWidthHint: Math.min(maxBubbleWidth, Math.max(fromUser ? 280 : 360, messageText.length * 10 + 96))

        height: bubble.height + (fromUser ? 16 : 20)

        CompanionAvatar {
            id: avatar
            width: 28
            height: 28
            anchors.verticalCenter: bubble.verticalCenter
            anchors.right: fromUser ? parent.right : undefined
            anchors.left: fromUser ? undefined : parent.left
        }

        Rectangle {
            id: bubble
            width: bubbleWidthHint
            height: messageTextLabel.implicitHeight + 34
            radius: 16
            anchors.top: parent.top
            anchors.right: fromUser ? avatar.left : undefined
            anchors.left: fromUser ? undefined : avatar.right
            anchors.rightMargin: fromUser ? 10 : 0
            anchors.leftMargin: fromUser ? 0 : 10
            color: fromUser ? "#F7DFBE" : Theme.color("surface.raised")
            border.color: fromUser ? Theme.alpha("state.warning", 0.24) : Theme.alpha("line.soft", 0.84)
            border.width: 1

            Text {
                id: messageTextLabel
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                anchors.topMargin: 11
                text: messageText
                width: parent.width - 36
                wrapMode: Text.Wrap
                font.pixelSize: 15
                font.family: Theme.fontUi
                lineHeight: 1.35
                color: Theme.color("text.primary")
            }

            Text {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.rightMargin: 14
                anchors.bottomMargin: 7
                text: timeText
                font.pixelSize: 11
                font.family: Theme.fontUi
                color: Theme.color("text.tertiary")
            }
        }

        ShapeIcon {
            visible: liked && !fromUser
            anchors.left: bubble.right
            anchors.leftMargin: 12
            anchors.verticalCenter: bubble.verticalCenter
            pathData: Icons.heart
            size: 14
            iconColor: Theme.color("accent.base")
        }
    }

    component CompanionAvatar: Rectangle {
        radius: width / 2
        clip: true
        color: Theme.alpha("accent.soft", 0.86)
        border.color: Theme.alpha("line.soft", 0.74)
        border.width: 1

        HomeAvatarArea {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: parent.height * 0.70
            width: parent.width * 3.0
            height: parent.height * 3.4
            modelScale: 1.86
            modelOffsetX: 0.0
            modelOffsetY: -0.34
            projectionWidthHint: width
            projectionHeightHint: height
        }
    }

    component CompanionPortrait: Item {
        HomeAvatarArea {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -parent.height * 0.16
            width: parent.width * 1.18
            height: parent.height * 1.30
            modelScale: 1.62
            modelOffsetX: 0.0
            modelOffsetY: -0.22
            projectionWidthHint: width
            projectionHeightHint: height
        }
    }
}
