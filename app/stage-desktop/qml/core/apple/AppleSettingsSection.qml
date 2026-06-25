import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string title: ""
    default property alias rows: body.data

    spacing: 8

    Text {
        visible: root.title !== ""
        Layout.fillWidth: true
        Layout.leftMargin: 4
        text: root.title
        font.pixelSize: 13
        font.family: Theme.fontUi
        font.weight: Font.DemiBold
        color: Theme.color("apple.secondary")
    }

    ColumnLayout {
        id: body
        Layout.fillWidth: true
        spacing: 0
    }
}
