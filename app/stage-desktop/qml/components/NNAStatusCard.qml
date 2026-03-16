import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card

    property string title: ""
    property string icon: ""
    property color accentColor: "#FF7AA2"

    default property alias content: contentColumn.children

    radius: 18
    color: "#FFFFFF"
    border.color: Qt.alpha(card.accentColor, 0.08)
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        RowLayout {
            spacing: 6
            Text {
                text: card.icon
                font.pixelSize: 16
            }
            Text {
                text: card.title
                font.pixelSize: 14
                font.family: "Nunito"
                font.weight: Font.Bold
                color: "#2D2D2D"
            }
        }

        Column {
            id: contentColumn
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6
        }
    }
}
