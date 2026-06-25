import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string title: ""
    default property alias rows: body.data

    spacing: 6

    Text {
        visible: root.title !== ""
        Layout.fillWidth: true
        Layout.leftMargin: 4
        Layout.bottomMargin: 2
        text: root.title
        font.pixelSize: 13
        font.family: Theme.fontUi
        font.weight: Font.DemiBold
        color: Theme.color("apple.secondary")
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: Math.max(1, body.childrenRect.height)
        radius: Theme.appleRadiusGroup
        color: Theme.color("apple.grouped")
        border.color: Theme.color("apple.hairline")
        border.width: 1
        clip: true

        ColumnLayout {
            id: body
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 0
        }
    }
}
