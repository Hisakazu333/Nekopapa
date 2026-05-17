import QtQuick
import QtQuick.Layouts

Item {
    id: root
    width: 148
    height: 36
    clip: true

    // Shadow backdrop
    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.shadow("overlay.scrim", 2)
        anchors.verticalCenterOffset: 2
        opacity: 0.18
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.glass(0.84)
        border.color: Theme.alpha("line.soft", 0.58)
        border.width: 1

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 1
            radius: parent.radius
            color: Theme.alpha("surface.float", Theme.isDark ? 0.14 : 0.34)
        }

        RowLayout {
            id: chipRow
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 10
            anchors.topMargin: 3
            anchors.bottomMargin: 3
            spacing: 8

            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                radius: 15
                clip: true
                color: Theme.alpha("accent.soft", Theme.isDark ? 0.74 : 0.92)
                border.color: Theme.alpha("accent.base", 0.68)
                border.width: 1

                HomeAvatarArea {
                    anchors.centerIn: parent
                    width: parent.width * 2.8
                    height: parent.height * 3.0
                    modelScale: 3.8
                    modelOffsetX: 0.0
                    modelOffsetY: 0.18
                    projectionWidthHint: width
                    projectionHeightHint: height
                }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Theme.alpha("surface.float", 0.04)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: appController.characterName
                    font.pixelSize: 13
                    font.family: Theme.fontUi
                    font.weight: Font.Bold
                    color: Theme.color("text.primary")
                    elide: Text.ElideRight
                }
                Text {
                    text: "\u5728\u7EBF"
                    font.pixelSize: 10
                    font.family: Theme.fontUi
                    color: Theme.color("state.success")
                }
            }

            Rectangle {
                Layout.preferredWidth: 8
                Layout.preferredHeight: 8
                radius: 4
                color: Theme.color("state.success")

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.4; duration: 1200; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 1200; easing.type: Easing.InOutSine }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
            }
        }
    }
}
