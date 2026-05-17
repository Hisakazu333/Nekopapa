import QtQuick

Item {
    id: root
    width: 140
    height: 140

    signal detailRequested(string orbType)

    readonly property var stats: [
        { type: "mood",    label: "\u5FC3\u60C5", value: appController.pleasure,    color: "accent.base" },
        { type: "satiety", label: "\u9971\u98DF", value: appController.satiety / 100, color: "state.success" },
        { type: "energy",  label: "\u6D3B\u529B", value: appController.energy / 100,  color: "state.warning" }
    ]

    Column {
        anchors.fill: parent
        spacing: 8

        Repeater {
            model: root.stats

            delegate: Row {
                spacing: 8
                width: parent.width

                Text {
                    text: modelData.label
                    font.pixelSize: 11
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                    width: 32
                }

                Rectangle {
                    width: 60
                    height: 4
                    radius: 2
                    color: Theme.color("line.soft")
                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, modelData.value))
                        height: parent.height
                        radius: 2
                        color: Theme.color(modelData.color)
                    }
                }

                Text {
                    text: Math.round(modelData.value * 100) + "%"
                    font.pixelSize: 11
                    font.family: Theme.fontMono
                    color: Theme.color(modelData.color)
                    width: 32
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
