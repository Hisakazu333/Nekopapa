import QtQuick
import QtQuick.Layouts

Item {
    StatusStore { id: statusStore }
    readonly property var s: statusStore.state

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        Text {
            text: "\u751F\u7406\u72B6\u6001\u4EEA\u8868\u76D8"
            font.pixelSize: 20
            font.family: Theme.fontUi
            font.weight: Font.Bold
            color: Theme.color("text.primary")
        }

        // PAD rings
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            RingCard { labelText: "Pleasure"; ringValue: s.pleasure; ringColor: Theme.color("accent.base") }
            RingCard { labelText: "Arousal"; ringValue: s.arousal; ringColor: Theme.color("state.warning") }
            RingCard { labelText: "Dominance"; ringValue: s.dominance; ringColor: Theme.color("state.success") }
        }

        // Physio bars
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            PhysioBar { label: "\u9971\u98DF\u5EA6"; value: s.satiety; color: Theme.color("state.success") }
            PhysioBar { label: "\u6C34\u5206"; value: s.hydration; color: Theme.color("info") }
            PhysioBar { label: "\u7CBE\u529B"; value: s.energy; color: Theme.color("state.warning") }
        }

        Item { Layout.fillHeight: true }
    }

    component RingCard: Rectangle {
        property string labelText: ""
        property real ringValue: 0
        property color ringColor: Theme.color("accent.base")

        Layout.fillWidth: true
        Layout.preferredHeight: 140
        radius: Theme.radiusLg
        color: Theme.color("surface.base")
        border.color: Theme.color("line.soft")
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 8

            // Simple ring simulation with rectangle
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 64
                height: 64
                radius: 32
                color: "transparent"
                border.color: Theme.color("surface.sunken")
                border.width: 6

                Rectangle {
                    anchors.fill: parent
                    radius: 32
                    color: "transparent"
                    border.color: parent.parent.parent.ringColor
                    border.width: 6
                    // Clip to show partial ring
                    Rectangle {
                        anchors.fill: parent
                        color: Theme.color("surface.base")
                        opacity: 1.0 - Math.max(0, Math.min(1, (parent.parent.parent.ringValue + 1) / 2))
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: ((parent.parent.parent.ringValue + 1) / 2 * 100).toFixed(0) + "%"
                    font.pixelSize: 13
                    font.family: Theme.fontMono
                    font.weight: Font.Bold
                    color: Theme.color("text.primary")
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: parent.parent.labelText
                font.pixelSize: 12
                font.family: Theme.fontUi
                color: Theme.color("text.secondary")
            }
        }
    }

    component PhysioBar: RowLayout {
        property string label: ""
        property real value: 0
        property color color: Theme.color("accent.base")

        Layout.fillWidth: true
        spacing: 12

        Text {
            text: parent.label
            font.pixelSize: 13
            font.family: Theme.fontUi
            color: Theme.color("text.secondary")
            Layout.preferredWidth: 60
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 8
            radius: 4
            color: Theme.color("surface.sunken")

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, parent.value / 100))
                height: parent.height
                radius: 4
                color: parent.color
                Behavior on width { NumberAnimation { duration: 600; easing.type: Easing.OutCubic } }
            }
        }

        Text {
            text: Math.round(parent.value) + "%"
            font.pixelSize: 12
            font.family: Theme.fontMono
            color: Theme.color("text.primary")
            Layout.preferredWidth: 40
        }
    }
}
