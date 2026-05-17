import QtQuick
import QtQuick.Layouts

Item {
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        Text {
            text: "\u8FDB\u5316\u4E0E\u8BAD\u7EC3"
            font.pixelSize: 20
            font.family: Theme.fontUi
            font.weight: Font.Bold
            color: Theme.color("text.primary")
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            radius: Theme.radiusLg
            color: Theme.color("surface.base")
            border.color: Theme.color("line.soft")
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                RowLayout {
                    spacing: 8
                    Text {
                        text: "\u5F53\u524D\u9636\u6BB5"
                        font.pixelSize: 14
                        font.family: Theme.fontUi
                        color: Theme.color("text.secondary")
                    }
                    Text {
                        text: "\u7B2C 3 \u9636\u6BB5 / 5"
                        font.pixelSize: 14
                        font.family: Theme.fontMono
                        font.weight: Font.Bold
                        color: Theme.color("text.primary")
                    }
                    Item { Layout.fillWidth: true }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 8
                    radius: 4
                    color: Theme.color("surface.sunken")
                    Rectangle {
                        width: parent.width * 0.6
                        height: parent.height
                        radius: 4
                        color: Theme.color("accent.strong")
                    }
                }
            }
        }

        NNABaseButton {
            text: "\u5F00\u59CB\u8BAD\u7EC3"
            buttonType: NNABaseButton.ButtonType.Primary
            onClicked: {}
        }

        Item { Layout.fillHeight: true }
    }
}
