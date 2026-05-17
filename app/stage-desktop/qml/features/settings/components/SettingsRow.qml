import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    property string label: ""
    property string description: ""
    default property alias control: controlArea.children

    Layout.fillWidth: true
    Layout.preferredHeight: 52
    spacing: 16

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        Text {
            text: root.label
            font.pixelSize: 14
            font.family: Theme.fontUi
            color: Theme.color("text.primary")
        }
        Text {
            text: root.description
            font.pixelSize: 11
            font.family: Theme.fontUi
            color: Theme.color("text.tertiary")
            visible: text !== ""
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }
    }

    Item {
        id: controlArea
        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
    }
}
