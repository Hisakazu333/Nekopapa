import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string activeSection: "overview"
    signal sectionRequested(string sectionId)

    readonly property var modes: [
        { id: "overview", label: "\u603B\u89C8" },
        { id: "companion", label: "\u6A21\u578B" },
        { id: "desktop", label: "\u8FDE\u63A5" },
        { id: "account", label: "\u8D26\u53F7" },
        { id: "privacy", label: "\u6570\u636E" }
    ]

    implicitHeight: 34
    implicitWidth: Math.min(520, track.implicitWidth + 4)

    Rectangle {
        id: track
        anchors.centerIn: parent
        height: 34
        width: modeRow.implicitWidth + 6
        radius: 10
        color: Theme.color("surface.float")
        border.color: Theme.color("apple.hairline")
        border.width: 1

        Row {
            id: modeRow
            anchors.centerIn: parent
            spacing: 2

            Repeater {
                model: root.modes

                delegate: Rectangle {
                    required property var modelData

                    width: Math.max(52, modeLabel.implicitWidth + 18)
                    height: 28
                    radius: 7
                    color: root.activeSection === modelData.id
                        ? Theme.color("apple.selection")
                        : (modeMouse.containsMouse ? Theme.alpha("apple.selection", 0.55) : "transparent")

                    Text {
                        id: modeLabel
                        anchors.centerIn: parent
                        text: modelData.label
                        font.pixelSize: 12
                        font.family: Theme.fontUi
                        font.weight: root.activeSection === modelData.id ? Font.DemiBold : Font.Medium
                        color: root.activeSection === modelData.id
                            ? Theme.color("apple.ink")
                            : Theme.color("apple.secondary")
                    }

                    MouseArea {
                        id: modeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.sectionRequested(modelData.id)
                    }
                }
            }
        }
    }
}
