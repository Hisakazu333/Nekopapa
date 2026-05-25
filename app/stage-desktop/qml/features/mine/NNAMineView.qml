import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import NNA.Core 1.0

Item {
    id: root

    property real dockClearance: 0
    property real desktopSidebarWidth: Math.round(Math.min(336, Math.max(width < 980 ? 236 : 260, width * 0.20)))
    property real desktopContentGutter: width < 1120 ? 24 : 38
    property real desktopContentWidth: Math.round(Math.min(Math.max(1, width - desktopSidebarWidth - 1 - desktopContentGutter * 2), 1168))
    property string activeMineSection: "overview"
    property real desktopModelScale: 1.20
    property bool desktopAlwaysOnTop: false
    property bool desktopClickThrough: false
    property bool desktopQuietMode: false
    readonly property bool loggedIn: appController.accountLoggedIn
    readonly property bool compact: width < 760
    readonly property string displayName: appController.accountUserName !== "" ? appController.accountUserName : (loggedIn ? "Neko Buddy" : "未登录")
    readonly property string accountSubtitle: loggedIn
        ? (appController.accountUserId > 0 ? ("UID " + appController.accountUserId) : "账号已登录")
        : "本地模式"
    readonly property color pageMaterial: Theme.color("bg.canvas")
    readonly property color sidebarMaterial: Theme.color("bg.sidebar")
    readonly property color contentMaterial: Theme.color("bg.canvas")
    readonly property color groupMaterial: Theme.color("surface.base")
    readonly property color hairline: Theme.color("line.soft")
    readonly property color sidebarHover: Theme.isDark ? Theme.alpha("surface.raised", 0.72) : Theme.alpha("surface.float", 0.96)
    readonly property color sidebarSearch: Theme.color("surface.float")
    readonly property color rowHoverMaterial: Theme.isDark ? Theme.alpha("surface.raised", 0.68) : Theme.alpha("surface.sunken", 0.82)
    readonly property color rowPressedMaterial: Theme.isDark ? "#2E1822" : Theme.alpha("accent.soft", 0.62)
    readonly property color dialogMaterial: Theme.color("surface.float")
    readonly property color dialogStroke: Theme.color("line.soft")
    readonly property color accountAccent: Theme.color("accent.strong")
    readonly property color accountAccentMuted: Theme.alpha("accent.soft", Theme.isDark ? 0.24 : 0.70)
    readonly property color selectionAccent: accountAccent
    readonly property color dialogShadowColor: Theme.alpha("overlay.scrim", Theme.isDark ? 0.42 : 0.12)
    readonly property color appleBlue: "#0066CC"
    readonly property color appleBlueSoft: "#EAF3FF"
    readonly property color appleInk: "#1D1D1F"
    readonly property color appleCanvas: "#F5F5F7"
    readonly property color appleHairline: "#DADCE0"

    function tint(c, opacity) {
        return Qt.rgba(c.r, c.g, c.b, opacity)
    }

    function openLoginDialog() {
        loginDialog.open()
    }

    function refreshProfile() {
        appController.refreshAccountProfile()
    }

    function scrollToSettings() {
        if (mainContentLoader.item && mainContentLoader.item.scrollToBottom)
            mainContentLoader.item.scrollToBottom()
    }

    function scrollToMineSection(sectionId) {
        root.activeMineSection = sectionId
        if (mainContentLoader.item && mainContentLoader.item.scrollToSection)
            mainContentLoader.item.scrollToSection(sectionId)
    }

    function currentModelName() {
        var models = modelManager.modelList || []
        for (var i = 0; i < models.length; ++i) {
            if (models[i].id === modelManager.currentModelId)
                return models[i].name || appController.characterName
        }
        return appController.characterName || "Hiyori Pro 中文版"
    }

    function companionDisplayName() {
        var name = currentModelName()
        if (name === "hiyori_pro_zh" || name === "preset:hiyori_pro_zh")
            return "Hiyori Pro 中文版"
        return name
    }

    Rectangle {
        anchors.fill: parent
        color: root.pageMaterial
    }

    Loader {
        id: mainContentLoader
        anchors.fill: parent
        sourceComponent: root.compact ? compactLayoutComponent : desktopLayoutComponent
    }

    component DesktopLayout: Item {
        function scrollToBottom() {
            accountContent.scrollToBottom()
        }

        function scrollToSection(sectionId) {
            accountContent.scrollToSection(sectionId)
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            AccountSidebar {
                Layout.preferredWidth: root.desktopSidebarWidth
                Layout.fillHeight: true
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: root.hairline
            }

            AccountContent {
                id: accountContent
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    component CompactLayout: ScrollView {
        id: compactScroll

        function scrollToBottom() {
            contentItem.contentY = Math.max(0, contentItem.contentHeight - height)
        }

        function scrollToSection(sectionId) {
            if (compactAccountContent.scrollToSection)
                compactAccountContent.scrollToSection(sectionId)
        }

        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 16
        anchors.bottomMargin: 0
        clip: true
        contentWidth: availableWidth
        contentHeight: compactStack.implicitHeight + root.dockClearance + 42
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        ColumnLayout {
            id: compactStack
            width: compactScroll.availableWidth
            spacing: 14

            AccountSidebar {
                Layout.fillWidth: true
                Layout.preferredHeight: 318
            }

            AccountContent {
                id: compactAccountContent
                Layout.fillWidth: true
                Layout.preferredHeight: 980
            }
        }
    }

    Component {
        id: desktopLayoutComponent
        DesktopLayout {}
    }

    Component {
        id: compactLayoutComponent
        CompactLayout {}
    }

    component AccountSidebar: Rectangle {
        id: sidebar

        color: root.sidebarMaterial
        radius: 0
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            anchors.topMargin: root.compact ? 16 : 28
            anchors.bottomMargin: root.compact ? 16 : 20
            spacing: 0

            SidebarProfileHeader {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
            }

            SearchField {
                Layout.fillWidth: true
                Layout.topMargin: 26
                Layout.preferredHeight: 34
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 24
                spacing: 10

                SidebarNavRow {
                    label: "总览"
                    iconPath: Icons.home
                    active: root.activeMineSection === "overview"
                    onTriggered: root.scrollToMineSection("overview")
                }
                SidebarNavRow {
                    label: "同伴"
                    iconPath: Icons.cat
                    active: root.activeMineSection === "companion"
                    onTriggered: root.scrollToMineSection("companion")
                }
                SidebarNavRow {
                    label: "桌面常驻"
                    iconPath: Icons.monitor
                    active: root.activeMineSection === "desktop"
                    onTriggered: root.scrollToMineSection("desktop")
                }
                SidebarNavRow {
                    label: "同步"
                    iconPath: Icons.cloud
                    active: root.activeMineSection === "sync"
                    onTriggered: root.scrollToMineSection("sync")
                }
                SidebarNavRow {
                    label: "隐私"
                    iconPath: Icons.lock
                    active: root.activeMineSection === "privacy"
                    onTriggered: root.scrollToMineSection("privacy")
                }
                SidebarNavRow {
                    label: "关于"
                    iconPath: Icons.infoCircle
                    active: root.activeMineSection === "about"
                    onTriggered: root.scrollToMineSection("about")
                }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                spacing: 14

                SidebarIconButton {
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    iconPath: Icons.sun
                }

                SidebarIconButton {
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    iconPath: Icons.settings
                }

                Item { Layout.fillWidth: true }
            }
        }
    }

    component SidebarProfileHeader: Rectangle {
        id: profile

        color: "transparent"

        RowLayout {
            anchors.fill: parent
            spacing: 10

            AvatarBubble {
                Layout.preferredWidth: 54
                Layout.preferredHeight: 54
                compactAvatar: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: root.loggedIn ? root.displayName : "小猫酱"
                    elide: Text.ElideRight
                    font.pixelSize: 15
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.primary")
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    StatusDot {
                        active: root.loggedIn
                        Layout.preferredWidth: 8
                        Layout.preferredHeight: 8
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.accountSubtitle
                        elide: Text.ElideRight
                        font.pixelSize: 12
                        font.family: Theme.fontUi
                        color: Theme.color("text.secondary")
                    }
                }
            }

            ShapeIcon {
                pathData: Icons.chevronDown
                size: 14
                strokeWidth: 1.62
                iconColor: Theme.color("text.secondary")
            }
        }
    }

    component SidebarIconButton: Rectangle {
        id: button
        property string iconPath: ""

        radius: 10
        color: buttonMouse.containsMouse ? Theme.alpha("surface.base", Theme.isDark ? 0.36 : 0.82) : "transparent"

        ShapeIcon {
            anchors.centerIn: parent
            pathData: button.iconPath
            size: 20
            strokeWidth: 1.66
            iconColor: Theme.color("text.primary")
        }

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }

    component AccountContent: Item {
        id: content

        function scrollToBottom() {
            accountScroll.contentItem.contentY = Math.max(0, accountScroll.contentItem.contentHeight - accountScroll.height)
        }

        function scrollToSection(sectionId) {
            var target = overviewSection
            if (sectionId === "companion") target = companionSection
            else if (sectionId === "desktop") target = desktopSection
            else if (sectionId === "sync") target = syncSection
            else if (sectionId === "privacy") target = privacySection
            else if (sectionId === "about") target = privacySection

            root.activeMineSection = sectionId
            var mapped = target.mapToItem(scrollHost, 0, 0)
            var topInset = sectionId === "overview" ? 26 : 22
            accountScroll.contentItem.contentY = Math.max(0, Math.min(mapped.y - topInset, accountScroll.contentItem.contentHeight - accountScroll.height))
        }

        Rectangle {
            anchors.fill: parent
            color: root.contentMaterial
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            ScrollView {
                id: accountScroll
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: availableWidth
                contentHeight: scrollHost.height
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Item {
                    id: scrollHost
                    width: accountScroll.availableWidth
                    readonly property real bottomNavigationPad: root.compact
                        ? Math.max(96, root.height * 0.30)
                        : Math.max(root.dockClearance, 150)
                    height: accountColumn.implicitHeight + bottomNavigationPad

                    ColumnLayout {
                        id: accountColumn
                        width: root.compact
                            ? Math.max(1, parent.width - 24)
                            : Math.min(root.desktopContentWidth, Math.max(1, parent.width - root.desktopContentGutter * 2))
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: root.compact ? 18 : 32
                        spacing: 36

                        CompanionOverviewPanel {
                            id: overviewSection
                            Layout.fillWidth: true
                        }

                        SectionHeader {
                            id: companionSection
                            Layout.fillWidth: true
                            eyebrow: "MODELS"
                            title: "同伴库"
                            subtitle: "选一个 Live2D 形象，或导入你自己的模型。"
                            actionText: "管理模型"
                            onActionTriggered: root.scrollToMineSection("companion")
                        }

                        ModelLibraryStrip {
                            Layout.fillWidth: true
                        }

                        SectionHeader {
                            id: desktopSection
                            Layout.fillWidth: true
                            eyebrow: "DESKTOP"
                            title: "桌面行为"
                            subtitle: "决定它在桌面上的呈现方式。"
                        }

                        DesktopBehaviorGrid {
                            Layout.fillWidth: true
                        }

                        SectionHeader {
                            id: syncSection
                            Layout.fillWidth: true
                            eyebrow: "ACCOUNT"
                            title: "账号与同步"
                            subtitle: root.loggedIn ? "OpenNeko Cloud 已连接。" : "登录后可在多台设备间同步记忆与设置。"
                            actionText: root.loggedIn ? "管理账号" : "登录"
                            onActionTriggered: root.loggedIn ? root.scrollToMineSection("sync") : root.openLoginDialog()
                        }

                        NNASettingGroup {
                            Layout.fillWidth: true
                            title: ""

                            NNASettingRow {
                                iconPath: Icons.character
                                title: root.loggedIn ? root.displayName : "未登录"
                                subtitle: root.loggedIn
                                    ? (appController.accountUserId > 0 ? ("UID " + appController.accountUserId) : "本地账号")
                                    : "本地模式 · 仅在此设备保存"
                                valueText: root.loggedIn ? "已连接" : "登录"
                                valueColor: root.loggedIn ? Theme.color("state.success") : Theme.color("accent.strong")
                                onTriggered: if (!root.loggedIn) root.openLoginDialog()
                            }
                            SettingsDivider {}
                            NNASettingRow {
                                iconPath: Icons.sparkle
                                title: "云端点数"
                                subtitle: "用于同步、AI 调用与限时模型"
                                valueText: Number(appController.accountCloudPointBalance).toFixed(0) + " 点"
                                showChevron: false
                                interactive: false
                            }
                            SettingsDivider {}
                            NNASettingRow {
                                iconPath: Icons.iot
                                title: "本地优先"
                                subtitle: "优先使用本地数据，离线也能正常使用"
                                showChevron: false
                                interactive: true

                                AppleSwitch {
                                    checked: true
                                }
                            }
                        }

                        SectionHeader {
                            id: privacySection
                            Layout.fillWidth: true
                            eyebrow: "PRIVACY"
                            title: "隐私与数据"
                            subtitle: "数据默认只存在本地。导出、清理都在你这一端。"
                        }

                        NNASettingGroup {
                            Layout.fillWidth: true
                            title: ""

                            NNASettingRow {
                                iconPath: Icons.settings
                                title: "权限管理"
                                subtitle: "麦克风、摄像头、文件访问"
                            }
                            SettingsDivider {}
                            NNASettingRow {
                                iconPath: Icons.memory
                                title: "数据与存储"
                                subtitle: "清理缓存、导出、删除全部数据"
                            }
                            SettingsDivider {}
                            NNASettingRow {
                                iconPath: Icons.bell
                                title: "通知"
                                subtitle: "陪伴提醒、状态广播"
                                showChevron: false
                                interactive: true

                                AppleSwitch {
                                    checked: true
                                }
                            }
                        }

                        AboutFooter {
                            Layout.fillWidth: true
                            Layout.topMargin: 8
                        }
                    }
                }
            }
        }
    }

    component MainToolbar: Rectangle {
        color: root.contentMaterial

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: root.compact ? 14 : 18
            anchors.rightMargin: root.compact ? 14 : 18
            spacing: 12

            NavigationStepper {
                Layout.preferredWidth: 74
                Layout.preferredHeight: 30
            }

            Text {
                Layout.fillWidth: true
                text: "我的"
                elide: Text.ElideRight
                font.pixelSize: 14
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: Theme.color("text.primary")
            }

            NNABaseButton {
                Layout.preferredWidth: root.loggedIn ? 92 : 88
                Layout.preferredHeight: 32
                text: root.loggedIn ? "刷新" : "登录"
                iconPath: root.loggedIn ? Icons.refresh : Icons.user
                enabled: !appController.syncBusy
                buttonType: NNABaseButton.ButtonType.Secondary
                onClicked: root.loggedIn ? root.refreshProfile() : root.openLoginDialog()
            }
        }
    }

    component NavigationStepper: Rectangle {
        radius: 11
        color: Theme.color("surface.base")
        border.color: root.hairline
        border.width: 1

        RowLayout {
            anchors.fill: parent
            spacing: 0

            ToolbarIconButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                iconPath: Icons.chevronLeft
                enabledButton: false
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: root.hairline
            }

            ToolbarIconButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                iconPath: Icons.chevronRight
                enabledButton: false
            }
        }
    }

    component ToolbarIconButton: Rectangle {
        id: tool
        property string iconPath: ""
        property bool enabledButton: true

        color: iconMouse.containsMouse && enabledButton ? Theme.alpha("surface.raised", 0.78) : "transparent"
        opacity: enabledButton ? 1 : 0.42

        ShapeIcon {
            anchors.centerIn: parent
            pathData: tool.iconPath
            size: 13
            iconColor: Theme.color("text.secondary")
        }

        MouseArea {
            id: iconMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: tool.enabledButton ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }

    component SearchField: Rectangle {
        radius: 7
        color: root.sidebarSearch
        border.color: root.hairline
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 9

            ShapeIcon {
                pathData: Icons.search
                size: 15
                iconColor: Theme.color("text.tertiary")
            }

            Text {
                Layout.fillWidth: true
                text: "搜索设置"
                font.pixelSize: 14
                font.family: Theme.fontUi
                color: Theme.color("text.tertiary")
            }

            Text {
                text: "⌘F"
                font.pixelSize: 12
                font.family: Theme.fontUi
                font.weight: Font.Medium
                color: Theme.color("text.tertiary")
            }
        }
    }

    component SidebarAccountRow: Rectangle {
        id: row
        property bool active: false
        property string title: ""
        property string subtitle: ""
        signal triggered()

        Layout.preferredHeight: 62
        radius: 16
        color: row.active
            ? (rowMouse.pressed ? Theme.color("surface.sunken") : Theme.color("surface.base"))
            : (rowMouse.containsMouse ? root.sidebarHover : "transparent")
        border.color: row.active ? root.hairline : "transparent"
        border.width: 1

        Rectangle {
            visible: row.active
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
            width: 3
            height: 30
            radius: 2
            color: root.selectionAccent
        }

        Behavior on color { ColorAnimation { duration: 130 } }
        Behavior on border.color { ColorAnimation { duration: 130 } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            AvatarBubble {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                selected: row.active
                compactAvatar: true
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: row.title
                    elide: Text.ElideRight
                    font.pixelSize: 13
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.primary")
                }

                Text {
                    Layout.fillWidth: true
                    text: row.subtitle
                    elide: Text.ElideRight
                    font.pixelSize: 11
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }

            ShapeIcon {
                pathData: Icons.chevronRight
                size: 12
                iconColor: row.active ? Theme.color("text.secondary") : Theme.color("text.tertiary")
            }
        }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.triggered()
        }
    }

    component SidebarSectionLabel: Text {
        Layout.fillWidth: true
        Layout.leftMargin: 6
        Layout.topMargin: 4
        font.pixelSize: 10
        font.family: Theme.fontUi
        font.weight: Font.DemiBold
        color: Theme.alpha("text.tertiary", 0.82)
    }

    component SidebarNavRow: Rectangle {
        id: row
        property string label: ""
        property string iconPath: ""
        property bool active: false
        signal triggered()

        Layout.fillWidth: true
        Layout.preferredHeight: 42
        radius: 10
        color: active
            ? Theme.alpha("accent.soft", Theme.isDark ? 0.18 : 0.34)
            : (navMouse.containsMouse ? root.sidebarHover : "transparent")
        border.color: active ? Theme.alpha("accent.strong", Theme.isDark ? 0.16 : 0.07) : "transparent"
        border.width: 1

        Rectangle {
            visible: false
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            width: 3
            height: 22
            radius: 2
            color: Theme.alpha("accent.strong", Theme.isDark ? 0.88 : 0.76)
        }

        Behavior on color { ColorAnimation { duration: 130 } }
        Behavior on border.color { ColorAnimation { duration: 130 } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 12
            spacing: 12

            ShapeIcon {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                pathData: row.iconPath
                size: 20
                strokeWidth: 1.66
                iconColor: row.active ? Theme.color("text.primary") : Theme.color("text.secondary")
            }

            Text {
                Layout.fillWidth: true
                text: row.label
                elide: Text.ElideRight
                font.pixelSize: 13
                font.family: Theme.fontUi
                font.weight: row.active ? Font.DemiBold : Font.Medium
                color: Theme.color("text.primary")
            }
        }

        MouseArea {
            id: navMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.triggered()
        }
    }

    component AvatarBubble: Rectangle {
        id: avatar
        property bool selected: false
        property bool compactAvatar: false

        radius: width / 2
        color: selected ? Theme.color("surface.base") : Theme.color("surface.sunken")
        border.color: selected ? root.tint(root.selectionAccent, 0.22) : Theme.alpha("line.soft", Theme.isDark ? 0.66 : 0.92)
        border.width: 1
        clip: true

        Rectangle {
            anchors.fill: parent
            radius: avatar.radius
            antialiasing: true
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: Theme.alpha("surface.float", Theme.isDark ? 0.06 : 0.42) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Rectangle {
            visible: !avatar.compactAvatar
            anchors.fill: parent
            anchors.margins: 6
            radius: width / 2
            color: "transparent"
            border.color: root.loggedIn ? Theme.alpha("state.success", 0.34) : Theme.alpha("line.strong", Theme.isDark ? 0.44 : 0.48)
            border.width: 1
        }

        Image {
            id: avatarImage
            anchors.fill: parent
            anchors.margins: avatar.compactAvatar ? 0 : 10
            source: appController.accountAvatarUrl
            fillMode: Image.PreserveAspectCrop
            visible: appController.accountAvatarUrl !== "" && status === Image.Ready
        }

        Text {
            anchors.centerIn: parent
            visible: appController.accountAvatarUrl === "" || avatarImage.status === Image.Error
            text: root.loggedIn ? root.displayName.charAt(0).toUpperCase() : "我"
            font.pixelSize: avatar.compactAvatar ? 14 : Math.max(24, avatar.width * 0.34)
            font.family: Theme.fontUi
            font.weight: Font.DemiBold
            color: root.loggedIn ? root.accountAccent : Theme.color("text.secondary")
        }
    }

    component SectionHeader: Item {
        id: header
        property string eyebrow: ""
        property string title: ""
        property string subtitle: ""
        property string actionText: ""
        signal actionTriggered()

        Layout.preferredHeight: column.implicitHeight

        ColumnLayout {
            id: column
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 4

            Text {
                visible: header.eyebrow !== ""
                text: header.eyebrow
                font.pixelSize: 11
                font.family: Theme.fontUi
                font.weight: Font.Bold
                font.letterSpacing: 1.6
                color: Theme.color("accent.strong")
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 2
                spacing: 12

                Text {
                    Layout.fillWidth: true
                    text: header.title
                    elide: Text.ElideRight
                    font.pixelSize: 26
                    font.family: Theme.fontUi
                    font.weight: Font.Black
                    color: Theme.color("text.primary")
                }

                Rectangle {
                    visible: header.actionText !== ""
                    Layout.preferredHeight: 28
                    Layout.preferredWidth: actionLabel.implicitWidth + 26
                    radius: 14
                    color: actionMouse.pressed
                        ? Theme.alpha("accent.soft", Theme.isDark ? 0.55 : 0.85)
                        : actionMouse.containsMouse
                            ? Theme.alpha("accent.soft", Theme.isDark ? 0.40 : 0.66)
                            : "transparent"

                    Text {
                        id: actionLabel
                        anchors.centerIn: parent
                        text: header.actionText
                        font.pixelSize: 12
                        font.family: Theme.fontUi
                        font.weight: Font.DemiBold
                        color: Theme.color("accent.strong")
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: header.actionTriggered()
                    }

                    Behavior on color { ColorAnimation { duration: 120 } }
                }
            }

            Text {
                visible: header.subtitle !== ""
                Layout.fillWidth: true
                text: header.subtitle
                wrapMode: Text.WordWrap
                font.pixelSize: 13
                font.family: Theme.fontUi
                color: Theme.color("text.secondary")
            }
        }
    }

    component ModelLibraryStrip: Item {
        id: strip

        readonly property var libraryModels: modelManager.modelList || []

        Layout.preferredHeight: 196

        ListView {
            id: stripList
            anchors.fill: parent
            anchors.leftMargin: -2
            anchors.rightMargin: -2
            orientation: ListView.Horizontal
            spacing: 14
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: strip.libraryModels.length > 0 ? strip.libraryModels : 4
            ScrollBar.horizontal: ScrollBar { policy: ScrollBar.AsNeeded }

            delegate: Rectangle {
                width: 158
                height: 192
                radius: 14
                color: Theme.color("surface.base")
                border.color: isCurrentModel
                    ? Theme.alpha("accent.strong", 0.62)
                    : Theme.alpha("line.soft", Theme.isDark ? 0.62 : 0.86)
                border.width: isCurrentModel ? 2 : 1

                readonly property var modelData: strip.libraryModels.length > 0 ? modelData : null
                readonly property string modelId: modelData ? modelData.id : ("placeholder-" + index)
                readonly property string modelName: modelData ? modelData.name : "添加模型"
                readonly property string modelThumb: modelData ? modelData.thumbnailUrl : ""
                readonly property bool isCurrentModel: modelData ? modelData.isCurrent === true : false
                readonly property bool isPresetModel: modelData ? modelData.isPreset === true : false

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 124
                        radius: 10
                        color: Theme.alpha("accent.soft", Theme.isDark ? 0.30 : 0.46)
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: modelThumb
                            fillMode: Image.PreserveAspectCrop
                            visible: modelThumb !== "" && status === Image.Ready
                            asynchronous: true
                        }

                        ShapeIcon {
                            anchors.centerIn: parent
                            visible: modelThumb === "" || !modelData
                            pathData: modelData ? Icons.paw : Icons.plus
                            size: 30
                            strokeWidth: 1.7
                            iconColor: Theme.alpha("accent.strong", Theme.isDark ? 0.96 : 0.78)
                        }

                        Rectangle {
                            visible: isCurrentModel
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 6
                            width: badgeText.implicitWidth + 12
                            height: 18
                            radius: 9
                            color: Theme.color("accent.base")

                            Text {
                                id: badgeText
                                anchors.centerIn: parent
                                text: "当前"
                                font.pixelSize: 10
                                font.family: Theme.fontUi
                                font.weight: Font.Bold
                                color: "#FFFFFF"
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.leftMargin: 2
                        text: modelName
                        elide: Text.ElideRight
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        font.weight: Font.DemiBold
                        color: Theme.color("text.primary")
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.leftMargin: 2
                        text: !modelData ? "导入 .model3.json"
                            : (isPresetModel ? "内置模型" : "导入模型")
                        elide: Text.ElideRight
                        font.pixelSize: 11
                        font.family: Theme.fontUi
                        color: Theme.color("text.tertiary")
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (modelData)
                            modelManager.switchModel(modelData.id)
                        else
                            root.scrollToMineSection("companion")
                    }
                }
            }
        }
    }

    component DesktopBehaviorGrid: GridLayout {
        id: behaviorGrid

        Layout.fillWidth: true
        columns: width < 720 ? 1 : 2
        columnSpacing: 14
        rowSpacing: 14

        BehaviorTile {
            iconPath: Icons.home
            title: "桌面常驻"
            subtitle: appController.desktopCompanionEnabled ? "正在桌面陪伴" : "未放出"
            tileChecked: appController.desktopCompanionEnabled
            onTileToggled: appController.desktopCompanionEnabled = !appController.desktopCompanionEnabled
        }

        BehaviorTile {
            iconPath: Icons.status
            title: "置顶显示"
            subtitle: root.desktopAlwaysOnTop ? "总是浮在最前" : "随窗口排序"
            tileChecked: root.desktopAlwaysOnTop
            onTileToggled: root.desktopAlwaysOnTop = !root.desktopAlwaysOnTop
        }

        BehaviorTile {
            iconPath: Icons.sparkle
            title: "点击穿透"
            subtitle: root.desktopClickThrough ? "鼠标穿过它" : "可被点击"
            tileChecked: root.desktopClickThrough
            onTileToggled: root.desktopClickThrough = !root.desktopClickThrough
        }

        BehaviorTile {
            iconPath: Icons.moon
            title: "安静模式"
            subtitle: root.desktopQuietMode ? "不发出声音" : "正常发声"
            tileChecked: root.desktopQuietMode
            onTileToggled: root.desktopQuietMode = !root.desktopQuietMode
        }

        NNACardPanel {
            Layout.fillWidth: true
            Layout.columnSpan: behaviorGrid.columns
            Layout.preferredHeight: 100
            panelRadius: 14
            fillColor: Theme.color("surface.base")
            strokeColor: Theme.alpha("line.soft", Theme.isDark ? 0.62 : 0.86)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 22
                anchors.rightMargin: 22
                spacing: 18

                ShapeIcon {
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    pathData: Icons.character
                    size: 24
                    strokeWidth: 1.7
                    iconColor: Theme.color("accent.strong")
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            Layout.fillWidth: true
                            text: "桌面尺寸"
                            font.pixelSize: 14
                            font.family: Theme.fontUi
                            font.weight: Font.DemiBold
                            color: Theme.color("text.primary")
                        }

                        Text {
                            text: Math.round(root.desktopModelScale * 100) + "%"
                            font.pixelSize: 13
                            font.family: Theme.fontUi
                            font.weight: Font.DemiBold
                            color: Theme.color("accent.strong")
                        }
                    }

                    Slider {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 22
                        from: 1.0
                        to: 1.4
                        value: root.desktopModelScale
                        onMoved: root.desktopModelScale = value

                        background: Rectangle {
                            x: parent.leftPadding
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            width: parent.availableWidth
                            height: 4
                            radius: 2
                            color: Theme.alpha("text.primary", Theme.isDark ? 0.14 : 0.10)

                            Rectangle {
                                width: parent.parent.visualPosition * parent.width
                                height: parent.height
                                radius: 2
                                color: Theme.color("accent.base")
                            }
                        }

                        handle: Rectangle {
                            x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                            y: parent.topPadding + parent.availableHeight / 2 - height / 2
                            width: 16
                            height: 16
                            radius: 8
                            color: "#FFFFFF"
                            border.color: Theme.alpha("text.primary", 0.18)
                            border.width: 1
                        }
                    }
                }
            }
        }
    }

    component BehaviorTile: NNACardPanel {
        id: tile
        property string iconPath: ""
        property string title: ""
        property string subtitle: ""
        property bool tileChecked: false
        signal tileToggled()

        Layout.fillWidth: true
        Layout.preferredHeight: 86
        panelRadius: 14
        fillColor: tileChecked
            ? Theme.alpha("accent.soft", Theme.isDark ? 0.36 : 0.55)
            : Theme.color("surface.base")
        strokeColor: tileChecked
            ? Theme.alpha("accent.strong", 0.42)
            : Theme.alpha("line.soft", Theme.isDark ? 0.62 : 0.86)

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            spacing: 14

            Rectangle {
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
                radius: 10
                color: tile.tileChecked
                    ? Theme.color("accent.base")
                    : Theme.alpha("accent.soft", Theme.isDark ? 0.32 : 0.52)

                ShapeIcon {
                    anchors.centerIn: parent
                    pathData: tile.iconPath
                    size: 18
                    strokeWidth: 1.72
                    iconColor: tile.tileChecked ? "#FFFFFF" : Theme.color("accent.strong")
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: tile.title
                    elide: Text.ElideRight
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.primary")
                }

                Text {
                    Layout.fillWidth: true
                    text: tile.subtitle
                    elide: Text.ElideRight
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }

            AppleSwitch {
                checked: tile.tileChecked
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: tile.tileToggled()
        }
    }

    component AboutFooter: Item {
        Layout.preferredHeight: footerColumn.implicitHeight

        ColumnLayout {
            id: footerColumn
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.alpha("text.primary", Theme.isDark ? 0.10 : 0.06)
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 14
                spacing: 14

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "OpenNeko Engine"
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        font.weight: Font.DemiBold
                        color: Theme.color("text.primary")
                    }

                    Text {
                        text: "桌面端 · 0.1 开发预览版"
                        font.pixelSize: 11
                        font.family: Theme.fontUi
                        color: Theme.color("text.tertiary")
                    }
                }

                Text {
                    text: "服务条款"
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
                Text {
                    text: "·"
                    font.pixelSize: 12
                    color: Theme.color("text.tertiary")
                }
                Text {
                    text: "隐私"
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
                Text {
                    text: "·"
                    font.pixelSize: 12
                    color: Theme.color("text.tertiary")
                }
                Text {
                    text: "开源许可"
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }
        }
    }

    component CompanionOverviewPanel: NNACardPanel {
        id: panel

        readonly property bool tight: width < 700
        readonly property color bleedTone: Theme.color("accent.base")

        Layout.preferredHeight: tight ? 320 : 384
        fillColor: Theme.color("surface.base")
        strokeColor: Theme.alpha("accent.strong", Theme.isDark ? 0.18 : 0.10)
        panelRadius: 16
        clip: true

        Rectangle {
            anchors.fill: parent
            radius: panel.panelRadius
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: Theme.alpha("accent.base", Theme.isDark ? 0.34 : 0.26) }
                GradientStop { position: 0.50; color: Theme.alpha("accent.base", Theme.isDark ? 0.12 : 0.08) }
                GradientStop { position: 1.0; color: Theme.alpha("accent.base", 0.00) }
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * (panel.tight ? 0.55 : 0.46)
            radius: panel.panelRadius
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Theme.alpha("accent.soft", Theme.isDark ? 0.42 : 0.70) }
                GradientStop { position: 1.0; color: Theme.alpha("accent.soft", 0.00) }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: panel.tight ? 18 : 30
            anchors.rightMargin: panel.tight ? 18 : 32
            anchors.topMargin: panel.tight ? 18 : 26
            anchors.bottomMargin: panel.tight ? 18 : 26
            spacing: panel.tight ? 20 : 38

            Item {
                Layout.preferredWidth: panel.tight ? 220 : 320
                Layout.fillHeight: true
                clip: true

                NNAAvatarCanvas {
                    id: companionPreview
                    anchors.fill: parent
                    modelPath: appController.currentModelPath
                    modelScale: panel.tight ? 1.10 : 1.32
                    modelOffsetX: 0
                    modelOffsetY: 0.08
                    visible: modelLoaded || appController.currentModelPath !== ""
                }

                ShapeIcon {
                    anchors.centerIn: parent
                    visible: !companionPreview.visible
                    pathData: Icons.paw
                    size: 56
                    strokeWidth: 1.6
                    iconColor: Theme.alpha("text.secondary", 0.60)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                Item { Layout.fillHeight: true }

                Text {
                    text: "DESKTOP COMPANION"
                    font.pixelSize: 10
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.6
                    color: Theme.alpha("accent.strong", Theme.isDark ? 0.92 : 0.82)
                }

                Item { Layout.preferredHeight: 6 }

                Text {
                    Layout.fillWidth: true
                    text: root.companionDisplayName()
                    elide: Text.ElideRight
                    font.pixelSize: panel.tight ? 28 : 34
                    font.family: Theme.fontUi
                    font.weight: Font.Black
                    color: Theme.color("text.primary")
                }

                Item { Layout.preferredHeight: 14 }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 8
                        Layout.preferredHeight: 8
                        Layout.alignment: Qt.AlignVCenter
                        radius: 4
                        color: appController.desktopCompanionEnabled ? Theme.color("state.success") : Theme.color("text.tertiary")
                    }

                    Text {
                        text: appController.desktopCompanionEnabled ? "桌面常驻中" : "未放出到桌面"
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        font.weight: Font.Medium
                        color: Theme.color("text.primary")
                    }

                    Text {
                        text: "·"
                        font.pixelSize: 13
                        color: Theme.color("text.tertiary")
                    }

                    Text {
                        text: "本地优先"
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        color: Theme.color("text.secondary")
                    }

                    Text {
                        visible: !panel.tight
                        text: "·"
                        font.pixelSize: 13
                        color: Theme.color("text.tertiary")
                    }

                    Text {
                        visible: !panel.tight
                        text: "Cubism Live2D"
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        color: Theme.color("text.secondary")
                    }

                    Item { Layout.fillWidth: true }
                }

                Item { Layout.preferredHeight: 18 }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Theme.alpha("text.primary", Theme.isDark ? 0.16 : 0.08)
                }

                Item { Layout.preferredHeight: 14 }

                Text {
                    Layout.fillWidth: true
                    text: appController.desktopCompanionEnabled
                        ? "它正在桌面上陪着你，随时可以收回。"
                        : "把它放到桌面，它会在角落安静地待着，等你想说话时再出现。"
                    wrapMode: Text.WordWrap
                    font.pixelSize: 13
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                    lineHeight: 1.42
                }

                Item { Layout.preferredHeight: 22 }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    PillButton {
                        Layout.preferredWidth: panel.tight ? 132 : 156
                        text: appController.desktopCompanionEnabled ? "收回桌面" : "放到桌面"
                        primary: true
                        onTriggered: appController.desktopCompanionEnabled = !appController.desktopCompanionEnabled
                    }

                    TextButton {
                        text: "更换模型"
                        onTriggered: root.scrollToMineSection("companion")
                    }

                    TextButton {
                        visible: !panel.tight
                        text: "调整位置"
                        onTriggered: root.scrollToMineSection("desktop")
                    }

                    Item { Layout.fillWidth: true }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    component StatusChip: Rectangle {
        id: chip
        property string textValue: ""
        property bool active: false
        property bool blue: false
        property bool showDot: false
        property color dotColor: Theme.color("state.success")
        property string iconPath: ""

        Layout.preferredWidth: Math.min(label.implicitWidth + (showDot || iconPath !== "" ? 34 : 22), 176)
        Layout.preferredHeight: 30
        radius: 7
        color: blue ? root.appleBlueSoft : Theme.color("surface.base")
        border.color: blue ? Qt.rgba(0, 0.4, 0.8, 0.22) : Theme.alpha("line.strong", Theme.isDark ? 0.26 : 0.50)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 7

            Rectangle {
                visible: chip.showDot
                Layout.preferredWidth: 8
                Layout.preferredHeight: 8
                radius: 4
                color: chip.dotColor
            }

            ShapeIcon {
                visible: chip.iconPath !== ""
                pathData: chip.iconPath
                size: 15
                strokeWidth: 1.65
                iconColor: root.appleBlue
            }

            Text {
                id: label
                Layout.fillWidth: true
                text: chip.textValue
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 13
                font.family: Theme.fontUi
                font.weight: Font.Medium
                color: chip.blue ? root.appleBlue : Theme.color("text.secondary")
            }
        }
    }

    component MiniMetric: Rectangle {
        id: metric
        property string label: ""
        property string valueText: ""

        Layout.fillWidth: true
        Layout.preferredHeight: 46
        radius: 10
        color: Theme.color("surface.sunken")
        border.color: Theme.alpha("line.soft", Theme.isDark ? 0.54 : 0.78)
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            anchors.topMargin: 6
            anchors.bottomMargin: 6
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: metric.valueText
                elide: Text.ElideRight
                font.pixelSize: 13
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: Theme.color("text.primary")
            }

            Text {
                Layout.fillWidth: true
                text: metric.label
                elide: Text.ElideRight
                font.pixelSize: 11
                font.family: Theme.fontUi
                color: Theme.color("text.tertiary")
            }
        }
    }

    component PillButton: Rectangle {
        id: button
        property string text: ""
        property string iconPath: ""
        property bool primary: false
        signal triggered()

        Layout.preferredHeight: 44
        radius: 22
        color: primary
            ? (buttonMouse.pressed
                ? Theme.color("accent.strong")
                : (buttonMouse.containsMouse ? Qt.lighter(Theme.color("accent.base"), 1.06) : Theme.color("accent.base")))
            : (buttonMouse.containsMouse ? Theme.alpha("surface.float", 0.72) : Theme.alpha("surface.float", 0.50))
        border.color: primary ? "transparent" : Theme.alpha("text.primary", 0.16)
        border.width: primary ? 0 : 1
        opacity: buttonMouse.pressed && !primary ? 0.78 : 1.0

        RowLayout {
            anchors.centerIn: parent
            spacing: 8

            ShapeIcon {
                visible: button.iconPath !== ""
                pathData: button.iconPath
                size: 18
                strokeWidth: 1.62
                iconColor: primary ? "#FFFFFF" : Theme.color("text.primary")
            }

            Text {
                text: button.text
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 13
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: primary ? "#FFFFFF" : Theme.color("text.primary")
            }
        }

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.triggered()
        }

        Behavior on color { ColorAnimation { duration: 130 } }
        Behavior on opacity { NumberAnimation { duration: 100 } }
    }

    component TextButton: Rectangle {
        id: textButton
        property string text: ""
        signal triggered()

        Layout.preferredWidth: label.implicitWidth + 24
        Layout.preferredHeight: 44
        radius: 22
        color: buttonMouse.containsMouse ? Theme.alpha("accent.soft", Theme.isDark ? 0.42 : 0.70) : "transparent"
        opacity: buttonMouse.pressed ? 0.72 : 1.0

        Text {
            id: label
            anchors.centerIn: parent
            text: textButton.text
            font.pixelSize: 13
            font.family: Theme.fontUi
            font.weight: Font.DemiBold
            color: Theme.color("accent.strong")
        }

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: textButton.triggered()
        }

        Behavior on color { ColorAnimation { duration: 130 } }
        Behavior on opacity { NumberAnimation { duration: 100 } }
    }

    component SliderSetting: Rectangle {
        id: sliderRow
        property string iconPath: ""
        property string title: ""
        property string subtitle: ""
        property string valueText: ""
        property real fromValue: 0
        property real toValue: 1
        property real currentValue: 0
        property bool showScaleTicks: false
        signal committed(real value)

        Layout.fillWidth: true
        Layout.preferredHeight: showScaleTicks ? 98 : 78
        color: "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 26
            anchors.rightMargin: 26
            anchors.topMargin: 0
            anchors.bottomMargin: 0
            spacing: 18

            ShapeIcon {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                Layout.alignment: Qt.AlignVCenter
                pathData: sliderRow.iconPath
                size: 22
                strokeWidth: 1.66
                iconColor: Theme.alpha("text.secondary", Theme.isDark ? 0.9 : 0.94)
            }

            Text {
                Layout.fillWidth: true
                text: sliderRow.title
                elide: Text.ElideRight
                font.pixelSize: 15
                font.family: Theme.fontUi
                font.weight: Font.Medium
                color: Theme.color("text.primary")
            }

            ColumnLayout {
                Layout.preferredWidth: Math.min(276, Math.max(210, sliderRow.width * 0.48))
                Layout.alignment: Qt.AlignVCenter
                Layout.maximumWidth: 292
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: sliderRow.valueText
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 15
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.primary")
                }

                Text {
                    Layout.fillWidth: true
                    visible: sliderRow.subtitle !== ""
                    text: sliderRow.subtitle
                    elide: Text.ElideRight
                    font.pixelSize: 13
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }

                NNASlider {
                    id: sizeSlider
                    Layout.fillWidth: true
                    Layout.topMargin: 0
                    from: sliderRow.fromValue
                    to: sliderRow.toValue
                    value: sliderRow.currentValue
                    trackHeight: 4
                    handleSize: 18
                    accentColor: root.appleBlue
                    onValueCommitted: function(value) {
                        sliderRow.committed(value)
                    }
                }

                Item {
                    id: tickRail
                    Layout.fillWidth: true
                    Layout.preferredHeight: 18
                    visible: sliderRow.showScaleTicks

                    Repeater {
                        model: sliderRow.fromValue >= 1.0
                            ? [
                                { label: "100%", value: 1.00 },
                                { label: "140%", value: 1.40 }
                            ]
                            : [
                                { label: "60%", value: 0.60 },
                                { label: "100%", value: 1.00 },
                                { label: "140%", value: 1.40 },
                                { label: "180%", value: 1.80 }
                            ]

                        Text {
                            width: implicitWidth
                            x: Math.max(0, Math.min(tickRail.width - width,
                                sizeSlider.trackLeft
                                + ((modelData.value - sliderRow.fromValue) / (sliderRow.toValue - sliderRow.fromValue)) * sizeSlider.trackWidth
                                - width / 2))
                            y: 1
                            text: modelData.label
                            font.pixelSize: 12
                            font.family: Theme.fontUi
                            color: Theme.color("text.secondary")
                        }
                    }
                }
            }
        }
    }

    component GroupedSection: ColumnLayout {
        id: section
        property string title: ""
        default property alias rows: groupBody.data

        spacing: 8

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 12
            text: section.title
            font.pixelSize: 12
            font.family: Theme.fontUi
            font.weight: Font.DemiBold
            color: Theme.alpha("text.secondary", Theme.isDark ? 0.86 : 0.78)
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: groupBody.implicitHeight
            clip: false

            Rectangle {
                id: groupFrame
                anchors.fill: parent
                radius: 12
                color: root.groupMaterial
                border.color: Theme.alpha("line.soft", Theme.isDark ? 0.70 : 0.96)
                border.width: 1
                antialiasing: true
                clip: true

                ColumnLayout {
                    id: groupBody
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    spacing: 0
                }
            }
        }
    }

    component SettingsCell: Rectangle {
        id: cell
        property string iconPath: ""
        property string title: ""
        property string subtitle: ""
        property string valueText: ""
        property color stateColor: Theme.color("text.secondary")
        property color tone: Theme.color("accent.strong")
        property bool showChevron: true
        property bool valueAsPill: false
        signal triggered()

        Layout.fillWidth: true
        Layout.preferredHeight: 64
        color: "transparent"
        opacity: enabled ? 1 : 0.48

        Rectangle {
            id: cellHover
            anchors.fill: parent
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            anchors.topMargin: 3
            anchors.bottomMargin: 3
            radius: 9
            color: cellMouse.containsMouse && cell.enabled
                ? (cellMouse.pressed ? root.rowPressedMaterial : root.rowHoverMaterial)
                : "transparent"

            Behavior on color { ColorAnimation { duration: 130 } }
        }

        RowLayout {
            z: 1
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 14
            spacing: 16

            SettingsIconTile {
                iconPath: cell.iconPath
                tone: cell.tone
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: cell.title
                    elide: Text.ElideRight
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.primary")
                }

                Text {
                    Layout.fillWidth: true
                    text: cell.subtitle
                    visible: cell.subtitle !== ""
                    elide: Text.ElideRight
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }

            ValuePill {
                visible: cell.valueText !== "" && cell.valueAsPill
                textValue: cell.valueText
                tone: cell.stateColor
            }

            Text {
                visible: cell.valueText !== "" && !cell.valueAsPill
                Layout.maximumWidth: Math.min(230, cell.width * 0.34)
                text: cell.valueText
                elide: Text.ElideRight
                font.pixelSize: 13
                font.family: Theme.fontUi
                font.weight: Font.Medium
                color: cell.stateColor
            }

            ShapeIcon {
                visible: cell.showChevron
                pathData: Icons.chevronRight
                size: 13
                iconColor: cellMouse.containsMouse && cell.enabled ? Theme.color("text.secondary") : Theme.color("text.tertiary")
            }
        }

        MouseArea {
            id: cellMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: cell.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (cell.enabled) cell.triggered()
        }
    }

    component SettingsSwitchCell: Rectangle {
        id: cell
        property string iconPath: ""
        property string title: ""
        property string subtitle: ""
        property bool checked: false
        property color tone: Theme.color("accent.strong")
        signal switchChanged(bool checked)

        Layout.fillWidth: true
        Layout.preferredHeight: 64
        color: "transparent"

        Rectangle {
            id: switchHover
            anchors.fill: parent
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            anchors.topMargin: 3
            anchors.bottomMargin: 3
            radius: 9
            color: switchMouse.containsMouse
                ? (switchMouse.pressed ? root.rowPressedMaterial : root.rowHoverMaterial)
                : "transparent"

            Behavior on color { ColorAnimation { duration: 130 } }
        }

        RowLayout {
            z: 1
            anchors.fill: parent
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            spacing: 16

            SettingsIconTile {
                iconPath: cell.iconPath
                tone: cell.tone
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: cell.title
                    elide: Text.ElideRight
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.primary")
                }

                Text {
                    Layout.fillWidth: true
                    text: cell.subtitle
                    elide: Text.ElideRight
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }

            AppleSwitch {
                checked: cell.checked
                onToggled: function(checked) { cell.switchChanged(checked) }
            }
        }

        MouseArea {
            id: switchMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: cell.switchChanged(!cell.checked)
        }
    }

    component SettingsDivider: Rectangle {
        Layout.fillWidth: true
        Layout.leftMargin: 76
        Layout.rightMargin: 26
        Layout.preferredHeight: 1
        color: Theme.alpha("line.soft", Theme.isDark ? 0.46 : 0.82)
    }

    component SettingsIconTile: Item {
        property string iconPath: ""
        property color tone: Theme.color("accent.strong")

        Layout.preferredWidth: 32
        Layout.preferredHeight: 32

        ShapeIcon {
            anchors.centerIn: parent
            pathData: parent.iconPath
            size: 24
            strokeWidth: 1.66
            iconColor: Theme.alpha("text.secondary", Theme.isDark ? 0.94 : 0.88)
        }
    }

    component ValuePill: Rectangle {
        id: pillValue
        property string textValue: ""
        property color tone: Theme.color("text.secondary")

        implicitWidth: Math.min(valueLabel.implicitWidth + 18, 150)
        implicitHeight: 24
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight
        radius: height / 2
        color: Theme.isDark ? Theme.alpha("surface.raised", 0.62) : Theme.alpha("surface.sunken", 0.74)
        border.color: Theme.alpha("line.strong", Theme.isDark ? 0.34 : 0.52)
        border.width: 1

        Text {
            id: valueLabel
            anchors.fill: parent
            anchors.leftMargin: 9
            anchors.rightMargin: 9
            text: pillValue.textValue
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 12
            font.family: Theme.fontUi
            font.weight: Font.Medium
            color: Theme.color("text.secondary")
        }
    }

    component AppleSwitch: Rectangle {
        id: switchControl
        property bool checked: false
        signal toggled(bool checked)

        implicitWidth: 48
        implicitHeight: 28
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight
        radius: height / 2
        color: checked ? root.appleBlue : Theme.alpha("surface.sunken", Theme.isDark ? 0.90 : 1.0)
        border.color: checked ? Qt.rgba(0, 0.28, 0.58, 0.26) : Theme.alpha("line.strong", Theme.isDark ? 0.46 : 0.72)
        border.width: 1

        Behavior on color { ColorAnimation { duration: 140 } }
        Behavior on border.color { ColorAnimation { duration: 140 } }

        RectangularShadow {
            x: knob.x - 1
            y: knob.y + 2
            width: knob.width + 2
            height: knob.height + 2
            radius: 14
            blur: 8
            spread: -2
            color: Theme.alpha("overlay.scrim", Theme.isDark ? 0.30 : 0.13)
            cached: true
        }

        Rectangle {
            id: knob
            width: 24
            height: 24
            radius: 12
            x: switchControl.checked ? switchControl.width - width - 2 : 2
            y: 2
            color: "#FFFFFF"
            border.color: Qt.rgba(0, 0, 0, 0.04)
            border.width: 1

            Behavior on x { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                switchControl.checked = !switchControl.checked
                switchControl.toggled(switchControl.checked)
            }
        }
    }

    component StatusDot: Rectangle {
        property bool active: false

        Layout.preferredWidth: 10
        Layout.preferredHeight: 10
        radius: 5
        color: active ? Theme.color("state.success") : Theme.color("text.tertiary")
        border.color: Theme.alpha("surface.base", 0.82)
        border.width: 1
    }

    Dialog {
        id: loginDialog
        modal: true
        width: Math.min(root.width - 48, 408)
        title: ""
        standardButtons: Dialog.NoButton
        anchors.centerIn: parent
        padding: 0
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        property string loginMode: "email"
        property bool thirdPartyOpen: false
        property string defaultBaseUrl: "http://127.0.0.1:8080"

        onOpened: {
            loginMode = "email"
            thirdPartyOpen = false
        }

        background: Item {
            RectangularShadow {
                x: -16
                y: 8
                width: parent.width + 32
                height: parent.height + 20
                radius: 22
                blur: 24
                spread: -5
                color: root.dialogShadowColor
                cached: true
            }

            Rectangle {
                anchors.fill: parent
                radius: 14
                color: root.dialogMaterial
                border.color: root.dialogStroke
                border.width: 1
                antialiasing: true
                clip: true
            }
        }

        contentItem: Item {
            implicitWidth: loginDialog.width
            implicitHeight: loginContent.implicitHeight

            ColumnLayout {
            id: loginContent
            width: parent.width
            spacing: 0

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 28
                Layout.rightMargin: 28
                Layout.topMargin: 24
                spacing: 7

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 52
                    Layout.preferredHeight: 52
                    radius: 14
                    color: Theme.alpha("surface.float", Theme.isDark ? 0.82 : 0.96)
                    border.color: root.dialogStroke
                    border.width: 1

                    Rectangle {
                        anchors.centerIn: parent
                        width: 38
                        height: 38
                        radius: 11
                        color: Theme.color("accent.soft")
                    }

                    ShapeIcon {
                        anchors.centerIn: parent
                        pathData: Icons.paw
                        size: 22
                        iconColor: Theme.color("accent.strong")
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    text: "登录 Neko 账户"
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 20
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.primary")
                }

                Text {
                    Layout.fillWidth: true
                    text: loginDialog.loginMode === "email" ? "使用邮箱验证码继续" : "使用手机 App 扫码登录"
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 13
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 28
                Layout.rightMargin: 28
                Layout.topMargin: 24
                visible: loginDialog.loginMode === "email"
                spacing: 12

                Rectangle {
                    id: emailForm
                    Layout.fillWidth: true
                    Layout.preferredHeight: 104
                    radius: 12
                    color: Theme.alpha("surface.float", Theme.isDark ? 0.78 : 0.96)
                    border.color: emailInput.activeFocus || emailCodeInput.activeFocus
                        ? Theme.alpha("accent.strong", 0.46)
                        : root.dialogStroke
                    border.width: 1

                    Behavior on border.color { ColorAnimation { duration: 130 } }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 52
                            Layout.leftMargin: 16
                            Layout.rightMargin: 12
                            spacing: 10

                            Text {
                                Layout.preferredWidth: 54
                                text: "邮箱"
                                font.pixelSize: 14
                                font.family: Theme.fontUi
                                font.weight: Font.Medium
                                color: Theme.color("text.primary")
                            }

                            TextField {
                                id: emailInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                placeholderText: "name@example.com"
                                background: Item {}
                                font.pixelSize: 14
                                font.family: Theme.fontUi
                                color: Theme.color("text.primary")
                                placeholderTextColor: Theme.color("text.tertiary")
                                selectByMouse: true
                                verticalAlignment: TextInput.AlignVCenter
                                Keys.onReturnPressed: emailCodeInput.forceActiveFocus()
                                Keys.onEnterPressed: emailCodeInput.forceActiveFocus()
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.leftMargin: 16
                            Layout.rightMargin: 12
                            Layout.preferredHeight: 1
                            color: Theme.color("line.soft")
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 51
                            Layout.leftMargin: 16
                            Layout.rightMargin: 8
                            spacing: 10

                            Text {
                                Layout.preferredWidth: 54
                                text: "验证码"
                                font.pixelSize: 14
                                font.family: Theme.fontUi
                                font.weight: Font.Medium
                                color: Theme.color("text.primary")
                            }

                            TextField {
                                id: emailCodeInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                placeholderText: "6 位数字"
                                background: Item {}
                                font.pixelSize: 14
                                font.family: Theme.fontUi
                                color: Theme.color("text.primary")
                                placeholderTextColor: Theme.color("text.tertiary")
                                selectByMouse: true
                                verticalAlignment: TextInput.AlignVCenter
                                Keys.onReturnPressed: appController.loginWithEmailCode(loginBaseUrl(), emailInput.text, emailCodeInput.text)
                                Keys.onEnterPressed: appController.loginWithEmailCode(loginBaseUrl(), emailInput.text, emailCodeInput.text)
                            }

                            LoginInlineButton {
                                Layout.preferredWidth: 58
                                text: "获取"
                                enabled: !appController.syncBusy
                                onTriggered: appController.sendEmailLoginCode(loginBaseUrl(), emailInput.text)
                            }
                        }
                    }
                }

                LoginPrimaryButton {
                    Layout.fillWidth: true
                    text: appController.syncBusy ? "请稍候" : "继续"
                    enabled: !appController.syncBusy
                    onTriggered: appController.loginWithEmailCode(loginBaseUrl(), emailInput.text, emailCodeInput.text)
                }

                LoginChoiceRow {
                    Layout.fillWidth: true
                    title: "手机 App 扫码登录"
                    subtitle: "适合已在手机端登录的账号"
                    iconPath: Icons.iot
                    onTriggered: {
                        loginDialog.loginMode = "scan"
                        if (appController.deviceLoginQrText === "")
                            appController.startDeviceLogin(loginBaseUrl())
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 28
                Layout.rightMargin: 28
                Layout.topMargin: 24
                visible: loginDialog.loginMode === "scan"
                spacing: 12

                LoginQrPreview {
                    Layout.alignment: Qt.AlignHCenter
                    qrText: appController.deviceLoginQrText
                }

                Text {
                    Layout.fillWidth: true
                    text: deviceStatusText()
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    font.pixelSize: 13
                    font.family: Theme.fontUi
                    font.weight: Font.Medium
                    color: appController.deviceLoginStatus === "SCANNED"
                        ? Theme.color("accent.strong")
                        : Theme.color("text.secondary")
                }

                LoginPrimaryButton {
                    Layout.fillWidth: true
                    text: appController.deviceLoginQrText === "" ? "生成二维码" : "刷新二维码"
                    enabled: !appController.syncBusy
                    onTriggered: appController.startDeviceLogin(loginBaseUrl())
                }

                LoginChoiceRow {
                    Layout.fillWidth: true
                    title: "邮箱验证码登录"
                    subtitle: "使用邮箱接收一次性验证码"
                    iconPath: Icons.chevronLeft
                    onTriggered: loginDialog.loginMode = "email"
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.leftMargin: 28
                Layout.rightMargin: 28
                Layout.topMargin: 14
                visible: appController.syncStatusText !== "" || appController.syncLastError !== ""
                text: appController.syncLastError !== "" ? appController.syncLastError : appController.syncStatusText
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 12
                font.family: Theme.fontUi
                color: appController.syncLastError !== "" ? Theme.color("state.danger") : Theme.color("text.secondary")
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 28
                Layout.rightMargin: 28
                Layout.topMargin: 18
                Layout.preferredHeight: 1
                color: Theme.color("line.soft")
            }

            LoginDisclosureRow {
                Layout.fillWidth: true
                Layout.leftMargin: 28
                Layout.rightMargin: 28
                Layout.topMargin: 6
                text: "第三方登录"
                expanded: loginDialog.thirdPartyOpen
                onTriggered: loginDialog.thirdPartyOpen = !loginDialog.thirdPartyOpen
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 28
                Layout.rightMargin: 28
                visible: loginDialog.thirdPartyOpen
                spacing: 8

                LoginThirdPartyRow {
                    Layout.fillWidth: true
                    title: "Apple"
                    subtitle: "P1 接入 Apple ID 后启用"
                    mark: "A"
                    enabledRow: false
                }

                LoginThirdPartyRow {
                    Layout.fillWidth: true
                    title: "华为账号"
                    subtitle: "请先使用手机 App 扫码登录"
                    mark: "H"
                    enabledRow: false
                }

                LoginThirdPartyRow {
                    Layout.fillWidth: true
                    title: "Steam"
                    subtitle: "Steam 版本发行后启用"
                    mark: "S"
                    enabledRow: false
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 28
                Layout.rightMargin: 28
                Layout.topMargin: root.loggedIn ? 12 : 0
                Layout.bottomMargin: root.loggedIn ? 24 : 22
                spacing: 10

                Item { Layout.fillWidth: true }

                LoginPlainButton {
                    visible: root.loggedIn
                    text: "退出登录"
                    destructive: true
                    onTriggered: {
                        appController.logoutAccount()
                    }
                }
            }
        }

            LoginCloseButton {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 14
                anchors.rightMargin: 14
                onTriggered: {
                    appController.cancelDeviceLogin()
                    loginDialog.close()
                }
            }
        }
    }

    function loginBaseUrl() {
        return appController.syncBackendBaseUrl !== "" ? appController.syncBackendBaseUrl : loginDialog.defaultBaseUrl
    }

    function deviceStatusText() {
        switch (appController.deviceLoginStatus) {
            case "WAITING": return "使用 NekoBuddy 手机 App 扫码登录"
            case "SCANNED": return "已扫码，请在手机上确认登录"
            case "CONFIRMED": return "登录中"
            case "EXPIRED": return "已过期"
            case "CANCELED": return "手机端已取消"
            case "CONSUMED": return "已完成"
        }
        return "点击生成二维码"
    }

    component LoginCloseButton: Rectangle {
        id: closeButton
        signal triggered()

        width: 28
        height: 28
        radius: 12
        color: closeMouse.pressed
            ? Theme.alpha("line.strong", 0.34)
            : (closeMouse.containsMouse ? Theme.alpha("line.soft", 0.62) : "transparent")

        ShapeIcon {
            anchors.centerIn: parent
            pathData: Icons.close
            size: 14
            iconColor: Theme.color("text.secondary")
        }

        MouseArea {
            id: closeMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: closeButton.triggered()
        }

        Behavior on color { ColorAnimation { duration: 120 } }
    }

    component LoginThirdPartyRow: Rectangle {
        id: providerRow
        property string title: ""
        property string subtitle: ""
        property string mark: ""
        property bool enabledRow: true
        signal triggered()

        Layout.preferredHeight: 54
        radius: 14
        color: providerMouse.pressed && enabledRow
            ? Theme.color("surface.sunken")
            : Theme.color("surface.base")
        border.color: root.dialogStroke
        border.width: 1
        opacity: enabledRow ? 1.0 : 0.58

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                radius: 9
                color: Theme.color("surface.sunken")
                border.color: Theme.color("line.soft")
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: providerRow.mark
                    font.pixelSize: 13
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.primary")
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    Layout.fillWidth: true
                    text: providerRow.title
                    elide: Text.ElideRight
                    font.pixelSize: 13
                    font.family: Theme.fontUi
                    font.weight: Font.Medium
                    color: Theme.color("text.primary")
                }

                Text {
                    Layout.fillWidth: true
                    text: providerRow.subtitle
                    elide: Text.ElideRight
                    font.pixelSize: 11
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }

            Text {
                text: "待支持"
                font.pixelSize: 11
                font.family: Theme.fontUi
                font.weight: Font.Medium
                color: Theme.color("text.tertiary")
            }
        }

        MouseArea {
            id: providerMouse
            anchors.fill: parent
            enabled: providerRow.enabledRow
            hoverEnabled: true
            cursorShape: providerRow.enabledRow ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: providerRow.triggered()
        }
    }

    component LoginInlineButton: Rectangle {
        id: inlineButton
        property string text: ""
        property bool enabled: true
        signal triggered()

        Layout.preferredHeight: 32
        radius: 10
        color: Theme.alpha("accent.strong", inlineMouse.pressed ? 0.20 : inlineMouse.containsMouse ? 0.14 : 0.09)
        border.color: Theme.alpha("accent.strong", inlineMouse.containsMouse ? 0.22 : 0.12)
        border.width: 1
        opacity: enabled ? 1.0 : 0.48

        Text {
            anchors.centerIn: parent
            text: inlineButton.text
            font.pixelSize: 13
            font.family: Theme.fontUi
            font.weight: Font.DemiBold
            color: Theme.color("accent.strong")
        }

        MouseArea {
            id: inlineMouse
            anchors.fill: parent
            enabled: inlineButton.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: inlineButton.triggered()
        }

        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }
    }

    component LoginChoiceRow: Rectangle {
        id: choice
        property string title: ""
        property string subtitle: ""
        property string iconPath: ""
        signal triggered()

        Layout.preferredHeight: 62
        radius: 12
        color: choiceMouse.pressed
            ? Theme.color("surface.sunken")
            : (choiceMouse.containsMouse ? Theme.alpha("surface.float", Theme.isDark ? 0.76 : 1.0) : Theme.color("surface.base"))
        border.color: choiceMouse.containsMouse ? Theme.alpha("accent.strong", 0.24) : root.dialogStroke
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 13
            anchors.rightMargin: 12
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 34
                Layout.preferredHeight: 34
                radius: 9
                color: Theme.alpha("surface.sunken", Theme.isDark ? 0.78 : 0.92)

                ShapeIcon {
                    anchors.centerIn: parent
                    pathData: choice.iconPath
                    size: 17
                    iconColor: Theme.color("text.secondary")
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: choice.title
                    font.pixelSize: 13
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.primary")
                }

                Text {
                    Layout.fillWidth: true
                    text: choice.subtitle
                    maximumLineCount: 1
                    elide: Text.ElideRight
                    font.pixelSize: 11
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }

            ShapeIcon {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                pathData: Icons.chevronRight
                size: 16
                iconColor: Theme.color("text.tertiary")
            }
        }

        MouseArea {
            id: choiceMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: choice.triggered()
        }

        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }
    }

    component LoginTextField: Rectangle {
        id: loginField
        property alias text: textField.text
        property alias placeholderText: textField.placeholderText
        property alias echoMode: textField.echoMode

        signal accepted()

        function forceInputFocus() {
            textField.forceActiveFocus()
        }

        Layout.preferredHeight: 44
        radius: 12
        color: Theme.color("surface.base")
        border.color: textField.activeFocus
            ? Theme.color("accent.base")
            : Theme.color("line.soft")
        border.width: 1

        Behavior on border.color { ColorAnimation { duration: 120 } }

        TextField {
            id: textField
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            anchors.topMargin: 5
            anchors.bottomMargin: 5
            background: Item {}
            font.pixelSize: 15
            font.family: Theme.fontUi
            color: Theme.color("text.primary")
            placeholderTextColor: Theme.color("text.tertiary")
            selectByMouse: true
            verticalAlignment: TextInput.AlignVCenter
            Keys.onReturnPressed: loginField.accepted()
            Keys.onEnterPressed: loginField.accepted()
        }
    }

    component LoginPrimaryButton: Rectangle {
        id: primaryButton
        property string text: ""
        property bool enabled: true

        signal triggered()

        Layout.preferredHeight: 44
        radius: 10
        color: Theme.color("accent.strong")
        opacity: enabled ? (buttonMouse.pressed ? 0.76 : buttonMouse.containsMouse ? 0.90 : 1.0) : 0.45

        Behavior on opacity { NumberAnimation { duration: 100 } }

        Text {
            anchors.centerIn: parent
            text: primaryButton.text
            font.pixelSize: 14
            font.family: Theme.fontUi
            font.weight: Font.DemiBold
            color: Theme.color("text.onAccent")
        }

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            enabled: primaryButton.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: primaryButton.triggered()
        }
    }

    component LoginSecondaryButton: Rectangle {
        id: secondaryButton
        property string text: ""
        property bool enabled: true
        signal triggered()

        Layout.preferredHeight: 44
        radius: 12
        color: secondaryMouse.pressed ? Theme.color("surface.sunken") : Theme.color("surface.base")
        border.color: secondaryMouse.containsMouse ? Theme.alpha("accent.strong", 0.42) : Theme.alpha("accent.strong", 0.30)
        border.width: 1
        opacity: enabled ? (secondaryMouse.pressed ? 0.72 : secondaryMouse.containsMouse ? 0.88 : 1.0) : 0.45

        Text {
            anchors.centerIn: parent
            text: secondaryButton.text
            font.pixelSize: 14
            font.family: Theme.fontUi
            font.weight: Font.DemiBold
            color: Theme.color("accent.strong")
        }

        MouseArea {
            id: secondaryMouse
            anchors.fill: parent
            enabled: secondaryButton.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: secondaryButton.triggered()
        }

        Behavior on opacity { NumberAnimation { duration: 100 } }
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }
    }

    component LoginPlainButton: Rectangle {
        id: plainButton
        property string text: ""
        property bool destructive: false
        signal triggered()

        implicitWidth: plainLabel.implicitWidth + 8
        Layout.preferredHeight: 30
        radius: 8
        color: plainMouse.pressed ? Theme.alpha("line.soft", 0.48) : "transparent"

        Text {
            id: plainLabel
            anchors.centerIn: parent
            text: plainButton.text
            font.pixelSize: 14
            font.family: Theme.fontUi
            font.weight: Font.Medium
            color: plainButton.destructive ? Theme.color("state.danger") : Theme.color("text.secondary")
        }

        MouseArea {
            id: plainMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: plainButton.triggered()
        }
    }

    component LoginDisclosureRow: Rectangle {
        id: disclosure
        property string text: ""
        property bool expanded: false
        signal triggered()

        Layout.preferredHeight: 34
        radius: 9
        color: disclosureMouse.pressed ? Theme.alpha("line.soft", 0.42) : "transparent"

        Item {
            anchors.fill: parent

            Text {
                anchors.centerIn: parent
                text: disclosure.text
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 13
                font.family: Theme.fontUi
                font.weight: Font.Medium
                color: Theme.color("text.secondary")
            }

            ShapeIcon {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                pathData: Icons.chevronRight
                size: 16
                iconColor: Theme.color("text.tertiary")
                rotation: disclosure.expanded ? 90 : 0

                Behavior on rotation { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            }
        }

        MouseArea {
            id: disclosureMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: disclosure.triggered()
        }
    }

    component LoginQrPreview: Rectangle {
        id: qrPreview
        property string qrText: ""
        readonly property int cells: 29
        readonly property int cellSize: 5

        function finder(row, col, top, left) {
            var r = row - top
            var c = col - left
            if (r < 0 || c < 0 || r > 6 || c > 6)
                return false
            return r === 0 || r === 6 || c === 0 || c === 6 || (r >= 2 && r <= 4 && c >= 2 && c <= 4)
        }

        function moduleOn(index) {
            var row = Math.floor(index / cells)
            var col = index % cells
            if (finder(row, col, 1, 1) || finder(row, col, 1, cells - 8) || finder(row, col, cells - 8, 1))
                return true
            if (qrText === "")
                return false
            var len = qrText.length
            var code = qrText.charCodeAt((row * 7 + col * 13) % len)
            return ((code + row * 17 + col * 31 + row * col) % 9) < 4
        }

        Layout.preferredWidth: 172
        Layout.preferredHeight: 172
        radius: 16
        color: Theme.color("surface.base")
        border.color: Theme.color("line.soft")
        border.width: 1

        Rectangle {
            anchors.fill: parent
            anchors.margins: 10
            radius: 12
            color: qrPreview.qrText === "" ? Theme.color("surface.sunken") : "#FFFFFF"
        }

        Grid {
            id: qrGrid
            anchors.centerIn: parent
            columns: qrPreview.cells
            rows: qrPreview.cells
            spacing: 0
            visible: qrPreview.qrText !== ""

            Repeater {
                model: qrPreview.cells * qrPreview.cells

                Rectangle {
                    width: qrPreview.cellSize
                    height: qrPreview.cellSize
                    color: qrPreview.moduleOn(index) ? "#111111" : "#FFFFFF"
                }
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 10
            visible: qrPreview.qrText === ""

            ShapeIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                pathData: Icons.iot
                size: 34
                iconColor: "#8E8E93"
            }

            Text {
                width: 126
                text: "生成后用手机 App 扫描"
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 12
                font.family: Theme.fontUi
                color: "#8E8E93"
            }
        }
    }
}
