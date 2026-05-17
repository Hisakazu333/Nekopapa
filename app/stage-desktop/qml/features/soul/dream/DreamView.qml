import QtQuick
import QtQuick.Layouts

Item {
    DreamStore { id: dreamStore }
    readonly property var s: dreamStore.state

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 12

        Text {
            text: "\u68A6\u5883\u65E5\u5FD7"
            font.pixelSize: 20
            font.family: Theme.fontUi
            font.weight: Font.Bold
            color: Theme.color("text.primary")
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            clip: true
            model: s.dreams

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width : 0
                height: 80
                radius: Theme.radiusLg
                color: Theme.color("surface.base")
                border.color: Theme.color("line.soft")
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 6

                    RowLayout {
                        spacing: 8
                        Text {
                            text: modelData.date
                            font.pixelSize: 11
                            font.family: Theme.fontMono
                            color: Theme.color("text.tertiary")
                        }
                        Rectangle {
                            Layout.preferredWidth: 4
                            Layout.preferredHeight: 4
                            radius: 2
                            color: Theme.color("line.soft")
                        }
                        Text {
                            text: "PAD: " + modelData.pad
                            font.pixelSize: 11
                            font.family: Theme.fontMono
                            color: Theme.color("accent.base")
                        }
                    }

                    Text {
                        text: modelData.content
                        font.pixelSize: 14
                        font.family: Theme.fontUi
                        font.italic: true
                        color: Theme.color("text.primary")
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                    }
                }
            }
        }
    }
}
