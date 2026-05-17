import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    default property alias content: contentArea.children
    property bool hoverable: true
    property bool hovered: hoverable && mouseArea.containsMouse

    radius: Theme.radiusLg
    color: Theme.color("surface.base")
    border.color: Theme.color("line.soft")
    border.width: 1

    // Elevation via subtle shadow (simulated with a bottom rect for cross-platform)
    Rectangle {
        id: shadowRect
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"
        z: -1
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 2
            radius: parent.radius
            color: Theme.alpha("overlay.scrim", 0.03)
        }
    }

    // Hover: surface lifts to raised
    Behavior on color { ColorAnimation { duration: 150 } }
    states: State {
        when: root.hovered
        PropertyChanges { target: root; color: Theme.color("surface.raised") }
        PropertyChanges { target: shadowRect.children[0]; color: Theme.alpha("overlay.scrim", 0.06) }
    }

    Item {
        id: contentArea
        anchors.fill: parent
        anchors.margins: 16
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.hoverable
        cursorShape: root.hoverable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }

    signal clicked()
}
