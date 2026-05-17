import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

Rectangle {
    id: root
    height: 56
    radius: 28
    color: Theme.isDark ? Theme.alpha("surface.raised", 0.94) : Theme.alpha("surface.float", 0.94)
    border.color: Theme.alpha("line.soft", Theme.isDark ? 0.80 : 0.72)
    border.width: 1

    property var store: null

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 6
        radius: parent.radius
        color: Theme.alpha("overlay.scrim", Theme.isDark ? 0.30 : 0.070)
        z: -1
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: 24
        anchors.rightMargin: 24
        anchors.topMargin: 1
        height: 1
        radius: 1
        color: Theme.alpha("surface.float", Theme.isDark ? 0.22 : 0.88)
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: parent.radius - 1
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Theme.alpha("surface.float", Theme.isDark ? 0.10 : 0.38) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 7
        spacing: 10

        TextField {
            id: inputField
            Layout.fillWidth: true
            placeholderText: root.store ? "\u8DDF " + root.store.state.characterName + " \u8BF4\u70B9\u4EC0\u4E48..." : "\u8BF4\u70B9\u4EC0\u4E48..."
            placeholderTextColor: Theme.color("text.tertiary")
            background: Item {}
            font.pixelSize: 16
            font.family: Theme.fontUi
            color: Theme.color("text.primary")
            verticalAlignment: TextInput.AlignVCenter
            selectByMouse: true

            Keys.onReturnPressed: root.send()
            Keys.onEnterPressed: root.send()
        }

        Rectangle {
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            radius: 19
            color: micMouse.containsMouse ? Theme.alpha("surface.sunken", Theme.isDark ? 0.64 : 0.70) : Theme.alpha("surface.base", Theme.isDark ? 0.12 : 0.38)
            border.color: micMouse.containsMouse ? Theme.alpha("line.soft", 0.62) : Theme.alpha("line.soft", 0.34)
            border.width: 1

            ShapeIcon {
                anchors.centerIn: parent
                pathData: Icons.mic
                size: 18
                iconColor: Theme.color("text.secondary")
            }

            MouseArea {
                id: micMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }

        Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            radius: 22
            color: sendMouse.containsMouse ? Theme.color("accent.strong") : Theme.color("accent.base")
            Behavior on color { ColorAnimation { duration: 120 } }

            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 3
                radius: parent.radius
                color: Theme.alpha("overlay.scrim", Theme.isDark ? 0.20 : 0.10)
                z: -1
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 11
                anchors.rightMargin: 11
                anchors.topMargin: 1
                height: 1
                color: Theme.alpha("text.onAccent", 0.44)
            }

            ShapeIcon {
                anchors.centerIn: parent
                pathData: Icons.send
                size: 18
                iconColor: Theme.color("text.onAccent")
            }

            MouseArea {
                id: sendMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.send()
            }
        }
    }

    function send() {
        if (!store) return
        store.sendMessage(inputField.text)
        inputField.text = ""
    }
}
