import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    enum ButtonType { Primary, Secondary, Ghost }

    property int buttonType: NNABaseButton.ButtonType.Primary
    property string text: ""
    property string iconPath: "" // Icons path string
    property bool enabled: true

    signal clicked()

    Layout.preferredHeight: 40
    Layout.fillWidth: false
    implicitWidth: contentRow.implicitWidth + 28

    radius: 14
    color: {
        if (!enabled) return Theme.color("surface.sunken")
        switch (buttonType) {
            case NNABaseButton.ButtonType.Primary: return Theme.color("accent.strong")
            case NNABaseButton.ButtonType.Secondary: return Theme.color("surface.base")
            case NNABaseButton.ButtonType.Ghost: return "transparent"
        }
        return "transparent"
    }
    border.color: {
        if (!enabled) return Theme.color("line.soft")
        switch (buttonType) {
            case NNABaseButton.ButtonType.Primary: return "transparent"
            case NNABaseButton.ButtonType.Secondary: return Theme.color("line.soft")
            case NNABaseButton.ButtonType.Ghost: return "transparent"
        }
        return "transparent"
    }
    border.width: buttonType === NNABaseButton.ButtonType.Secondary ? 1 : 0

    // Hover / Press effects
    scale: mouseArea.pressed ? 0.97 : (mouseArea.containsMouse ? 1.02 : 1.0)
    opacity: enabled ? 1.0 : 0.5

    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 120 } }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        ShapeIcon {
            visible: root.iconPath !== ""
            pathData: root.iconPath
            size: 18
            iconColor: root.textColor
        }

        Text {
            visible: root.text !== ""
            text: root.text
            font.pixelSize: 14
            font.family: Theme.fontUi
            font.weight: Font.DemiBold
            color: root.textColor
        }
    }

    property color textColor: {
        if (!enabled) return Theme.color("text.tertiary")
        switch (buttonType) {
            case NNABaseButton.ButtonType.Primary: return Theme.color("text.onAccent")
            case NNABaseButton.ButtonType.Secondary: return Theme.color("text.primary")
            case NNABaseButton.ButtonType.Ghost: return Theme.color("accent.base")
        }
        return Theme.color("text.primary")
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: root.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
