import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string title: ""
    default property alias rows: body.data

    spacing: 0

    NNACardPanel {
        Layout.fillWidth: true
        implicitHeight: groupStack.implicitHeight
        panelRadius: 12
        fillColor: Theme.color("surface.base")
        strokeColor: Theme.alpha("line.soft", Theme.isDark ? 0.70 : 0.96)

        ColumnLayout {
            id: groupStack
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 0

            Text {
                Layout.fillWidth: true
                Layout.preferredHeight: 58
                Layout.leftMargin: 26
                Layout.rightMargin: 26
                text: root.title
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 18
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: Theme.color("text.primary")
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 0
                visible: false
                color: Theme.alpha("line.soft", Theme.isDark ? 0.46 : 0.82)
            }

            ColumnLayout {
                id: body
                Layout.fillWidth: true
                spacing: 0
            }
        }
    }
}
