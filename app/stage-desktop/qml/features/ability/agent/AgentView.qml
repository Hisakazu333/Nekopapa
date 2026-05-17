import QtQuick
import QtQuick.Layouts

Item {
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        Text {
            text: "\u6E38\u620F\u4EE3\u7406"
            font.pixelSize: 20
            font.family: Theme.fontUi
            font.weight: Font.Bold
            color: Theme.color("text.primary")
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            StatCard { label: "\u6D3B\u8DC3\u4EE3\u7406"; value: "3" }
            StatCard { label: "\u4ECA\u65E5\u8C03\u7528"; value: "42" }
            StatCard { label: "\u6210\u529F\u7387"; value: "98%" }
        }

        Item { Layout.fillHeight: true }
    }

    component StatCard: Rectangle {
        property string label: ""
        property string value: ""

        Layout.fillWidth: true
        Layout.preferredHeight: 100
        radius: Theme.radiusLg
        color: Theme.color("surface.base")
        border.color: Theme.color("line.soft")
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 6
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: parent.parent.value
                font.pixelSize: 28
                font.family: Theme.fontMono
                font.weight: Font.Bold
                color: Theme.color("accent.base")
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: parent.parent.label
                font.pixelSize: 12
                font.family: Theme.fontUi
                color: Theme.color("text.secondary")
            }
        }
    }
}
