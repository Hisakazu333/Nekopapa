import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    Layout.preferredWidth: 180
    Layout.fillHeight: true
    color: Theme.color("surface.sunken")

    property int currentIndex: 0
    signal categorySelected(int index)

    readonly property var categories: [
        { label: "\u901A\u7528", icon: Icons.settings },
        { label: "\u5F15\u64CE", icon: Icons.zap },
        { label: "AI", icon: Icons.chat },
        { label: "\u9690\u79C1", icon: Icons.heart },
        { label: "\u684C\u5BA0", icon: Icons.paw },
        { label: "\u5173\u4E8E", icon: Icons.world }
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 16
        anchors.bottomMargin: 16
        spacing: 2

        Repeater {
            model: root.categories

            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: root.currentIndex === index
                    ? Theme.color("surface.raised")
                    : (itemMouse.containsMouse ? Theme.alpha("accent.base", 0.03) : "transparent")

                Rectangle {
                    visible: root.currentIndex === index
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 3
                    color: Theme.color("accent.strong")
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 12
                    spacing: 10

                    ShapeIcon {
                        pathData: modelData.icon
                        size: 18
                        iconColor: root.currentIndex === index
                            ? Theme.color("accent.strong")
                            : Theme.color("text.secondary")
                    }

                    Text {
                        text: modelData.label
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        font.weight: root.currentIndex === index ? Font.Bold : Font.Normal
                        color: root.currentIndex === index
                            ? Theme.color("text.primary")
                            : Theme.color("text.secondary")
                        Layout.fillWidth: true
                    }
                }

                MouseArea {
                    id: itemMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.categorySelected(index)
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
