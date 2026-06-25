import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string label: ""
    property string value: ""
    property color valueColor: Theme.color("apple.tertiary")
    property bool showChevron: false
    property bool interactive: false
    default property alias trailing: trailingSlot.data

    signal triggered()

    implicitWidth: row.implicitWidth
    implicitHeight: 28
    Layout.fillWidth: true
    Layout.preferredHeight: implicitHeight

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: 10

        Text {
            Layout.preferredWidth: Math.min(120, root.width * 0.38)
            text: root.label
            elide: Text.ElideRight
            font.pixelSize: 13
            font.family: Theme.fontUi
            color: Theme.color("apple.secondary")
        }

        Item { Layout.fillWidth: true }

        Item {
            id: trailingSlot
            Layout.preferredWidth: childrenRect.width
            Layout.preferredHeight: Math.max(1, childrenRect.height)
            visible: children.length > 0
        }

        Text {
            visible: root.value !== "" && trailingSlot.children.length === 0
            text: root.value
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignRight
            font.pixelSize: 13
            font.family: Theme.fontUi
            color: root.valueColor
        }

        ShapeIcon {
            visible: root.showChevron && root.interactive && trailingSlot.children.length === 0
            pathData: Icons.chevronRight
            size: 11
            iconColor: Theme.color("apple.tertiary")
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: root.interactive
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (root.interactive) root.triggered()
    }
}
