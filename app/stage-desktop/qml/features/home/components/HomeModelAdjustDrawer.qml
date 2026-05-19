import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: parent ? parent.width : 320
    height: parent ? parent.height : 430
    x: store && store.state.modelAdjustOpen ? 0 : width + 40
    y: 0
    radius: 30
    color: Theme.isDark ? Theme.alpha("surface.float", 0.99) : Theme.alpha("surface.base", 0.985)
    border.color: Theme.alpha("line.soft", 0.84)
    border.width: 1
    clip: true
    visible: x < width + 20
    opacity: store && store.state.modelAdjustOpen ? 1 : 0

    property var store: null

    Behavior on x { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on opacity { NumberAnimation { duration: 180 } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 12

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "\u6A21\u578B\u8C03\u8282"
                font.pixelSize: 17
                font.family: Theme.fontUi
                font.weight: Font.Bold
                color: Theme.color("text.primary")
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                radius: 16
                color: closeMouse.containsMouse ? Theme.alpha("accent.base", 0.10) : Theme.alpha("surface.sunken", Theme.isDark ? 0.48 : 0.60)

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
                    onClicked: {
                        if (root.store)
                            root.store.state.modelAdjustOpen = false
                    }
                }
            }
        }

        Flickable {
            id: contentScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            contentWidth: width
            contentHeight: controlsColumn.implicitHeight
            interactive: contentHeight > height

            ColumnLayout {
                id: controlsColumn
                width: contentScroll.width
                spacing: 14

                Text {
                    Layout.fillWidth: true
                    text: "\u5FAE\u8C03 Lumia \u5728\u821E\u53F0\u91CC\u7684\u7AD9\u4F4D\u548C\u6784\u56FE\uff0C\u4E0D\u5F71\u54CD\u5F53\u524D\u5BF9\u8BDD\u3002"
                    wrapMode: Text.WordWrap
                    lineHeight: 1.35
                    font.pixelSize: 12
                    font.family: Theme.fontUi
                    color: Theme.color("text.secondary")
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: 20
                    color: Theme.alpha("surface.sunken", Theme.isDark ? 0.72 : 0.90)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 34
                            radius: 17
                            color: Theme.alpha("accent.base", Theme.isDark ? 0.22 : 0.14)

                            ShapeIcon {
                                anchors.centerIn: parent
                                pathData: Icons.sparkle
                                size: 16
                                iconColor: Theme.color("accent.strong")
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: "\u821E\u53F0\u5C45\u4E2D"
                                font.pixelSize: 12
                                font.family: Theme.fontUi
                                font.weight: Font.DemiBold
                                color: Theme.color("text.primary")
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "\u9002\u5408\u4E3B\u821E\u53F0\u89C6\u89D2\uff0C\u6865\u63A5\u684C\u9762\u4F34\u4F53\u7684\u89C2\u611F"
                                wrapMode: Text.WordWrap
                                font.pixelSize: 11
                                font.family: Theme.fontUi
                                color: Theme.color("text.tertiary")
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    SliderRow {
                        label: "\u7F29\u653E\u7CFB\u6570"
                        from: 0.72; to: 1.28; initialValue: root.store ? root.store.state.modelScaleFactor : 1.0
                        onSliderMoved: function(v) { if (root.store) root.store.state.modelScaleFactor = v }
                    }
                    SliderRow {
                        label: "X \u5FAE\u8C03"
                        from: -0.30; to: 0.30; initialValue: root.store ? root.store.state.modelOffsetXAdjust : 0.0
                        onSliderMoved: function(v) { if (root.store) root.store.state.modelOffsetXAdjust = v }
                    }
                    SliderRow {
                        label: "Y \u5FAE\u8C03"
                        from: -0.24; to: 0.24; initialValue: root.store ? root.store.state.modelOffsetYAdjust : 0.0
                        onSliderMoved: function(v) { if (root.store) root.store.state.modelOffsetYAdjust = v }
                    }
                }
            }
        }
    }

    component SliderRow: ColumnLayout {
        id: sliderRow

        property string label: ""
        property real from: 0
        property real to: 1
        property real initialValue: 0
        signal sliderMoved(real value)

        Layout.fillWidth: true
        spacing: 4
        Text {
            text: sliderRow.label
            font.pixelSize: 12
            font.family: Theme.fontUi
            color: Theme.color("text.secondary")
        }
        RowLayout {
            spacing: 8
            Slider {
                id: sliderCtrl
                Layout.fillWidth: true
                from: sliderRow.from
                to: sliderRow.to
                value: sliderRow.initialValue
                onMoved: sliderRow.sliderMoved(sliderCtrl.value)
            }
            Text {
                text: sliderCtrl.value.toFixed(2)
                font.pixelSize: 11
                font.family: Theme.fontMono
                color: Theme.color("text.tertiary")
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: 42
            }
        }
    }
}
