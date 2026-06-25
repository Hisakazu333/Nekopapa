import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string activeSection: "overview"
    property bool horizontal: false
    signal sectionRequested(string sectionId)

    readonly property var sections: [
        { id: "overview", icon: Icons.home, label: "\u603B\u89C8" },
        { id: "companion", icon: Icons.character, label: "\u89D2\u8272" },
        { id: "desktop", icon: Icons.monitor, label: "\u684C\u9762" },
        { id: "account", icon: Icons.cloud, label: "\u8D26\u53F7" },
        { id: "privacy", icon: Icons.lock, label: "\u9690\u79C1" }
    ]

    width: horizontal ? parent.width : 52
    height: horizontal ? 52 : parent.height
    color: Theme.color("apple.sidebar")

    Rectangle {
        visible: !horizontal
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: Theme.color("apple.hairline")
    }

    Rectangle {
        visible: horizontal
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.color("apple.hairline")
    }

    Column {
        visible: !horizontal
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 16
        spacing: 4

        Repeater {
            model: root.sections

            delegate: Item {
                id: railItem
                width: parent.width
                height: 44

                readonly property bool active: root.activeSection === modelData.id

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 3
                    height: active ? 20 : 0
                    radius: 1.5
                    color: Theme.color("accent.base")
                    opacity: active ? 1 : 0

                    Behavior on height { NumberAnimation { duration: 120 } }
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    radius: 8
                    color: railItem.active
                        ? Theme.color("apple.selection")
                        : (railMouse.containsMouse ? Theme.alpha("apple.selection", 0.55) : "transparent")

                    Behavior on color { ColorAnimation { duration: 100 } }

                    ShapeIcon {
                        anchors.centerIn: parent
                        pathData: modelData.icon
                        size: railItem.active ? 20 : 18
                        strokeWidth: railItem.active ? 1.72 : 1.58
                        iconColor: railItem.active ? Theme.color("accent.base") : Theme.color("text.secondary")
                    }
                }

                ToolTip {
                    visible: railMouse.containsMouse
                    delay: 280
                    text: modelData.label
                }

                MouseArea {
                    id: railMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.sectionRequested(modelData.id)
                }
            }
        }
    }

    Row {
        visible: horizontal
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 4
        spacing: 4

        Repeater {
            model: root.sections

            delegate: Item {
                id: railItemH
                width: (parent.width - parent.spacing * 4) / 5
                height: 44

                readonly property bool active: root.activeSection === modelData.id

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    radius: 8
                    color: railItemH.active
                        ? Theme.color("apple.selection")
                        : (railMouseH.containsMouse ? Theme.alpha("apple.selection", 0.55) : "transparent")

                    ShapeIcon {
                        anchors.centerIn: parent
                        pathData: modelData.icon
                        size: railItemH.active ? 20 : 18
                        strokeWidth: railItemH.active ? 1.72 : 1.58
                        iconColor: railItemH.active ? Theme.color("accent.base") : Theme.color("text.secondary")
                    }
                }

                MouseArea {
                    id: railMouseH
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.sectionRequested(modelData.id)
                }
            }
        }
    }
}
