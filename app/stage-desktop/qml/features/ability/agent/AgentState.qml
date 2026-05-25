import QtQuick

QtObject {
    id: state

    property string workspaceName: agentWorkspace.workspaceName
    property string workspacePath: agentWorkspace.workspacePath
    property string repoName: agentWorkspace.repoName
    property string branchName: agentWorkspace.branchName
    property string activeEditorPath: agentWorkspace.activeEditorPath
    property string activeEditorName: activeEditorPath.split("/").pop()
    property string changeSummary: agentWorkspace.changeSummary
    property string inputPlaceholder: "跟 Lumia 说，或直接指令 Agent..."

    property var activityItems: [
        { "label": "Explorer", "active": true, "kind": "explorer" },
        { "label": "Search", "active": false, "kind": "search" },
        { "label": "Source Control", "active": false, "kind": "source" },
        { "label": "Run", "active": false, "kind": "run" },
        { "label": "Settings", "active": false, "kind": "settings" }
    ]

    property var fileTree: agentWorkspace.projectTree(96)
    property var changedFiles: agentWorkspace.changedFiles(48)
    property var editorTabs: agentWorkspace.editorTabs(7)
    property var editorRows: agentWorkspace.editorRows(activeEditorPath, 96)
    property var terminalEntries: agentWorkspace.terminalEntries(10)

    property var approvals: changedFiles.length === 0 ? [] : [
        {
            "title": "验证当前工作区",
            "subtitle": "cmake --build build --target OpenNekoEngine -j4",
            "detail": changeSummary
        }
    ]
}
