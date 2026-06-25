import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    id: root
    readonly property int targetStageWidth: 735
    readonly property int targetStageHeight: 944

    width: targetStageWidth
    height: targetStageHeight + 38
    minimumWidth: 680
    minimumHeight: 820
    visible: false
    title: "OpenNeko Engine"
    flags: Qt.Window | Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint
    color: Theme.color("bg.canvas")
    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    readonly property bool isMacDesktop: Qt.platform.os === "osx"
        || Qt.platform.os === "macos"
        || Qt.platform.os === "darwin"
    readonly property real chromeLeadingInset: isMacDesktop
        ? Math.max(80, (typeof windowChromeLeadingInset !== "undefined" ? windowChromeLeadingInset : 0) + 6)
        : 16

    readonly property string helpIcon: "M9.09 9a3 3 0 1 1 5.83 1c0 2-3 3-3 3 M12 17h.01 M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20z"
    readonly property string syncIcon: "M21 12a9 9 0 0 1-15.5 6.2 M3 12A9 9 0 0 1 18.5 5.8 M18 3v4h-4 M6 21v-4h4"

    Rectangle {
        id: appChrome
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 38
        z: 50
        color: Theme.alpha("surface.float", Theme.isDark ? 0.86 : 0.82)

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: Theme.alpha("line.soft", Theme.isDark ? 0.60 : 0.72)
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                Layout.preferredWidth: root.chromeLeadingInset
                Layout.fillHeight: true
            }

            Text {
                visible: !root.isMacDesktop
                Layout.alignment: Qt.AlignVCenter
                text: "OpenNeko"
                font.pixelSize: 12
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: Theme.color("text.tertiary")
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                NNAAppNavSegment {
                    anchors.centerIn: parent
                    currentPage: shell.currentPage
                    onPageRequested: function(page) {
                        shell.closeOverlay()
                        shell.currentPage = page
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: 14
                spacing: 11

                ChromeIconButton {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    iconPath: root.helpIcon
                }

                ChromeIconButton {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    iconPath: root.syncIcon
                    onTriggered: {
                        if (appController.accountLoggedIn)
                            appController.refreshAccountProfile()
                    }
                }

                ChromeIconButton {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    iconPath: Icons.settings
                    onTriggered: shell.openSettings(0)
                }

                ChromeModeSwitch {
                    Layout.preferredWidth: 94
                    Layout.preferredHeight: 26
                    visible: shell.currentPage === 1
                }

                ChromeAvatar {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                }
            }
        }

        MouseArea {
            anchors.left: parent.left
            anchors.leftMargin: root.chromeLeadingInset
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            acceptedButtons: Qt.LeftButton
            z: -1
            onPressed: root.startSystemMove()
        }
    }

    NNAAppShell {
        id: shell
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: appChrome.bottom
        anchors.bottom: parent.bottom
    }

    DesktopCompanionWindow {
        id: companionWindow
        mainWindowRef: root
        shellRef: shell
        companionEnabled: appController.desktopCompanionEnabled
    }

    AgentWorkspaceWindow {
        id: agentWindow
        mainWindowRef: root
        companionWindowRef: companionWindow
        shellRef: shell
    }

    component ChromeIconButton: Rectangle {
        id: chromeButton
        property string iconPath: ""
        signal triggered()

        radius: width / 2
        color: chromeMouse.containsMouse ? Theme.alpha("surface.sunken", Theme.isDark ? 0.46 : 0.62) : "transparent"

        ShapeIcon {
            anchors.centerIn: parent
            pathData: chromeButton.iconPath
            size: 14
            iconColor: Theme.color("text.secondary")
        }

        MouseArea {
            id: chromeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: chromeButton.triggered()
        }
    }

    component ChromeAvatar: Rectangle {
        id: avatar

        radius: width / 2
        color: appController.accountLoggedIn ? Theme.color("accent.soft") : Theme.color("surface.sunken")
        border.color: Theme.alpha(appController.accountLoggedIn ? "accent.base" : "line.soft", 0.72)
        border.width: 1
        clip: true

        Image {
            id: avatarImage
            anchors.fill: parent
            source: appController.accountAvatarUrl
            fillMode: Image.PreserveAspectCrop
            visible: appController.accountAvatarUrl !== "" && status === Image.Ready
        }

        Text {
            anchors.centerIn: parent
            visible: appController.accountAvatarUrl === "" || avatarImage.status === Image.Error
            text: appController.accountLoggedIn && appController.accountUserName !== "" ? appController.accountUserName.charAt(0).toUpperCase() : "我"
            font.pixelSize: 14
            font.family: Theme.fontUi
            font.weight: Font.DemiBold
            color: Theme.color("accent.strong")
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: shell.openMineSection("overview")
        }
    }

    component ChromeModeSwitch: Rectangle {
        id: switcher

        radius: 10
        color: Theme.alpha("surface.sunken", Theme.isDark ? 0.44 : 0.54)
        border.color: Theme.alpha("line.soft", 0.76)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 2
            spacing: 2

            ModeOption {
                Layout.fillWidth: true
                text: "日常"
                active: shell.agentMode === "daily"
                onTriggered: shell.agentMode = "daily"
            }

            ModeOption {
                Layout.fillWidth: true
                text: "IDE"
                active: shell.agentMode === "ide"
                onTriggered: shell.agentMode = "ide"
            }
        }
    }

    component ModeOption: Rectangle {
        id: option
        property string text: ""
        property bool active: false
        signal triggered()

        Layout.fillHeight: true
        radius: 8
        color: active ? Theme.color("surface.base") : "transparent"
        border.color: active ? Theme.alpha("accent.base", 0.38) : "transparent"
        border.width: active ? 1 : 0

        Text {
            anchors.centerIn: parent
            text: option.text
            font.pixelSize: 11
            font.family: Theme.fontUi
            font.weight: option.active ? Font.DemiBold : Font.Medium
            color: option.active ? Theme.color("accent.strong") : Theme.color("text.secondary")
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: option.triggered()
        }
    }
}
