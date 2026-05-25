import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NNA.Core 1.0

Item {
    id: root

    property real dockClearance: 104
    property string mode: "ide"
    property string workspaceMode: "follow"
    property var shellRef: null

    property string selectedPath: agentStore.state.activeEditorPath
    property string baseContent: ""
    property string workingContent: ""
    property string diffText: ""
    property var diffRowsModel: agentWorkspace.diffRows(selectedPath, 90)
    property var editorRowsModel: agentWorkspace.editorRows(selectedPath, 220)
    property var projectTreeModel: agentWorkspace.projectTree(140)
    property string terminalOutput: agentWorkspace.terminalText(16)
    property var changedFileModel: agentWorkspace.changedFiles(80)
    property bool editorDirty: false
    property bool loadingFile: false
    property string actionStatus: ""

    readonly property var s: agentStore.state
    readonly property bool compact: width < 1180 || height < 760
    readonly property real frameMargin: 0
    readonly property real frameWidth: Math.max(1, width)
    readonly property real leftPaneWidth: Math.round(Math.min(330, Math.max(252, frameWidth * 0.23)))
    readonly property real rightPaneWidth: Math.round(Math.min(420, Math.max(330, frameWidth * 0.25)))
    readonly property color panelBorder: Theme.alpha("line.soft", Theme.isDark ? 0.70 : 0.88)
    readonly property color softPanel: Theme.alpha("surface.base", Theme.isDark ? 0.96 : 0.98)

    AgentStore {
        id: agentStore
    }

    function reloadWorkspace() {
        changedFileModel = agentWorkspace.changedFiles(80)
        projectTreeModel = agentWorkspace.projectTree(140)
        editorRowsModel = agentWorkspace.editorRows(selectedPath, 220)
        diffText = agentWorkspace.gitDiff(selectedPath, 140000)
        diffRowsModel = agentWorkspace.diffRows(selectedPath, 90)
        terminalOutput = agentWorkspace.terminalText(16)
    }

    function openFile(path) {
        if (!path || path.length === 0)
            return
        loadingFile = true
        selectedPath = path
        baseContent = agentWorkspace.gitBaseFile(path, 300000)
        workingContent = agentWorkspace.readFile(path, 300000)
        diffText = agentWorkspace.gitDiff(path, 140000)
        diffRowsModel = agentWorkspace.diffRows(path, 90)
        editorRowsModel = agentWorkspace.editorRows(path, 220)
        loadingFile = false
        editorDirty = false
        actionStatus = ""
    }

    function lineNumbersFor(content) {
        var count = Math.max(1, content.split("\n").length)
        var lines = []
        for (var i = 1; i <= count; ++i)
            lines.push(i)
        return lines.join("\n")
    }

    function saveFile() {
        var ok = agentWorkspace.writeFile(selectedPath, workingContent)
        editorDirty = !ok
        actionStatus = ok ? "Saved " + selectedPath : "Save failed"
        reloadWorkspace()
    }

    function runBuild() {
        terminalOutput = "Running cmake build..."
        terminalOutput = agentWorkspace.runBuild()
        reloadWorkspace()
    }

    Component.onCompleted: openFile(selectedPath)

    Rectangle {
        anchors.fill: parent
        color: Theme.color("bg.canvas")
    }

    Loader {
        anchors.fill: parent
        sourceComponent: root.mode === "ide" ? idePage : dailyPage
    }

    Component {
        id: idePage

        Rectangle {
            anchors.fill: parent
            radius: 0
            color: Theme.color("surface.base")
            border.width: 0
            clip: true

            RowLayout {
                anchors.fill: parent
                spacing: 0

                CompanionPane {
                    Layout.preferredWidth: root.leftPaneWidth
                    Layout.fillHeight: true
                }

                PaneDivider {}

                CenterPane {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                PaneDivider {}

                OperationsPane {
                    Layout.preferredWidth: root.rightPaneWidth
                    Layout.fillHeight: true
                }
            }
        }
    }

    Component {
        id: dailyPage

        Rectangle {
            anchors.fill: parent
            anchors.margins: root.frameMargin
            anchors.bottomMargin: root.dockClearance + 12
            radius: 8
            color: Theme.color("surface.base")
            border.color: root.panelBorder
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "Daily"
                font.pixelSize: 22
                font.family: Theme.fontUi
                font.weight: Font.Black
                color: Theme.color("text.primary")
            }
        }
    }

    component CompanionPane: Rectangle {
        color: Theme.alpha("surface.raised", Theme.isDark ? 0.82 : 0.94)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.compact ? 8 : 12
            spacing: root.compact ? 8 : 10

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: appController.characterName + " 伴随"
                    elide: Text.ElideRight
                    font.pixelSize: 15
                    font.family: Theme.fontUi
                    font.weight: Font.Black
                    color: Theme.color("text.primary")
                }

                Rectangle {
                    Layout.preferredWidth: 7
                    Layout.preferredHeight: 7
                    radius: 4
                    color: Theme.color("state.success")
                }

                Text {
                    text: "在线"
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }

                SmallSelect {
                    text: "待命"
                }
            }

            CompanionStage {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(250, Math.min(430, parent.height * 0.46))
            }

            InfoCard {
                Layout.fillWidth: true
                title: "当前状态"
                accentText: appController.currentMood

                Text {
                    Layout.fillWidth: true
                    text: "角色：" + appController.characterName + " · 互动 " + appController.interactionCount + " 次 · 记忆 " + appController.memoryCount + " 条"
                    wrapMode: Text.Wrap
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }

            InfoCard {
                Layout.fillWidth: true
                title: "当前任务"
                accentText: "查看详情"

                Text {
                    Layout.fillWidth: true
                    text: root.selectedPath
                    elide: Text.ElideMiddle
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                StatusChip {
                    Layout.fillWidth: true
                    label: "模式"
                    value: "受控执行"
                    tone: Theme.color("state.success")
                }

                StatusChip {
                    Layout.fillWidth: true
                    label: "情绪"
                    value: appController.currentMood
                    tone: Theme.color("state.warning")
                }
            }

            InfoCard {
                Layout.fillWidth: true
                title: "能量"
                accentText: Math.round(appController.energy) + "%"

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    MetricBar {
                        Layout.fillWidth: true
                        label: "活力"
                        value: appController.energy
                        tone: Theme.color("state.danger")
                    }

                    MetricBar {
                        Layout.fillWidth: true
                        label: "饱食"
                        value: appController.satiety
                        tone: Theme.color("state.warning")
                    }

                    MetricBar {
                        Layout.fillWidth: true
                        label: "水分"
                        value: appController.hydration
                        tone: Theme.color("state.success")
                    }
                }
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                NavButton {
                    Layout.fillWidth: true
                    label: "记忆"
                    iconPath: Icons.memory
                    onClicked: if (root.shellRef) root.shellRef.currentPage = 2
                }

                NavButton {
                    Layout.fillWidth: true
                    label: "状态"
                    iconPath: Icons.status
                    onClicked: if (root.shellRef) root.shellRef.currentPage = 5
                }

                NavButton {
                    Layout.fillWidth: true
                    label: "设置"
                    iconPath: Icons.settings
                    onClicked: if (root.shellRef) root.shellRef.currentPage = 5
                }
            }
        }

    }

    component CenterPane: Rectangle {
        color: Theme.color("bg.canvas")

        Item {
            anchors.fill: parent

            EditorTabsBar {
                id: tabsBar
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 44
            }

            Rectangle {
                id: tabsDivider
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: tabsBar.bottom
                height: 1
                color: root.panelBorder
            }

            Loader {
                id: centerLoader
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: tabsDivider.bottom
                anchors.bottom: root.workspaceMode === "follow" ? commandBar.top : parent.bottom
                sourceComponent: root.workspaceMode === "editor" ? editorWorkbenchComponent : followWorkbenchComponent
            }

            CommandBar {
                id: commandBar
                z: 2
                visible: root.workspaceMode === "follow"
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                anchors.bottomMargin: root.dockClearance + 8
                height: root.compact ? 88 : 96
            }

            Component {
                id: followWorkbenchComponent

                Flickable {
                    anchors.fill: parent
                    clip: true
                    contentWidth: width
                    contentHeight: centerColumn.implicitHeight + 18
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: centerColumn
                        width: parent.width
                        spacing: root.compact ? 8 : 10

                        FollowPanel {
                            Layout.fillWidth: true
                            Layout.leftMargin: 14
                            Layout.rightMargin: 14
                            Layout.topMargin: 14
                        }

                        DiffWorkbench {
                            Layout.fillWidth: true
                            Layout.leftMargin: 14
                            Layout.rightMargin: 14
                            Layout.preferredHeight: root.compact ? 330 : 420
                        }
                    }
                }
            }

            Component {
                id: editorWorkbenchComponent

                EditorWorkbench {
                    anchors.fill: parent
                }
            }
        }

    }

    component OperationsPane: Rectangle {
        color: Theme.alpha("surface.raised", Theme.isDark ? 0.82 : 0.94)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.compact ? 8 : 12
            spacing: root.compact ? 8 : 10
            visible: root.workspaceMode !== "editor"

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 34

                Text {
                    Layout.fillWidth: true
                    text: "Agent 操作"
                    font.pixelSize: 16
                    font.family: Theme.fontUi
                    font.weight: Font.Black
                    color: Theme.color("text.primary")
                }

                IconButton {
                    iconPath: Icons.status
                    onClicked: root.reloadWorkspace()
                }

                IconButton {
                    iconPath: Icons.more
                }
            }

            InfoCard {
                Layout.fillWidth: true
                title: "源代码管理"
                accentText: root.s.branchName

                RepoRow {
                    Layout.fillWidth: true
                }
            }

            InfoCard {
                Layout.fillWidth: true
                title: "变更摘要"
                accentText: root.changedFileModel.length + " files"

                Text {
                    Layout.fillWidth: true
                    text: root.s.changeSummary
                    wrapMode: Text.Wrap
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }

            InfoCard {
                Layout.fillWidth: true
                title: "更改的文件"
                accentText: root.changedFileModel.length

                Text {
                    visible: root.changedFileModel.length === 0
                    Layout.fillWidth: true
                    text: "工作区干净"
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }

                Repeater {
                    model: root.changedFileModel

                    delegate: ChangedFileRow {
                        Layout.fillWidth: true
                        fileName: modelData.fileName
                        path: modelData.path
                        added: modelData.added
                        removed: modelData.removed
                        status: modelData.status
                        active: root.selectedPath === modelData.path
                        onClicked: root.openFile(path)
                    }
                }
            }

            InfoCard {
                Layout.fillWidth: true
                title: "待批准的操作"
                accentText: root.editorDirty ? "1" : "0"

                ApprovalRow {
                    Layout.fillWidth: true
                    title: "写入文件"
                    subtitle: root.selectedPath
                    enabledAction: root.editorDirty
                    onReject: root.openFile(root.selectedPath)
                    onAllow: root.saveFile()
                }

                ApprovalRow {
                    Layout.fillWidth: true
                    title: "运行命令"
                    subtitle: "cmake --build build --target OpenNekoEngine -j4"
                    enabledAction: true
                    onReject: root.actionStatus = "Build skipped"
                    onAllow: root.runBuild()
                }
            }

            InfoCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "执行日志"
                accentText: "真实"

                TextArea {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    readOnly: true
                    text: root.terminalOutput
                    wrapMode: TextEdit.NoWrap
                    font.pixelSize: 10
                    font.family: Theme.fontMono
                    color: Theme.color("text.secondary")
                    background: Rectangle {
                        radius: 6
                        color: Theme.alpha("surface.sunken", Theme.isDark ? 0.48 : 0.55)
                        border.color: root.panelBorder
                        border.width: 1
                    }
                }
            }
        }

        ExplorerPane {
            anchors.fill: parent
            visible: root.workspaceMode === "editor"
        }
    }

    component EditorTabsBar: Rectangle {
        color: root.softPanel

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 6

            ModeTab {
                label: "实时跟随"
                iconPath: Icons.sparkle
                active: root.workspaceMode === "follow"
                onClicked: root.workspaceMode = "follow"
            }

            ModeTab {
                label: "编辑器"
                iconPath: Icons.ability
                active: root.workspaceMode === "editor"
                onClicked: root.workspaceMode = "editor"
            }

            FileTab {
                Layout.preferredWidth: Math.min(260, Math.max(180, parent.width * 0.22))
                label: root.selectedPath.split("/").pop()
                dirty: root.editorDirty
            }

            IconButton {
                iconPath: Icons.plus
            }

            Item { Layout.fillWidth: true }

            SmallPill {
                text: root.actionStatus
                visible: root.actionStatus.length > 0
                tone: root.actionStatus.indexOf("failed") >= 0 ? Theme.color("state.danger") : Theme.color("state.success")
            }
        }
    }

    component FollowPanel: Item {
        implicitHeight: root.compact ? 372 : 416

        ColumnLayout {
            id: followColumn
            anchors.fill: parent
            anchors.margins: 0
            spacing: 10

            Text {
                text: "对话与执行流"
                font.pixelSize: 16
                font.family: Theme.fontUi
                font.weight: Font.Black
                color: Theme.color("text.primary")
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.compact ? 146 : 162

                ChatBubble {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    width: Math.min(330, parent.width * 0.34)
                    message: "这个页面为什么这么怪？"
                    user: true
                }

                Row {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: 52
                    spacing: 10

                    AvatarDot {
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    ChatBubble {
                        width: Math.min(360, followColumn.width * 0.38)
                        message: "我先整理问题，再给出改动计划。"
                    }
                }

                TaskNotice {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.topMargin: 100
                    width: Math.min(520, parent.width * 0.56)
                }
            }

            ExecutionPlanCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    component ChatBubble: Rectangle {
        id: bubble
        property string message: ""
        property bool user: false

        implicitHeight: 40
        radius: 10
        color: user ? Theme.alpha("state.danger", 0.08) : Theme.color("surface.base")
        border.color: user ? Theme.alpha("state.danger", 0.24) : root.panelBorder
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 12
            spacing: 10

            Text {
                Layout.fillWidth: true
                text: bubble.message
                elide: Text.ElideRight
                font.pixelSize: 13
                font.family: Theme.fontUi
                color: Theme.color("text.primary")
            }

            Text {
                text: "10:18"
                font.pixelSize: 10
                font.family: Theme.fontMono
                color: Theme.color("text.tertiary")
            }
        }
    }

    component TaskNotice: Rectangle {
        height: 54
        radius: 9
        color: root.softPanel
        border.color: root.panelBorder
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 14
                color: Theme.color("state.warning")

                ShapeIcon {
                    anchors.centerIn: parent
                    pathData: Icons.sparkle
                    size: 14
                    iconColor: "#FFFFFF"
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: "已识别为界面重构任务"
                    elide: Text.ElideRight
                    font.pixelSize: 13
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.primary")
                }

                Text {
                    Layout.fillWidth: true
                    text: "目标：统一信息结构，提升可读性与操作效率"
                    elide: Text.ElideRight
                    font.pixelSize: 11
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }

            Text {
                text: "10:18"
                font.pixelSize: 10
                font.family: Theme.fontMono
                color: Theme.color("text.tertiary")
            }
        }
    }

    component ExecutionPlanCard: Rectangle {
        radius: 10
        color: root.softPanel
        border.color: root.panelBorder
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 26

                Text {
                    Layout.fillWidth: true
                    text: "执行计划（4 步）"
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    font.weight: Font.Black
                    color: Theme.color("text.primary")
                }

                ShapeIcon {
                    pathData: Icons.chevronDown
                    size: 14
                    iconColor: Theme.color("text.tertiary")
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: root.panelBorder
            }

            PlanLine {
                Layout.fillWidth: true
                indexText: "1"
                title: "分析现状"
                subtitle: "梳理当前页面结构与交互问题"
                stateText: "已完成"
                done: true
            }

            PlanLine {
                Layout.fillWidth: true
                indexText: "2"
                title: "制定改动方案"
                subtitle: "统一布局、对齐信息层级、优化视觉样式"
                stateText: "已完成"
                done: true
            }

            PlanLine {
                Layout.fillWidth: true
                indexText: "3"
                title: "修改代码"
                subtitle: "更新 QML 组件与样式"
                stateText: "进行中"
                active: true
            }

            PlanLine {
                Layout.fillWidth: true
                indexText: "4"
                title: "验证与预览"
                subtitle: "本地预览并检查逻辑与样式"
                stateText: "等待中"
            }
        }
    }

    component PlanLine: Item {
        property string indexText: ""
        property string title: ""
        property string subtitle: ""
        property string stateText: ""
        property bool done: false
        property bool active: false

        Layout.preferredHeight: root.compact ? 30 : 34

        RowLayout {
            anchors.fill: parent
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                radius: 11
                color: done || active ? Theme.color("state.success") : Theme.alpha("surface.sunken", 0.78)
                border.color: done || active ? "transparent" : root.panelBorder
                border.width: done || active ? 0 : 1

                Text {
                    anchors.centerIn: parent
                    text: indexText
                    font.pixelSize: 10
                    font.family: Theme.fontMono
                    font.weight: Font.Black
                    color: done || active ? "#FFFFFF" : Theme.color("text.secondary")
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: title
                    elide: Text.ElideRight
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.primary")
                }

                Text {
                    Layout.fillWidth: true
                    text: subtitle
                    elide: Text.ElideRight
                    font.pixelSize: 10
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }

            Text {
                text: stateText
                font.pixelSize: 11
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: done ? Theme.color("state.success") : active ? Theme.color("state.warning") : Theme.color("text.tertiary")
            }
        }
    }

    component ExecutionPanel: Panel {
        implicitHeight: root.compact ? 168 : 190

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: "执行状态"
                    font.pixelSize: 15
                    font.family: Theme.fontUi
                    font.weight: Font.Black
                    color: Theme.color("text.primary")
                }

                ShapeIcon {
                    pathData: Icons.chevronDown
                    size: 15
                    iconColor: Theme.color("text.tertiary")
                }
            }

            StateStep {
                Layout.fillWidth: true
                indexText: "1"
                title: "读取工作区"
                subtitle: root.s.workspaceName
                stateText: "已完成"
                done: true
            }

            StateStep {
                Layout.fillWidth: true
                indexText: "2"
                title: "加载文件"
                subtitle: root.selectedPath
                stateText: "已完成"
                done: root.workingContent.length > 0
            }

            StateStep {
                Layout.fillWidth: true
                indexText: "3"
                title: "同步 Git Diff"
                subtitle: root.s.changeSummary
                stateText: root.changedFileModel.length > 0 ? "有改动" : "干净"
                done: true
            }

            StateStep {
                Layout.fillWidth: true
                indexText: "4"
                title: "验证与构建"
                subtitle: "右侧允许后运行真实构建"
                stateText: "待执行"
                done: false
            }
        }
    }

    component EditorWorkbench: Rectangle {
        color: Theme.color("bg.canvas")

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            EditorFileStrip {
                Layout.fillWidth: true
                Layout.preferredHeight: 42
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: root.panelBorder
            }

            CodeEditorPane {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            TerminalPanel {
                Layout.fillWidth: true
                Layout.preferredHeight: root.compact ? 132 : 158
            }
        }
    }

    component EditorFileStrip: Rectangle {
        color: Theme.alpha("surface.base", Theme.isDark ? 0.96 : 0.98)

        Flickable {
            anchors.fill: parent
            clip: true
            contentWidth: tabRow.implicitWidth + 20
            contentHeight: height
            boundsBehavior: Flickable.StopAtBounds

            RowLayout {
                id: tabRow
                height: parent.height
                spacing: 0

                Repeater {
                    model: root.changedFileModel

                    delegate: EditorTabChip {
                        label: modelData.fileName
                        path: modelData.path
                        dirty: true
                        active: root.selectedPath === modelData.path
                    }
                }
            }
        }
    }

    component EditorTabChip: Rectangle {
        id: tab
        property string label: ""
        property string path: ""
        property bool dirty: false
        property bool active: false

        Layout.preferredWidth: Math.max(140, Math.min(230, tabText.implicitWidth + 56))
        Layout.fillHeight: true
        color: active ? Theme.color("surface.base") : Theme.alpha("surface.sunken", Theme.isDark ? 0.24 : 0.18)
        border.color: active ? root.panelBorder : "transparent"
        border.width: active ? 1 : 0

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 10
            spacing: 8

            Text {
                id: tabText
                Layout.fillWidth: true
                text: tab.label
                elide: Text.ElideRight
                font.pixelSize: 12
                font.family: Theme.fontUi
                font.weight: tab.active ? Font.Black : Font.Medium
                color: tab.active ? Theme.color("text.primary") : Theme.color("text.secondary")
            }

            Rectangle {
                visible: tab.dirty
                Layout.preferredWidth: 7
                Layout.preferredHeight: 7
                radius: 4
                color: Theme.color("state.warning")
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openFile(tab.path)
        }
    }

    component CodeEditorPane: Rectangle {
        color: Theme.color("surface.base")
        border.color: root.panelBorder
        border.width: 1
        clip: true

        Flickable {
            anchors.fill: parent
            clip: true
            contentWidth: width
            contentHeight: codeColumn.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: codeColumn
                width: parent.width

                Repeater {
                    model: root.editorRowsModel

                    delegate: CodeLine {
                        width: codeColumn.width
                        lineNo: modelData.lineNo
                        codeText: modelData.text
                    }
                }
            }
        }
    }

    component CodeLine: Rectangle {
        property string lineNo: ""
        property string codeText: ""

        height: 24
        color: Number(lineNo) % 2 === 0 ? Theme.alpha("surface.sunken", Theme.isDark ? 0.16 : 0.14) : "transparent"

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.preferredWidth: 56
                Layout.fillHeight: true
                color: Theme.alpha("surface.sunken", Theme.isDark ? 0.30 : 0.28)

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: lineNo
                    font.pixelSize: 11
                    font.family: Theme.fontMono
                    color: Theme.color("text.tertiary")
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.leftMargin: 14
                Layout.rightMargin: 16
                text: codeText
                elide: Text.ElideRight
                font.pixelSize: 12
                font.family: Theme.fontMono
                color: Theme.color("text.primary")
            }
        }
    }

    component TerminalPanel: Rectangle {
        color: Theme.alpha("surface.base", Theme.isDark ? 0.96 : 0.98)
        border.color: root.panelBorder
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 28

                Text {
                    Layout.fillWidth: true
                    text: "TERMINAL"
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    font.weight: Font.Black
                    color: Theme.color("text.secondary")
                }

                GhostButton {
                    label: "Build"
                    onClicked: root.runBuild()
                }
            }

            TextArea {
                Layout.fillWidth: true
                Layout.fillHeight: true
                readOnly: true
                text: root.terminalOutput
                wrapMode: TextEdit.NoWrap
                font.pixelSize: 11
                font.family: Theme.fontMono
                color: Theme.color("text.primary")
                background: Rectangle {
                    radius: 6
                    color: Theme.color("surface.base")
                    border.color: root.panelBorder
                    border.width: 1
                }
            }
        }
    }

    component DiffWorkbench: Panel {
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: "文件 Diff / Patch 预览"
                    font.pixelSize: 15
                    font.family: Theme.fontUi
                    font.weight: Font.Black
                    color: Theme.color("text.primary")
                }

                GhostButton {
                    label: "并排对比"
                }

                GhostButton {
                    label: "统一视图"
                }

                GhostButton {
                    label: "展开折叠"
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                DiffPane {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    title: root.selectedPath.split("/").pop() + " (HEAD)"
                    headerTone: Theme.color("state.danger")
                    side: "base"
                }

                DiffPane {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    title: root.selectedPath.split("/").pop() + " (Working)"
                    headerTone: Theme.color("state.success")
                    side: "work"
                }
            }
        }
    }

    component CommandBar: Rectangle {
        color: Theme.color("bg.canvas")
        border.width: 0

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 0
            anchors.rightMargin: 0
            anchors.topMargin: 8
            anchors.bottomMargin: 2
            spacing: 7

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 42
                    radius: 16
                    color: Theme.color("surface.base")
                    border.color: Theme.alpha("state.danger", 0.34)
                    border.width: 1

                    Text {
                        anchors.left: parent.left
                        anchors.right: mic.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 16
                        anchors.rightMargin: 10
                        text: root.s.inputPlaceholder
                        elide: Text.ElideRight
                        font.pixelSize: 12
                        font.family: Theme.fontUi
                        color: Theme.color("text.tertiary")
                    }

                    ShapeIcon {
                        id: mic
                        anchors.right: parent.right
                        anchors.rightMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        pathData: Icons.mic
                        size: 16
                        iconColor: Theme.color("text.secondary")
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    radius: 24
                    color: Theme.color("accent.strong")

                    ShapeIcon {
                        anchors.centerIn: parent
                        pathData: Icons.send
                        size: 20
                        iconColor: "#FFFFFF"
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                GhostButton { label: "添加上下文" }
                GhostButton { label: "运行命令"; onClicked: root.runBuild() }
                GhostButton { label: "生成 Patch"; onClicked: root.reloadWorkspace() }
                GhostButton { label: "新建任务" }
                Item { Layout.fillWidth: true }
            }
        }
    }

    component CompanionStage: Rectangle {
        radius: 14
        color: Theme.alpha("surface.sunken", Theme.isDark ? 0.48 : 0.55)
        border.color: root.panelBorder
        border.width: 1
        clip: true

        NNAAvatarCanvas {
            anchors.fill: parent
            anchors.margins: 6
            modelPath: appController.currentModelPath
            modelScale: 0.90
            modelOffsetX: 0
            modelOffsetY: 0
            visible: modelLoaded || appController.currentModelPath !== ""
        }

        Column {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 8
            spacing: 8

            FloatingIcon { iconPath: Icons.chat }
            FloatingIcon { iconPath: Icons.paw }
            FloatingIcon { iconPath: Icons.heart }
            FloatingIcon { iconPath: Icons.more }
        }
    }

    component InfoCard: Rectangle {
        id: card
        property string title: ""
        property string accentText: ""
        default property alias content: body.data

        implicitHeight: body.implicitHeight + 22
        radius: 8
        color: root.softPanel
        border.color: root.panelBorder
        border.width: 1

        ColumnLayout {
            id: body
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: card.title
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.primary")
                }

                Text {
                    visible: card.accentText !== ""
                    text: card.accentText
                    font.pixelSize: 11
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.tertiary")
                }
            }
        }
    }

    component Panel: Rectangle {
        radius: 8
        color: root.softPanel
        border.color: root.panelBorder
        border.width: 1
        clip: true
    }

    component DiffPane: Rectangle {
        id: pane
        property string title: ""
        property color headerTone: Theme.color("accent.strong")
        property string side: "base"

        radius: 7
        color: Theme.color("surface.base")
        border.color: root.panelBorder
        border.width: 1
        clip: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                color: Theme.alpha(pane.headerTone, 0.10)
                border.color: Theme.alpha(pane.headerTone, 0.44)
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    width: parent.width - 18
                    horizontalAlignment: Text.AlignHCenter
                    text: pane.title
                    elide: Text.ElideMiddle
                    font.pixelSize: 11
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.secondary")
                }
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: width
                contentHeight: diffColumn.implicitHeight

                Column {
                    id: diffColumn
                    width: parent.width

                    Repeater {
                        model: root.diffRowsModel

                        delegate: DiffLine {
                            width: diffColumn.width
                            lineNo: pane.side === "base" ? modelData.baseLine : modelData.workLine
                            codeText: pane.side === "base" ? modelData.baseText : modelData.workText
                            kind: modelData.kind
                            side: pane.side
                        }
                    }
                }
            }
        }
    }

    component DiffLine: Rectangle {
        property string lineNo: ""
        property string codeText: ""
        property string kind: "context"
        property string side: "base"

        height: 21
        color: kind === "removed" && side === "base"
            ? Theme.alpha("state.danger", 0.12)
            : kind === "added" && side === "work"
                ? Theme.alpha("state.success", 0.12)
                : Theme.alpha("surface.sunken", Theme.isDark ? 0.30 : 0.24)

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.preferredWidth: 42
                Layout.fillHeight: true
                color: Theme.alpha("surface.sunken", Theme.isDark ? 0.46 : 0.46)

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    text: lineNo
                    font.pixelSize: 10
                    font.family: Theme.fontMono
                    color: Theme.color("text.tertiary")
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    text: codeText
                    elide: Text.ElideRight
                    font.pixelSize: root.compact ? 10 : 11
                    font.family: Theme.fontMono
                    color: kind === "removed" && side === "base"
                        ? Theme.color("state.danger")
                        : kind === "added" && side === "work"
                            ? Theme.color("state.success")
                            : Theme.color("text.primary")
                }
            }
        }
    }

    component ExplorerPane: Item {
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.compact ? 8 : 12
            spacing: 10

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: root.s.repoName
                    elide: Text.ElideRight
                    font.pixelSize: 16
                    font.family: Theme.fontUi
                    font.weight: Font.Black
                    color: Theme.color("text.primary")
                }

                Text {
                    Layout.fillWidth: true
                    text: root.s.workspacePath
                    elide: Text.ElideMiddle
                    font.pixelSize: 11
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 28

                Text {
                    Layout.fillWidth: true
                    text: "EXPLORER"
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    font.weight: Font.Black
                    color: Theme.color("text.secondary")
                }

                Text {
                    text: root.changedFileModel.length + " changes"
                    font.pixelSize: 11
                    font.family: Theme.fontUi
                    color: Theme.color("text.tertiary")
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                radius: 8
                color: Theme.color("surface.base")
                border.color: root.panelBorder
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    ShapeIcon {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        pathData: Icons.search
                        size: 16
                        iconColor: Theme.color("text.tertiary")
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "Search files"
                        font.pixelSize: 13
                        font.family: Theme.fontUi
                        color: Theme.color("text.tertiary")
                    }
                }
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: width
                contentHeight: explorerColumn.implicitHeight + root.dockClearance + 28
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: explorerColumn
                    width: parent.width

                    Repeater {
                        model: root.projectTreeModel

                        delegate: ExplorerRow {
                            width: explorerColumn.width
                            label: modelData.label
                            path: modelData.path
                            depth: modelData.depth
                            folder: modelData.folder
                            expanded: modelData.expanded
                            active: root.selectedPath === modelData.path
                        }
                    }
                }
            }
        }
    }

    component ExplorerRow: Rectangle {
        id: explorerRow
        property string label: ""
        property string path: ""
        property int depth: 0
        property bool folder: false
        property bool expanded: false
        property bool active: false

        height: 34
        radius: 7
        color: active ? Theme.alpha("state.danger", 0.10) : (rowMouse.containsMouse ? Theme.alpha("surface.sunken", 0.42) : "transparent")

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 6 + explorerRow.depth * 17
            anchors.rightMargin: 8
            spacing: 7

            ShapeIcon {
                visible: explorerRow.folder
                Layout.preferredWidth: 12
                Layout.preferredHeight: 12
                pathData: explorerRow.expanded ? Icons.chevronDown : Icons.chevronRight
                size: 12
                iconColor: Theme.color("text.tertiary")
            }

            Item {
                visible: !explorerRow.folder
                Layout.preferredWidth: 12
                Layout.preferredHeight: 12
            }

            Rectangle {
                Layout.preferredWidth: 17
                Layout.preferredHeight: 17
                radius: explorerRow.folder ? 4 : 3
                color: explorerRow.folder ? Theme.alpha("state.warning", 0.12) : Theme.alpha("state.danger", 0.06)
                border.color: explorerRow.folder ? Theme.alpha("state.warning", 0.36) : Theme.alpha("state.danger", 0.26)
                border.width: 1
            }

            Text {
                Layout.fillWidth: true
                text: explorerRow.label
                elide: Text.ElideRight
                font.pixelSize: 13
                font.family: Theme.fontUi
                font.weight: explorerRow.folder || explorerRow.active ? Font.DemiBold : Font.Medium
                color: explorerRow.active ? Theme.color("state.danger") : Theme.color("text.primary")
            }
        }

        MouseArea {
            id: rowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: explorerRow.folder ? Qt.ArrowCursor : Qt.PointingHandCursor
            onClicked: if (!explorerRow.folder) root.openFile(explorerRow.path)
        }
    }

    component RepoRow: Rectangle {
        radius: 7
        color: Theme.alpha("surface.sunken", Theme.isDark ? 0.46 : 0.50)
        border.color: root.panelBorder
        border.width: 1
        Layout.preferredHeight: 54

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            ShapeIcon {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                pathData: Icons.world
                size: 16
                iconColor: Theme.color("text.secondary")
            }

            Text {
                Layout.fillWidth: true
                text: root.s.repoName
                elide: Text.ElideRight
                font.pixelSize: 12
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: Theme.color("text.primary")
            }

            SmallPill {
                text: root.s.branchName
                tone: Theme.color("state.success")
            }
        }
    }

    component ChangedFileRow: Rectangle {
        id: row
        property string fileName: ""
        property string path: ""
        property string added: ""
        property string removed: ""
        property string status: ""
        property bool active: false
        signal clicked()

        Layout.preferredHeight: 36
        radius: 6
        color: active ? Theme.alpha("accent.soft", 0.52) : (mouse.containsMouse ? Theme.alpha("surface.sunken", 0.50) : "transparent")

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 7

            Rectangle {
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                radius: 4
                color: Theme.alpha("accent.soft", 0.55)

                Text {
                    anchors.centerIn: parent
                    text: row.status.length > 0 ? row.status.charAt(0) : "M"
                    font.pixelSize: 9
                    font.family: Theme.fontUi
                    font.weight: Font.Black
                    color: Theme.color("accent.strong")
                }
            }

            Text {
                Layout.fillWidth: true
                text: row.fileName
                elide: Text.ElideRight
                font.pixelSize: 12
                font.family: Theme.fontUi
                color: Theme.color("text.primary")
            }

            Text {
                visible: row.added !== ""
                text: row.added
                font.pixelSize: 11
                font.family: Theme.fontMono
                color: Theme.color("state.success")
            }

            Text {
                visible: row.removed !== ""
                text: row.removed
                font.pixelSize: 11
                font.family: Theme.fontMono
                color: Theme.color("state.danger")
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: row.clicked()
        }
    }

    component ApprovalRow: Rectangle {
        id: approval
        property string title: ""
        property string subtitle: ""
        property bool enabledAction: true
        signal allow()
        signal reject()

        Layout.preferredHeight: 58
        radius: 8
        opacity: enabledAction ? 1.0 : 0.54
        color: Theme.alpha("state.danger", 0.10)
        border.color: Theme.alpha("state.danger", 0.18)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: approval.title
                    elide: Text.ElideRight
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.primary")
                }

                Text {
                    Layout.fillWidth: true
                    text: approval.subtitle
                    elide: Text.ElideMiddle
                    font.pixelSize: 10
                    font.family: Theme.fontMono
                    color: Theme.color("text.secondary")
                }
            }

            GhostButton {
                label: "拒绝"
                enabled: approval.enabledAction
                onClicked: approval.reject()
            }

            AccentButton {
                label: "允许"
                enabled: approval.enabledAction
                onClicked: approval.allow()
            }
        }
    }

    component StateStep: Item {
        id: step
        property string indexText: ""
        property string title: ""
        property string subtitle: ""
        property string stateText: ""
        property bool done: false

        Layout.preferredHeight: 31

        RowLayout {
            anchors.fill: parent
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                radius: 10
                color: step.done ? Theme.color("state.success") : Theme.alpha("surface.sunken", 0.80)
                border.color: step.done ? "transparent" : root.panelBorder
                border.width: step.done ? 0 : 1

                Text {
                    anchors.centerIn: parent
                    text: step.indexText
                    font.pixelSize: 10
                    font.family: Theme.fontMono
                    font.weight: Font.Black
                    color: step.done ? "#FFFFFF" : Theme.color("text.secondary")
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    Layout.fillWidth: true
                    text: step.title
                    elide: Text.ElideRight
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    font.weight: Font.DemiBold
                    color: Theme.color("text.primary")
                }

                Text {
                    Layout.fillWidth: true
                    text: step.subtitle
                    elide: Text.ElideMiddle
                    font.pixelSize: 10
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }

            Text {
                text: step.stateText
                font.pixelSize: 11
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: step.done ? Theme.color("state.success") : Theme.color("state.warning")
            }
        }
    }

    component Bubble: Rectangle {
        property string title: ""
        property string detail: ""
        property color tone: Theme.color("accent.strong")

        Layout.preferredHeight: 58
        radius: 9
        color: Theme.alpha(tone, 0.08)
        border.color: Theme.alpha(tone, 0.22)
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 3

            Text {
                Layout.fillWidth: true
                text: parent.parent.title
                elide: Text.ElideRight
                font.pixelSize: 12
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: Theme.color("text.primary")
            }

            Text {
                Layout.fillWidth: true
                text: parent.parent.detail
                elide: Text.ElideMiddle
                font.pixelSize: 10
                font.family: Theme.fontUi
                color: Theme.color("text.secondary")
            }
        }
    }

    component MetricBar: Item {
        property string label: ""
        property real value: 0
        property color tone: Theme.color("accent.strong")

        Layout.preferredHeight: 22

        RowLayout {
            anchors.fill: parent
            spacing: 8

            Text {
                Layout.preferredWidth: 42
                text: label
                font.pixelSize: 11
                font.family: Theme.fontUi
                color: Theme.color("text.secondary")
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 5
                radius: 3
                color: Theme.alpha("line.soft", 0.62)

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, value / 100))
                    height: parent.height
                    radius: parent.radius
                    color: tone
                }
            }

            Text {
                Layout.preferredWidth: 34
                horizontalAlignment: Text.AlignRight
                text: Math.round(value) + "%"
                font.pixelSize: 11
                font.family: Theme.fontMono
                color: Theme.color("text.secondary")
            }
        }
    }

    component StatusChip: Rectangle {
        property string label: ""
        property string value: ""
        property color tone: Theme.color("accent.strong")

        implicitHeight: 32
        radius: 8
        color: Theme.alpha(tone, 0.10)
        border.color: Theme.alpha(tone, 0.22)
        border.width: 1

        Text {
            anchors.centerIn: parent
            width: parent.width - 12
            horizontalAlignment: Text.AlignHCenter
            text: label + "  " + value
            elide: Text.ElideRight
            font.pixelSize: 11
            font.family: Theme.fontUi
            font.weight: Font.DemiBold
            color: tone
        }
    }

    component ModeTab: Rectangle {
        property string label: ""
        property string iconPath: ""
        property bool active: false
        signal clicked()

        implicitWidth: tabRow.implicitWidth + 20
        Layout.preferredHeight: 32
        radius: 8
        color: active ? Theme.alpha("state.success", 0.12) : Theme.color("surface.base")
        border.color: active ? Theme.alpha("state.success", 0.26) : root.panelBorder
        border.width: 1

        Row {
            id: tabRow
            anchors.centerIn: parent
            spacing: 7

            ShapeIcon {
                anchors.verticalCenter: parent.verticalCenter
                pathData: iconPath
                size: 14
                iconColor: active ? Theme.color("state.success") : Theme.color("text.secondary")
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: label
                font.pixelSize: 12
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: active ? Theme.color("text.primary") : Theme.color("text.secondary")
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component FileTab: Rectangle {
        property string label: ""
        property bool dirty: false

        Layout.preferredHeight: 32
        radius: 8
        color: Theme.color("surface.base")
        border.color: root.panelBorder
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 8
            spacing: 7

            Text {
                Layout.fillWidth: true
                text: label
                elide: Text.ElideRight
                font.pixelSize: 12
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: Theme.color("text.primary")
            }

            Rectangle {
                visible: dirty
                Layout.preferredWidth: 7
                Layout.preferredHeight: 7
                radius: 4
                color: Theme.color("state.warning")
            }

            ShapeIcon {
                Layout.preferredWidth: 12
                Layout.preferredHeight: 12
                pathData: Icons.close
                size: 12
                iconColor: Theme.color("text.tertiary")
            }
        }
    }

    component SmallSelect: Rectangle {
        property string text: ""
        implicitWidth: selectText.implicitWidth + 30
        implicitHeight: 28
        radius: 8
        color: Theme.color("surface.base")
        border.color: root.panelBorder
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: 6

            Text {
                id: selectText
                text: parent.parent.text
                font.pixelSize: 11
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: Theme.color("text.secondary")
            }

            ShapeIcon {
                anchors.verticalCenter: parent.verticalCenter
                pathData: Icons.chevronDown
                size: 11
                iconColor: Theme.color("text.tertiary")
            }
        }
    }

    component SmallPill: Rectangle {
        property string text: ""
        property color tone: Theme.color("text.secondary")

        implicitWidth: pillText.implicitWidth + 14
        implicitHeight: 22
        radius: 7
        color: Theme.alpha(tone, 0.11)
        visible: text !== ""

        Text {
            id: pillText
            anchors.centerIn: parent
            text: parent.text
            font.pixelSize: 10
            font.family: Theme.fontUi
            font.weight: Font.DemiBold
            color: parent.tone
        }
    }

    component NavButton: Rectangle {
        id: button
        property string label: ""
        property string iconPath: ""
        signal clicked()

        Layout.preferredHeight: 34
        radius: 8
        color: mouse.containsMouse ? Theme.alpha("surface.sunken", 0.60) : Theme.color("surface.base")
        border.color: root.panelBorder
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: 6

            ShapeIcon {
                anchors.verticalCenter: parent.verticalCenter
                pathData: button.iconPath
                size: 13
                iconColor: Theme.color("text.secondary")
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: button.label
                font.pixelSize: 12
                font.family: Theme.fontUi
                font.weight: Font.DemiBold
                color: Theme.color("text.secondary")
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }

    component GhostButton: Rectangle {
        id: button
        property string label: ""
        signal clicked()

        implicitWidth: labelText.implicitWidth + 22
        implicitHeight: 28
        radius: 8
        opacity: enabled ? 1.0 : 0.45
        color: mouse.containsMouse && enabled ? Theme.alpha("surface.sunken", 0.62) : Theme.color("surface.base")
        border.color: root.panelBorder
        border.width: 1

        Text {
            id: labelText
            anchors.centerIn: parent
            text: button.label
            font.pixelSize: 11
            font.family: Theme.fontUi
            font.weight: Font.DemiBold
            color: Theme.color("text.secondary")
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            enabled: button.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }

    component AccentButton: Rectangle {
        id: button
        property string label: ""
        signal clicked()

        implicitWidth: labelText.implicitWidth + 22
        implicitHeight: 28
        radius: 8
        opacity: enabled ? 1.0 : 0.45
        color: Theme.color("state.danger")

        Text {
            id: labelText
            anchors.centerIn: parent
            text: button.label
            font.pixelSize: 11
            font.family: Theme.fontUi
            font.weight: Font.DemiBold
            color: "#FFFFFF"
        }

        MouseArea {
            anchors.fill: parent
            enabled: button.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }

    component IconButton: Rectangle {
        id: button
        property string iconPath: ""
        signal clicked()

        implicitWidth: 28
        implicitHeight: 28
        radius: 8
        color: mouse.containsMouse ? Theme.alpha("surface.sunken", 0.62) : "transparent"
        border.color: mouse.containsMouse ? root.panelBorder : "transparent"
        border.width: mouse.containsMouse ? 1 : 0

        ShapeIcon {
            anchors.centerIn: parent
            pathData: button.iconPath
            size: 14
            iconColor: Theme.color("text.secondary")
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }

    component FloatingIcon: Rectangle {
        property string iconPath: ""
        width: 34
        height: 34
        radius: 17
        color: Theme.alpha("surface.base", Theme.isDark ? 0.72 : 0.82)
        border.color: root.panelBorder
        border.width: 1

        ShapeIcon {
            anchors.centerIn: parent
            pathData: parent.iconPath
            size: 14
            iconColor: Theme.color("text.secondary")
        }
    }

    component AvatarDot: Rectangle {
        width: 38
        height: 38
        Layout.preferredWidth: 38
        Layout.preferredHeight: 38
        radius: 19
        color: Theme.alpha("accent.soft", 0.58)
        border.color: Theme.alpha("accent.base", 0.34)
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: appController.characterName.length > 0 ? appController.characterName.charAt(0) : "N"
            font.pixelSize: 15
            font.family: Theme.fontUi
            font.weight: Font.Black
            color: Theme.color("accent.strong")
        }
    }

    component PaneDivider: Rectangle {
        Layout.preferredWidth: 1
        Layout.fillHeight: true
        color: root.panelBorder
    }
}
