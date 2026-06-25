import QtQuick
import QtQuick.Layouts
import NNA.Core 1.0

Item {
    id: root

    property string companionName: appController.characterName
    property bool loggedIn: appController.accountLoggedIn
    property bool fillHeight: false

    signal requestLogin()
    signal requestCompanionSection()
    signal requestAccountSection()
    signal requestDesktopSection()
    signal requestMemory()
    signal requestWorld()
    signal putOnDesktop()
    signal connectPhone()

    readonly property string accountValueText: loggedIn
        ? (appController.accountUserName !== "" ? appController.accountUserName : "\u5DF2\u767B\u5F55")
        : "\u672A\u767B\u5F55"

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: root.fillHeight ? 28 : 20
        anchors.rightMargin: root.fillHeight ? 28 : 20
        anchors.topMargin: root.fillHeight ? 52 : 44
        anchors.bottomMargin: 16
        spacing: root.fillHeight ? 24 : 20

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: root.fillHeight
            spacing: 28

            DesktopPreview {
                Layout.fillWidth: true
                Layout.fillHeight: root.fillHeight
                Layout.preferredWidth: Math.round(parent.width * 0.58)
                Layout.minimumHeight: root.fillHeight ? 300 : 240
                companionEnabled: appController.desktopCompanionEnabled
                companionName: root.companionName
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: root.fillHeight
                Layout.preferredWidth: Math.round(parent.width * 0.42)
                Layout.maximumWidth: 320
                spacing: 12

                Text {
                    Layout.fillWidth: true
                    text: root.companionName
                    font.pixelSize: 22
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("apple.ink")
                }

                Text {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: appController.desktopCompanionEnabled
                        ? "\u684C\u9762\u5E38\u9A7B\u5DF2\u5F00\u542F"
                        : "\u5DF2\u5728\u672C\u673A\u5C31\u7EEA\uFF0C\u53EF\u653E\u5230\u684C\u9762"
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    color: Theme.color("apple.secondary")
                    lineHeight: 1.4
                }

                MineFieldRow {
                    label: "\u6A21\u578B"
                    value: root.companionName
                    interactive: true
                    showChevron: true
                    onTriggered: root.requestCompanionSection()
                }

                MineFieldRow {
                    label: "\u684C\u9762\u5E38\u9A7B"
                    value: appController.desktopCompanionEnabled ? "\u5F00\u542F" : "\u5173\u95ED"
                    interactive: true
                    showChevron: true
                    onTriggered: root.requestDesktopSection()
                    AppleToggleSwitch {
                        checked: appController.desktopCompanionEnabled
                        onToggled: function(on) { appController.desktopCompanionEnabled = on }
                    }
                }

                MineFieldRow {
                    label: "\u624B\u673A"
                    value: loggedIn ? "\u53EF\u63A8\u9001" : "\u672A\u8FDE\u63A5"
                    interactive: true
                    showChevron: true
                    onTriggered: root.connectPhone()
                }

                MineFieldRow {
                    label: "\u4E91\u7AEF"
                    value: root.accountValueText
                    valueColor: loggedIn ? Theme.color("state.success") : Theme.color("apple.action")
                    interactive: true
                    showChevron: loggedIn
                    onTriggered: {
                        if (root.loggedIn)
                            root.requestAccountSection()
                        else
                            root.requestLogin()
                    }
                    AppleTextButton {
                        visible: !root.loggedIn
                        text: "\u767B\u5F55"
                        onTriggered: root.requestLogin()
                    }
                }

                MineFieldRow {
                    label: "\u8BB0\u5FC6"
                    value: "\u672C\u5730"
                    interactive: true
                    showChevron: true
                    onTriggered: root.requestMemory()
                }

                Item { Layout.fillHeight: true }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ApplePrimaryButton {
                text: appController.desktopCompanionEnabled ? "\u6536\u56DE\u684C\u9762" : "\u653E\u5230\u684C\u9762"
                onTriggered: root.putOnDesktop()
            }

            ApplePrimaryButton {
                text: "\u8FDE\u63A5\u624B\u673A"
                filled: false
                onTriggered: root.connectPhone()
            }

            Item { Layout.fillWidth: true }
        }
    }

    component DesktopPreview: Item {
        id: preview

        property bool companionEnabled: false
        property string companionName: "Lumia"

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: Theme.alpha("apple.ink", Theme.isDark ? 0.14 : 0.04)
            clip: true

            NNAAvatarCanvas {
                anchors.centerIn: parent
                width: Math.min(parent.width * 0.72, parent.height * 0.88)
                height: width * 1.12
                modelPath: appController.currentModelPath
                modelScale: 1.05
                modelOffsetY: 0.05
                visible: appController.currentModelPath !== ""
            }

            Text {
                anchors.centerIn: parent
                visible: appController.currentModelPath === ""
                text: preview.companionName.charAt(0)
                font.pixelSize: 48
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: Theme.color("apple.tertiary")
            }

            Rectangle {
                visible: preview.companionEnabled
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                width: 8
                height: 8
                radius: 4
                color: Theme.color("state.success")
            }
        }
    }
}
