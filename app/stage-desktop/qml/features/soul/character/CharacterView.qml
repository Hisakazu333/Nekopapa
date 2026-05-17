import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import NNA.Core 1.0

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "\uD83D\uDC3E \u89D2\u8272"
                font.pixelSize: 22
                font.family: Theme.fontUi
                font.weight: Font.Bold
                color: Theme.color("text.primary")
            }

            Item { Layout.fillWidth: true }

            // Import button
            NNABaseButton {
                text: "+ \u5BFC\u5165\u6A21\u578B"
                buttonType: NNABaseButton.ButtonType.Primary
                onClicked: folderDialog.open()
            }
        }

        // Model grid
        GridView {
            id: modelGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 160
            cellHeight: 200
            clip: true
            model: modelManager.modelList

            delegate: Item {
                width: modelGrid.cellWidth
                height: modelGrid.cellHeight

                property bool isCurrent: modelData.isCurrent

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 6
                    radius: Theme.radiusLg
                    color: Theme.color("surface.base")
                    border.color: isCurrent ? Theme.color("accent.base")
                                 : cardMouse.containsMouse ? Theme.alpha("accent.base", 0.3)
                                 : Theme.color("line.soft")
                    border.width: isCurrent ? 2 : 1
                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        // Model preview
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 100
                            height: 100
                            radius: Theme.radiusMd
                            color: Theme.alpha("accent.base", 0.06)
                            clip: true

                            NNAAvatarCanvas {
                                anchors.fill: parent
                                modelPath: modelData.path
                                visible: modelLoaded
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "\uD83D\uDC31"
                                font.pixelSize: 48
                                opacity: 0.6
                                visible: !modelData.path || modelData.path === ""
                            }
                        }

                        // Model name
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.name
                            font.pixelSize: 13
                            font.family: Theme.fontUi
                            font.weight: Font.DemiBold
                            color: Theme.color("text.primary")
                            elide: Text.ElideRight
                            width: 120
                            horizontalAlignment: Text.AlignHCenter
                        }

                        // Status badge
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: badgeText.implicitWidth + 16
                            height: 24
                            radius: 12
                            color: isCurrent ? Theme.color("accent.base") : Theme.alpha("accent.base", 0.1)

                            Text {
                                id: badgeText
                                anchors.centerIn: parent
                                text: isCurrent ? "\u4F7F\u7528\u4E2D" : "\u5207\u6362"
                                font.pixelSize: 11
                                font.family: Theme.fontUi
                                color: isCurrent ? Theme.color("text.onAccent") : Theme.color("accent.base")
                            }
                        }
                    }

                    // Preset indicator
                    Text {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 8
                        text: modelData.isPreset ? "\u2B50" : ""
                        font.pixelSize: 12
                        visible: modelData.isPreset
                    }

                    MouseArea {
                        id: cardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onClicked: function(mouse) {
                            if (mouse.button === Qt.RightButton) {
                                if (!modelData.isPreset) {
                                    contextMenu.modelId = modelData.id
                                    contextMenu.popup()
                                }
                            } else {
                                modelManager.switchModel(modelData.id)
                            }
                        }
                    }
                }
            }
        }

        // Empty state
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: modelManager.modelList.length === 0

            Column {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\uD83D\uDE3F"
                    font.pixelSize: 64
                    opacity: 0.4
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "\u8FD8\u6CA1\u6709\u6A21\u578B\u54E6\uFF0C\u5BFC\u5165\u4E00\u4E2A\u5427\uFF01"
                    font.pixelSize: 14
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }
            }
        }
    }

    // Context menu for delete
    Menu {
        id: contextMenu
        property string modelId: ""

        MenuItem {
            text: "\u5220\u9664\u6A21\u578B"
            onTriggered: modelManager.removeModel(contextMenu.modelId)
        }
    }

    // Folder dialog for import
    FolderDialog {
        id: folderDialog
        title: "\u9009\u62E9 Live2D \u6A21\u578B\u6587\u4EF6\u5939"
        onAccepted: {
            modelManager.importModel(selectedFolder)
        }
    }
}
