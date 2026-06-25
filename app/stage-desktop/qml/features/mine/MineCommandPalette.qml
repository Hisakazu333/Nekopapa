import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root

    property var commandHost: null

    modal: true
    focus: true
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    anchors.centerIn: Overlay.overlay
    width: Math.min(560, Overlay.overlay ? Overlay.overlay.width - 80 : 560)

    readonly property var commands: [
        { id: "desktop", label: "\u653E\u5230\u684C\u9762", keywords: "desktop companion" },
        { id: "phone", label: "\u8FDE\u63A5\u624B\u673A", keywords: "phone mobile" },
        { id: "model", label: "\u5207\u6362\u6A21\u578B", keywords: "model live2d" },
        { id: "memory", label: "\u6253\u5F00\u8BB0\u5FC6", keywords: "memory soul" },
        { id: "world", label: "\u6253\u5F00\u4E16\u754C", keywords: "world" },
        { id: "settings", label: "\u6253\u5F00\u5F15\u64CE\u8BBE\u7F6E", keywords: "settings engine" },
        { id: "login", label: "\u767B\u5F55\u8D26\u53F7", keywords: "login account" },
        { id: "overview", label: "\u8FD4\u56DE\u603B\u89C8", keywords: "overview home" }
    ]

    function filteredCommands() {
        var query = searchField.text.trim().toLowerCase()
        if (query === "")
            return commands
        var result = []
        for (var i = 0; i < commands.length; ++i) {
            var item = commands[i]
            if (item.label.toLowerCase().indexOf(query) >= 0
                    || item.keywords.toLowerCase().indexOf(query) >= 0)
                result.push(item)
        }
        return result
    }

    function runCommand(commandId) {
        if (!commandHost)
            return
        switch (commandId) {
        case "desktop":
            appController.desktopCompanionEnabled = !appController.desktopCompanionEnabled
            break
        case "phone":
            commandHost.connectMobileDevice()
            break
        case "model":
            commandHost.scrollToMineSection("companion")
            break
        case "memory":
            commandHost.scrollToMineSection("memory")
            break
        case "world":
            commandHost.scrollToMineSection("world")
            break
        case "settings":
            commandHost.openEngineSettings(0)
            break
        case "login":
            commandHost.openLoginDialog()
            break
        case "overview":
            commandHost.scrollToMineSection("overview")
            break
        }
        root.close()
    }

    onOpened: {
        searchField.text = ""
        searchField.forceActiveFocus()
        listView.currentIndex = 0
    }

    background: Rectangle {
        radius: 14
        color: Theme.alpha("surface.float", Theme.isDark ? 0.96 : 0.98)
        border.color: Theme.alpha("line.soft", 0.82)
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            radius: 14
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 10
                spacing: 10

                ShapeIcon {
                    pathData: Icons.search
                    size: 16
                    iconColor: Theme.color("text.tertiary")
                }

                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: "\u641C\u7D22\u547D\u4EE4\u2026"
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    color: Theme.color("text.primary")
                    background: null
                    onTextChanged: listView.currentIndex = 0
                    Keys.onDownPressed: listView.incrementCurrentIndex()
                    Keys.onUpPressed: listView.decrementCurrentIndex()
                    Keys.onReturnPressed: {
                        var items = filteredCommands()
                        if (items.length > 0)
                            runCommand(items[listView.currentIndex].id)
                    }
                }

                Text {
                    text: "ESC"
                    font.pixelSize: 10
                    font.family: Theme.fontUi
                    color: Theme.color("text.tertiary")
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: Theme.color("apple.hairline")
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(320, Math.max(1, count) * 44)
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: filteredCommands()
            currentIndex: 0

            delegate: Rectangle {
                width: listView.width
                height: 44
                color: ListView.isCurrentItem || rowMouse.containsMouse
                    ? Theme.alpha("apple.selection", ListView.isCurrentItem ? 1 : 0.65)
                    : "transparent"

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.label
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    font.weight: ListView.isCurrentItem ? Font.DemiBold : Font.Medium
                    color: Theme.color("apple.ink")
                }

                MouseArea {
                    id: rowMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.runCommand(modelData.id)
                }
            }
        }
    }
}
