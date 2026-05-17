import QtQuick
import QtQuick.Controls

Rectangle {
    id: root

    property alias text: textField.text
    property alias placeholderText: textField.placeholderText
    property alias echoMode: textField.echoMode
    property bool valid: true
    property bool inputActiveFocus: textField.activeFocus

    signal accepted()

    radius: Theme.radiusMd
    color: {
        if (!valid) return Theme.color("surface.base")
        if (textField.activeFocus) return Theme.color("surface.base")
        return Theme.color("surface.sunken")
    }
    border.color: {
        if (!valid) return Theme.color("state.danger")
        if (textField.activeFocus) return Theme.color("accent.base")
        return Theme.color("line.soft")
    }
    border.width: 1

    Behavior on border.color { ColorAnimation { duration: 120 } }
    Behavior on color { ColorAnimation { duration: 120 } }

    TextField {
        id: textField
        anchors.fill: parent
        anchors.margins: 12
        background: Item {}
        font.pixelSize: 14
        font.family: Theme.fontUi
        color: Theme.color("text.primary")
        placeholderTextColor: Theme.color("text.tertiary")
        selectByMouse: true
        Keys.onReturnPressed: root.accepted()
        Keys.onEnterPressed: root.accepted()
    }
}
