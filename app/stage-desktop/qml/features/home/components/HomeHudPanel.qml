import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

Column {
    id: root
    spacing: 8

    property real pleasure: 0
    property real satiety: 0
    property real hydration: 0
    property real energy: 0
    property real arousal: 0
    property string mood: ""

    HudBadge {
        iconPath: Icons.pleasure
        label: moodText(root.mood)
        badgeColor: Theme.color("accent.base")
    }
    HudBadge {
        iconPath: Icons.satiety
        label: Math.round(root.satiety) + "%"
        badgeColor: Theme.color("state.success")
        progress: root.satiety / 100
    }
    HudBadge {
        iconPath: Icons.hydration
        label: Math.round(root.hydration) + "%"
        badgeColor: Theme.color("info")
        progress: root.hydration / 100
    }
    HudBadge {
        iconPath: Icons.energy
        label: Math.round(root.energy) + "%"
        badgeColor: Theme.color("state.warning")
        progress: root.energy / 100
    }

    component HudBadge: Rectangle {
        property string iconPath: ""
        property string label: ""
        property color badgeColor: Theme.color("accent.base")
        property real progress: -1

        width: 56
        height: progress >= 0 ? 56 : 40
        radius: 12
        color: Theme.color("surface.raised")
        border.color: Theme.color("line.soft")
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 3
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 3
                ShapeIcon { pathData: parent.parent.parent.iconPath; size: 12; iconColor: parent.parent.parent.badgeColor }
                Text {
                    text: parent.parent.parent.label
                    font.pixelSize: 11
                    font.family: Theme.fontMono
                    font.weight: Font.DemiBold
                    color: parent.parent.parent.badgeColor
                }
            }
            Rectangle {
                visible: parent.parent.progress >= 0
                anchors.horizontalCenter: parent.horizontalCenter
                width: 36
                height: 3
                radius: 1.5
                color: Theme.alpha("accent.base", 0.1)
                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, parent.parent.parent.progress))
                    height: parent.height
                    radius: 1.5
                    color: parent.parent.parent.badgeColor
                    Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                }
            }
        }
    }

    function moodText(mood: string): string {
        if (mood === "happy") return "\u5F00\u5FC3"
        if (mood === "calm") return "\u5E73\u9759"
        return "\u4F4E\u843D"
    }
}
