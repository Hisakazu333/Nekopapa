import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

Rectangle {
    id: root

    property var shellRef: null
    property var mineRef: null

    readonly property bool mineMode: shellRef && shellRef.currentPage === 2

    readonly property var mineSections: [
        { id: "overview", icon: Icons.home, label: "\u603B\u89C8" },
        { id: "companion", icon: Icons.character, label: "\u89D2\u8272" },
        { id: "desktop", icon: Icons.monitor, label: "\u684C\u9762" },
        { id: "account", icon: Icons.cloud, label: "\u8D26\u53F7" },
        { id: "privacy", icon: Icons.lock, label: "\u9690\u79C1" }
    ]

    color: Theme.color("apple.sidebar")

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: Theme.color("apple.hairline")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 14
        anchors.bottomMargin: 12
        spacing: 4

        Repeater {
            model: shellRef ? shellRef.navItems : []

            delegate: NavSlot {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                label: modelData.label
                iconPath: modelData.icon
                active: shellRef && shellRef.currentPage === index
                pageIndex: index
                contextMenuModel: shellRef ? shellRef.navMenuItems(index) : []
                onTriggered: {
                    if (!shellRef)
                        return
                    shellRef.closeOverlay()
                    shellRef.currentPage = index
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.preferredHeight: root.mineMode ? 1 : 0
            visible: root.mineMode
            color: Theme.color("apple.hairline")
        }

        Repeater {
            model: root.mineMode ? root.mineSections : []

            delegate: NavSlot {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                label: modelData.label
                iconPath: modelData.icon
                compactLabel: true
                active: mineRef && mineRef.activeMineSection === modelData.id
                onTriggered: {
                    if (mineRef)
                        mineRef.scrollToMineSection(modelData.id)
                }
            }
        }

        Item { Layout.fillHeight: true }

        MineAccountChip {
            Layout.fillWidth: true
            Layout.preferredHeight: root.mineMode ? 48 : 0
            visible: root.mineMode
            mineRef: root.mineRef
        }
    }

    component NavSlot: Item {
        id: slot
        property string label: ""
        property string iconPath: ""
        property bool active: false
        property bool compactLabel: false
        property var contextMenuModel: []
        property int pageIndex: -1
        signal triggered()

        implicitHeight: 52

        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            radius: 10
            color: slot.active
                ? Theme.color("apple.selection")
                : (slotMouse.containsMouse ? Theme.alpha("apple.selection", 0.55) : "transparent")

            Behavior on color { ColorAnimation { duration: 100 } }
        }

        Rectangle {
            visible: slot.active
            anchors.left: parent.left
            anchors.leftMargin: 6
            anchors.verticalCenter: parent.verticalCenter
            width: 3
            height: compactLabel ? 16 : 20
            radius: 1.5
            color: Theme.color("accent.base")
        }

        Column {
            anchors.centerIn: parent
            spacing: compactLabel ? 2 : 4

            ShapeIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                pathData: slot.iconPath
                size: slot.active ? 20 : 18
                strokeWidth: slot.active ? 1.72 : 1.58
                iconColor: slot.active ? Theme.color("accent.base") : Theme.color("text.secondary")
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: slot.label
                font.pixelSize: compactLabel ? 9 : 10
                font.family: Theme.fontUi
                font.weight: slot.active ? Font.DemiBold : Font.Medium
                color: slot.active ? Theme.color("accent.strong") : Theme.color("text.secondary")
            }
        }

        ToolTip {
            visible: slotMouse.containsMouse
            delay: 260
            text: slot.label
        }

        MouseArea {
            id: slotMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton && slot.contextMenuModel.length > 0) {
                    slotContextMenu.popup()
                    return
                }
                slot.triggered()
            }
        }

        Menu {
            id: slotContextMenu

            Repeater {
                model: slot.contextMenuModel

                delegate: MenuItem {
                    text: modelData.label
                    onTriggered: {
                        if (shellRef)
                            shellRef.handleDockMenuAction(slot.pageIndex, modelData.action)
                    }
                }
            }
        }
    }

    component MineAccountChip: Rectangle {
        id: chip
        property var mineRef: null

        radius: 10
        color: chipMouse.containsMouse ? Theme.color("apple.selection") : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 14
                color: appController.accountLoggedIn ? Theme.color("accent.soft") : Theme.color("surface.sunken")
                clip: true

                Text {
                    anchors.centerIn: parent
                    text: appController.accountLoggedIn && appController.accountUserName !== ""
                        ? appController.accountUserName.charAt(0).toUpperCase()
                        : "\u6211"
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("accent.strong")
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: appController.accountLoggedIn
                        ? (appController.accountUserName !== "" ? appController.accountUserName : "\u5DF2\u767B\u5F55")
                        : "\u672A\u767B\u5F55"
                    font.pixelSize: 11
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("apple.ink")
                }

                Text {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: appController.accountLoggedIn ? "\u8D26\u53F7" : "\u70B9\u6309\u767B\u5F55"
                    font.pixelSize: 10
                    font.family: Theme.fontUi
                    color: Theme.color("apple.tertiary")
                }
            }
        }

        MouseArea {
            id: chipMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!chip.mineRef)
                    return
                if (appController.accountLoggedIn)
                    chip.mineRef.scrollToMineSection("account")
                else
                    chip.mineRef.openLoginDialog()
            }
        }
    }
}
