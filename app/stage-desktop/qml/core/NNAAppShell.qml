import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import NNA.Core 1.0

Item {
    id: shell

    property int currentPage: 0
    property int overlayPanel: -1
    property string agentMode: "ide"
    readonly property real designWidth: 735
    readonly property real designHeight: 944
    readonly property real stageAspect: designWidth / designHeight
    readonly property real fittedStageWidth: Math.min(width, height * stageAspect)
    readonly property real fittedStageHeight: Math.min(height, width / stageAspect)
    readonly property real stageWidth: Math.round(fittedStageWidth)
    readonly property real stageHeight: Math.round(fittedStageHeight)
    readonly property real stageX: Math.round((width - stageWidth) / 2)
    readonly property real stageY: Math.round((height - stageHeight) / 2)
    readonly property real stageScale: Math.max(0.82, Math.min(1.35, stageWidth / designWidth, stageHeight / designHeight))
    readonly property real widthCompactProgress: smoothStep((960 - width) / 160)
    readonly property real heightCompactProgress: smoothStep((860 - height) / 180)
    readonly property real aspectCompactProgress: smoothStep((1.08 - (width / Math.max(1, height))) / 0.22)
    readonly property real shapeCompactProgress: Math.max(widthCompactProgress, aspectCompactProgress)
    readonly property real compactProgress: Math.max(shapeCompactProgress, heightCompactProgress)
    readonly property real compactScale: Math.max(0.1, Math.min(1.0, width / designWidth, height / designHeight))
    readonly property real layoutWidth: mix(width, designWidth, shapeCompactProgress)
    readonly property real layoutHeight: mix(height, designHeight, compactProgress)
    readonly property real layoutScale: mix(1.0, compactScale, compactProgress)
    readonly property real shellRailWidth: desktopLayout.shellRailWidth
    readonly property real contentBottomInset: desktopLayout.contentBottomInset

    property bool settingsPanelOpen: false

    readonly property var navItems: [
        { label: "\u9996\u9875", icon: Icons.home },
        { label: "Agent", icon: Icons.ability },
        { label: "\u6211\u7684", icon: Icons.character }
    ]

    readonly property bool chatOpen: overlayPanel === 0
    readonly property bool sideOverlayOpen: overlayPanel === 1 || overlayPanel === 2

    NNADesktopLayoutMetrics {
        id: desktopLayout
        windowWidth: shell.width
        windowHeight: shell.height
        contentMaxWidth: 1168
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.color("bg.canvas")
    }

    Item {
        id: contentStage
        anchors.fill: parent

    Item {
        id: homeStage
        anchors.fill: parent
        visible: shell.currentPage === 0 && !shell.chatOpen
        clip: true

        HomeView {
            id: homeView
            anchors.fill: parent
            shellRef: shell
            dockClearance: shell.contentBottomInset
        }
    }

    ChatView {
        id: chatView
        anchors.fill: parent
        dockClearance: shell.contentBottomInset
        visible: shell.chatOpen
        opacity: visible ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: 180 } }
    }

    NNAMineView {
        id: mineView
        anchors.fill: parent
        shellRef: shell
        dockClearance: shell.contentBottomInset
        desktopSidebarWidth: 0
        desktopContentWidth: desktopLayout.contentWidth
        desktopContentGutter: desktopLayout.contentGutter
        visible: shell.currentPage === 2
        opacity: visible ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: 180 } }
    }

    AgentView {
        id: agentView
        anchors.fill: parent
        dockClearance: shell.contentBottomInset
        shellRef: shell
        mode: shell.agentMode
        visible: shell.currentPage === 1
        opacity: visible ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: 180 } }
    }
    }

    Rectangle {
        anchors.fill: parent
        visible: sideOverlayOpen
        color: Theme.alpha("overlay.scrim", Theme.isDark ? 0.32 : 0.12)
        opacity: sideOverlayOpen ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: 180 } }

        MouseArea {
            anchors.fill: parent
            onClicked: shell.closeOverlay()
        }
    }

    Rectangle {
        id: workspacePanel
        width: panelWidth(shell.overlayPanel)
        height: parent.height - 128
        x: sideOverlayOpen ? parent.width - width - 28 : parent.width + 40
        y: 34
        radius: 34
        color: Theme.alpha("surface.base", Theme.isDark ? 0.96 : 0.95)
        border.color: Theme.alpha("line.soft", 0.80)
        border.width: 1
        opacity: sideOverlayOpen ? 1 : 0
        visible: opacity > 0
        clip: true

        Behavior on x { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 180 } }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: Theme.alpha("surface.raised", Theme.isDark ? 0.88 : 0.96) }
                GradientStop { position: 1.0; color: Theme.alpha("surface.base", Theme.isDark ? 0.96 : 0.98) }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 56

                Text {
                    Layout.fillWidth: true
                    text: panelTitle(shell.overlayPanel)
                    font.pixelSize: 24
                    font.family: Theme.fontUi
                    font.weight: Font.Black
                    color: Theme.color("text.primary")
                }

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: Theme.alpha("surface.sunken", Theme.isDark ? 0.58 : 0.76)
                    border.color: Theme.alpha("line.soft", 0.72)
                    border.width: 1

                    ShapeIcon {
                        anchors.centerIn: parent
                        pathData: Icons.close
                        size: 15
                        iconColor: Theme.color("text.secondary")
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shell.closeOverlay()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 26
                color: Theme.alpha("surface.raised", Theme.isDark ? 0.82 : 0.94)
                border.color: Theme.alpha("line.soft", 0.76)
                border.width: 1
                clip: true

                StackLayout {
                    anchors.fill: parent
                    currentIndex: panelIndex(shell.overlayPanel)

                    SoulView {}
                    WorldView {}
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        visible: settingsPanelOpen
        z: 1200

        Rectangle {
            anchors.fill: parent
            color: Theme.alpha("overlay.scrim", Theme.isDark ? 0.36 : 0.14)

            MouseArea {
                anchors.fill: parent
                onClicked: shell.closeSettings()
            }
        }

        Rectangle {
            width: Math.min(parent.width - 56, 920)
            height: parent.height - 72
            anchors.centerIn: parent
            radius: 14
            color: Theme.color("bg.canvas")
            border.color: Theme.color("apple.hairline")
            border.width: 1
            clip: true

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onPressed: function(mouse) { mouse.accepted = false }
            }

            SettingsView {
                id: engineSettingsPanel
                anchors.fill: parent
            }

            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 12
                width: 32
                height: 32
                radius: 16
                color: closeSettingsMouse.containsMouse
                    ? Theme.color("apple.selection")
                    : "transparent"

                ShapeIcon {
                    anchors.centerIn: parent
                    pathData: Icons.close
                    size: 14
                    iconColor: Theme.color("apple.secondary")
                }

                MouseArea {
                    id: closeSettingsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: shell.closeSettings()
                }
            }
        }
    }

    function navMenuItems(page) {
        switch (page) {
        case 0:
            return [
                { label: "\u6253\u5F00\u9996\u9875", action: 0 },
                { label: "\u684C\u5BA0\u5F00\u5173", action: 1 },
                { label: "\u6A21\u578B\u7BA1\u7406", action: 2 },
                { label: "\u59FF\u6001\u6821\u51C6", action: 3 }
            ]
        case 1:
            return [
                { label: "\u6253\u5F00 Agent", action: 0 },
                { label: "\u5DE5\u5177\u4E2D\u5FC3", action: 1 },
                { label: "\u8FD0\u884C\u65E5\u5FD7", action: 2 },
                { label: "\u81EA\u52A8\u5316\u4EFB\u52A1", action: 3 }
            ]
        case 2:
            return [
                { label: "\u6253\u5F00\u6211\u7684\u9875", action: 0 },
                { label: "\u8D26\u53F7\u540C\u6B65", action: 1 },
                { label: "\u8BBE\u7F6E\u4E2D\u5FC3", action: 2 },
                { label: "\u9690\u79C1\u4E0E\u6570\u636E", action: 3 }
            ]
        default:
            return []
        }
    }

    function panelIndex(panel) {
        return panel === 2 ? 1 : 0
    }

    function panelTitle(panel) {
        switch (panel) {
        case 1: return "\u8BB0\u5FC6"
        case 2: return "\u4E16\u754C"
        default: return "\u8BB0\u5FC6"
        }
    }

    function panelWidth(panel) {
        if (panel === 1)
            return Math.min(width * 0.42, 560)
        return Math.min(width * 0.52, 720)
    }

    function openOverlay(panel) {
        overlayPanel = panel
    }

    function closeOverlay() {
        overlayPanel = -1
    }

    function openMineSection(sectionId) {
        closeOverlay()
        currentPage = 2
        Qt.callLater(function() {
            if (mineView)
                mineView.scrollToMineSection(sectionId)
        })
    }

    function openSettings(categoryIndex) {
        settingsPanelOpen = true
        Qt.callLater(function() {
            if (engineSettingsPanel)
                engineSettingsPanel.openCategory(categoryIndex)
        })
    }

    function closeSettings() {
        settingsPanelOpen = false
    }

    function clamp01(value) {
        return Math.max(0, Math.min(1, value))
    }

    function smoothStep(value) {
        var t = clamp01(value)
        return t * t * (3 - 2 * t)
    }

    function mix(from, to, progress) {
        return from + (to - from) * clamp01(progress)
    }

    function handleDockMenuAction(page, action) {
        switch (page) {
        case 0:
            if (action === 0) {
                closeOverlay()
                currentPage = 0
            } else if (action === 1) {
                appController.desktopCompanionEnabled = !appController.desktopCompanionEnabled
            } else if (action === 2 || action === 3) {
                homeView.openModelAdjustDrawer()
            }
            break
        case 1:
            if (action === 0) {
                closeOverlay()
                currentPage = 1
            }
            break
        case 2:
            if (action === 0) {
                openMineSection("overview")
            } else if (action === 1) {
                if (appController.accountLoggedIn)
                    mineView.refreshProfile()
                else
                    mineView.openLoginDialog()
            } else if (action === 2) {
                openSettings(0)
            } else if (action === 3) {
                openMineSection("privacy")
            }
            break
        default:
            break
        }
    }
}
