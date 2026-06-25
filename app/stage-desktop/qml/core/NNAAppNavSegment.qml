import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property int currentPage: 0
    signal pageRequested(int page)

    readonly property var tabs: [
        { label: "\u9996\u9875", page: 0 },
        { label: "Agent", page: 1 },
        { label: "\u6211\u7684", page: 2 }
    ]

    implicitWidth: row.implicitWidth + 8
    implicitHeight: 30

    Rectangle {
        anchors.fill: parent
        radius: 9
        color: Theme.alpha("surface.sunken", Theme.isDark ? 0.55 : 0.68)
        border.color: Theme.alpha("line.soft", 0.55)
        border.width: 1
    }

    RowLayout {
        id: row
        anchors.fill: parent
        anchors.margins: 3
        spacing: 2

        Repeater {
            model: root.tabs

            delegate: Rectangle {
                required property var modelData

                Layout.preferredHeight: 24
                Layout.preferredWidth: Math.max(58, label.implicitWidth + 22)
                radius: 7
                color: root.currentPage === modelData.page
                    ? Theme.alpha("surface.base", Theme.isDark ? 0.92 : 0.98)
                    : (tabMouse.containsMouse ? Theme.alpha("surface.base", 0.45) : "transparent")
                border.color: root.currentPage === modelData.page
                    ? Theme.alpha("line.soft", 0.65)
                    : "transparent"
                border.width: root.currentPage === modelData.page ? 1 : 0

                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: modelData.label
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    font.weight: root.currentPage === modelData.page ? Font.DemiBold : Font.Medium
                    color: root.currentPage === modelData.page
                        ? Theme.color("text.primary")
                        : Theme.color("text.secondary")
                }

                MouseArea {
                    id: tabMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.pageRequested(modelData.page)
                }
            }
        }
    }
}
