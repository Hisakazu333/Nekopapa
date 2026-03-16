import QtQuick
import QtQuick.Layouts

Item {
    property string pageName: ""
    property string pageIcon: ""

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Column {
            anchors.centerIn: parent
            spacing: 16

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: pageIcon
                font.pixelSize: 64
                opacity: 0.4
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: pageName
                font.pixelSize: 20
                font.family: "Nunito"
                font.weight: Font.Bold
                color: "#2D2D2D"
                opacity: 0.6
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "\u5F00\u53D1\u4E2D\uFF0C\u656C\u8BF7\u671F\u5F85~"
                font.pixelSize: 14
                font.family: "Nunito"
                color: "#9CA3AF"
            }

            // Cute sleeping cat animation placeholder
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "(=\u00B4\u2207\uFF40=) zzZ"
                font.pixelSize: 24
                color: "#D1D5DB"

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 1500; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
                }
            }
        }
    }
}
