import QtQuick
import QtQuick.Layouts

Item {
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        Text {
            text: "\u73AF\u5883\u611F\u77E5"
            font.pixelSize: 20
            font.family: Theme.fontUi
            font.weight: Font.Bold
            color: Theme.color("text.primary")
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8
            clip: true
            model: [
                { name: "\u89C6\u89C9\u611F\u77E5", status: "active", last: "2s ago" },
                { name: "\u58F0\u97F3\u76D1\u542C", status: "active", last: "5s ago" },
                { name: "\u7CFB\u7EDF\u4E8B\u4EF6", status: "idle", last: "1m ago" }
            ]

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width : 0
                height: 52
                radius: Theme.radiusMd
                color: Theme.color("surface.base")
                border.color: Theme.color("line.soft")
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Rectangle {
                        Layout.preferredWidth: 8
                        Layout.preferredHeight: 8
                        radius: 4
                        color: modelData.status === "active" ? Theme.color("state.success") : Theme.color("text.tertiary")

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            running: modelData.status === "active"
                            NumberAnimation { to: 0.4; duration: 1000; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1.0; duration: 1000; easing.type: Easing.InOutSine }
                        }
                    }

                    Text {
                        text: modelData.name
                        font.pixelSize: 14
                        font.family: Theme.fontUi
                        color: Theme.color("text.primary")
                        Layout.fillWidth: true
                    }

                    Text {
                        text: modelData.last
                        font.pixelSize: 11
                        font.family: Theme.fontMono
                        color: Theme.color("text.tertiary")
                    }
                }
            }
        }
    }
}
