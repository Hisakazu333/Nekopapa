import QtQuick

QtObject {
    id: root

    property real windowWidth: 0
    property real windowHeight: 0
    property real dividerWidth: 1
    property real contentMaxWidth: 1168

    readonly property real contentGutter: windowWidth < 1120 ? 24 : 38
    readonly property real sidebarWidth: Math.round(clamp(windowWidth * 0.20, windowWidth < 980 ? 236 : 260, 336))
    readonly property real mainAreaX: sidebarWidth + dividerWidth
    readonly property real mainAreaWidth: Math.max(1, windowWidth - mainAreaX)
    readonly property real contentWidth: Math.round(Math.max(1, Math.min(mainAreaWidth - contentGutter * 2, contentMaxWidth)))
    readonly property real contentX: Math.round(mainAreaX + (mainAreaWidth - contentWidth) / 2)
    readonly property real contentCenterX: contentX + contentWidth / 2

    readonly property real dockMaxWidth: Math.max(1, Math.min(540, windowWidth - 48))
    readonly property real dockMinWidth: Math.max(1, Math.min(440, dockMaxWidth))
    readonly property real dockWidth: Math.round(clamp(windowWidth * 0.42, dockMinWidth, dockMaxWidth))
    readonly property real dockHeight: 58
    readonly property real dockBottomMargin: 28
    readonly property real dockRadius: dockHeight / 2
    readonly property real dockClearance: dockHeight + dockBottomMargin + 24

    function clamp(value, minValue, maxValue) {
        return Math.max(minValue, Math.min(maxValue, value))
    }
}
