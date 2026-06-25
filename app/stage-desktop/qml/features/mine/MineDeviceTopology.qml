import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property bool loggedIn: appController.accountLoggedIn
    property bool companionEnabled: appController.desktopCompanionEnabled

    signal connectPhone()

    readonly property string phoneStateText: loggedIn ? "\u53EF\u63A8\u9001" : "\u672A\u8FDE\u63A5"
    readonly property color phoneStateColor: loggedIn ? Theme.color("text.secondary") : Theme.color("text.tertiary")

    implicitHeight: topology.implicitHeight

    ColumnLayout {
        id: topology
        anchors.fill: parent
        spacing: 18

        Text {
            Layout.fillWidth: true
            text: "\u8BBE\u5907\u8FDE\u63A5"
            font.pixelSize: 13
            font.family: Theme.fontUi
            font.weight: Font.DemiBold
            color: Theme.color("apple.ink")
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 132
            spacing: 0

            DeviceNode {
                Layout.fillWidth: true
                title: "\u672C\u673A"
                subtitle: "OpenNeko Engine"
                iconPath: Icons.laptop
                stateText: companionEnabled ? "\u684C\u9762\u5E38\u9A7B" : "\u5C31\u7EEA"
                stateColor: companionEnabled ? Theme.color("state.success") : Theme.color("text.secondary")
                active: true
            }

            ConnectionLink {
                Layout.preferredWidth: 88
                Layout.fillHeight: true
                linked: loggedIn
            }

            DeviceNode {
                Layout.fillWidth: true
                title: "\u624B\u673A"
                subtitle: "NekoBuddy App"
                iconPath: Icons.smartphone
                stateText: phoneStateText
                stateColor: phoneStateColor
                active: loggedIn
            }
        }

        Text {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: loggedIn
                ? "\u767B\u5F55\u540E\u53EF\u5C06\u5F53\u524D\u540C\u4F34\u63A8\u9001\u81F3\u624B\u673A\uFF0C\u5C1A\u672A\u5EFA\u7ACB\u5B9E\u65F6\u914D\u5BF9\u8FDE\u63A5\u3002"
                : "\u624B\u673A\u672A\u8FDE\u63A5\u3002\u767B\u5F55\u540E\u53EF\u63A8\u9001\u540C\u4F34\u8D44\u6E90\u3002"
            font.pixelSize: 12
            font.family: Theme.fontUi
            color: Theme.color("apple.secondary")
            lineHeight: 1.45
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            ApplePrimaryButton {
                text: loggedIn ? "\u63A8\u9001\u5230\u624B\u673A" : "\u767B\u5F55\u5E76\u8FDE\u63A5"
                onTriggered: root.connectPhone()
            }
        }
    }

    component DeviceNode: Rectangle {
        id: node

        property string title: ""
        property string subtitle: ""
        property string iconPath: ""
        property string stateText: ""
        property color stateColor: Theme.color("text.secondary")
        property bool active: false

        radius: 12
        color: Theme.alpha("surface.sunken", Theme.isDark ? 0.42 : 0.72)
        border.color: node.active ? Theme.alpha("accent.base", 0.42) : Theme.alpha("line.soft", 0.72)
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 10
                color: Theme.alpha("surface.base", Theme.isDark ? 0.55 : 0.92)

                ShapeIcon {
                    anchors.centerIn: parent
                    pathData: node.iconPath
                    size: 18
                    iconColor: node.active ? Theme.color("accent.base") : Theme.color("text.secondary")
                }
            }

            Text {
                text: node.title
                font.pixelSize: 14
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: Theme.color("apple.ink")
            }

            Text {
                text: node.subtitle
                font.pixelSize: 11
                font.family: Theme.fontUi
                color: Theme.color("apple.tertiary")
            }

            RowLayout {
                spacing: 6

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: node.stateColor
                }

                Text {
                    text: node.stateText
                    font.pixelSize: 11
                    font.family: Theme.fontUi
                    font.weight: Font.Medium
                    color: node.stateColor
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    component ConnectionLink: Item {
        property bool linked: false

        Item {
            anchors.centerIn: parent
            width: parent.width
            height: 24

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                height: 2
                radius: 1
                color: linked ? Theme.alpha("state.success", 0.55) : Theme.color("apple.hairline")
            }

            ShapeIcon {
                anchors.centerIn: parent
                pathData: linked ? Icons.check : Icons.chevronRight
                size: 12
                iconColor: linked ? Theme.color("state.success") : Theme.color("text.tertiary")
            }
        }
    }
}
