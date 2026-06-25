import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property string valueText: ""
    property color valueColor: Theme.color("apple.tertiary")
    property bool showChevron: true
    property bool interactive: true
    default property alias trailingContent: trailingSlot.data
    signal triggered()

    Layout.fillWidth: true
    Layout.preferredHeight: subtitle === "" ? 44 : 58
    color: rowMouse.containsMouse && interactive
        ? Theme.color("apple.selection")
        : "transparent"
    opacity: enabled ? 1.0 : 0.5

    Behavior on color { ColorAnimation { duration: 100 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 14
        spacing: 12

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.title
                elide: Text.ElideRight
                font.pixelSize: 13
                font.family: Theme.fontUi
                font.weight: Font.Medium
                color: Theme.color("apple.ink")
            }

            Text {
                Layout.fillWidth: true
                visible: root.subtitle !== ""
                text: root.subtitle
                elide: Text.ElideRight
                font.pixelSize: 11
                font.family: Theme.fontUi
                color: Theme.color("apple.tertiary")
            }
        }

        Item {
            id: trailingSlot
            Layout.preferredWidth: childrenRect.width
            Layout.preferredHeight: Math.max(1, childrenRect.height)
            visible: children.length > 0
        }

        Text {
            visible: root.valueText !== "" && trailingSlot.children.length === 0
            Layout.maximumWidth: Math.min(200, root.width * 0.42)
            text: root.valueText
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignRight
            font.pixelSize: 13
            font.family: Theme.fontUi
            color: root.valueColor
        }

        ShapeIcon {
            visible: root.showChevron && root.interactive && trailingSlot.children.length === 0
            pathData: Icons.chevronRight
            size: 12
            iconColor: Theme.color("apple.tertiary")
        }
    }

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (root.enabled) root.triggered()
    }
}
