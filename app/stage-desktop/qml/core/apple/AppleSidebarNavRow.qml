import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string label: ""
    property string iconPath: ""
    property bool active: false
    signal triggered()

    Layout.fillWidth: true
    Layout.preferredHeight: 34
    radius: 6
    color: active
        ? Theme.color("apple.selection")
        : (navMouse.containsMouse ? Theme.alpha("apple.selection", 0.55) : "transparent")

    Behavior on color { ColorAnimation { duration: 100 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 10

        ShapeIcon {
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
            pathData: root.iconPath
            size: 16
            strokeWidth: 1.6
            iconColor: root.active ? Theme.color("apple.ink") : Theme.color("apple.secondary")
        }

        Text {
            Layout.fillWidth: true
            text: root.label
            elide: Text.ElideRight
            font.pixelSize: 13
            font.family: Theme.fontUi
            font.weight: root.active ? Font.DemiBold : Font.Medium
            color: Theme.color("apple.ink")
        }
    }

    MouseArea {
        id: navMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.triggered()
    }
}
