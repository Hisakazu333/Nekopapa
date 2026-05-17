import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    property string title: ""
    property string description: ""
    default property alias content: innerLayout.children

    Layout.fillWidth: true
    spacing: 12

    ColumnLayout {
        spacing: 4
        Text {
            text: root.title
            font.pixelSize: 16
            font.family: Theme.fontUi
            font.weight: Font.Bold
            color: Theme.color("text.primary")
            visible: root.title !== ""
        }
        Text {
            text: root.description
            font.pixelSize: 12
            font.family: Theme.fontUi
            color: Theme.color("text.secondary")
            visible: root.description !== ""
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }
    }

    ColumnLayout {
        id: innerLayout
        spacing: 0
        Layout.fillWidth: true
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Theme.color("line.soft")
    }
}
