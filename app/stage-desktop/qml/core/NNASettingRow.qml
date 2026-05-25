import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string iconPath: ""
    property string title: ""
    property string subtitle: ""
    property string valueText: ""
    property color valueColor: Theme.color("text.secondary")
    property bool showChevron: true
    property bool interactive: true
    default property alias trailingContent: trailingSlot.data
    signal triggered()

    Layout.fillWidth: true
    Layout.preferredHeight: subtitle === "" ? 64 : 82
    color: "transparent"
    opacity: enabled ? 1.0 : 0.46

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        anchors.topMargin: 3
        anchors.bottomMargin: 3
        radius: 8
        color: rowMouse.containsMouse && root.enabled && root.interactive
            ? (rowMouse.pressed ? Theme.alpha("surface.sunken", Theme.isDark ? 0.82 : 0.96) : Theme.alpha("surface.sunken", Theme.isDark ? 0.62 : 0.72))
            : "transparent"

        Behavior on color { ColorAnimation { duration: 130 } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 26
        anchors.rightMargin: 26
        spacing: 18

        ShapeIcon {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            pathData: root.iconPath
            size: 24
            strokeWidth: 1.66
            iconColor: Theme.alpha("text.primary", Theme.isDark ? 0.82 : 0.78)
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.title
                elide: Text.ElideRight
                font.pixelSize: 15
                font.family: Theme.fontUi
                font.weight: Font.Medium
                color: Theme.color("text.primary")
            }

            Text {
                Layout.fillWidth: true
                visible: root.subtitle !== ""
                text: root.subtitle
                elide: Text.ElideRight
                font.pixelSize: 12
                font.family: Theme.fontUi
                color: Theme.color("text.secondary")
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
            Layout.maximumWidth: Math.min(190, root.width * 0.34)
            text: root.valueText
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignRight
            font.pixelSize: 13
            font.family: Theme.fontUi
            font.weight: Font.Medium
            color: root.valueColor
        }

        ShapeIcon {
            visible: root.showChevron
                && root.interactive
                && trailingSlot.children.length === 0
            pathData: Icons.chevronRight
            size: 13
            iconColor: rowMouse.containsMouse && root.enabled ? Theme.color("text.secondary") : Theme.color("text.tertiary")
        }
    }

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: root.enabled && root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (root.enabled) root.triggered()
    }
}
