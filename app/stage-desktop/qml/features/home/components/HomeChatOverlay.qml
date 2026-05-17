import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property var messages: []
    property bool isTyping: false

    ListView {
        id: chatList
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: inputBar.top
        anchors.bottomMargin: 12
        clip: true
        verticalLayoutDirection: ListView.BottomToTop
        spacing: 8
        model: root.messages

        delegate: HomeChatBubble {
            fromUser: modelData.isUser
            text: modelData.text
            avatarEmoji: modelData.isUser ? "\uD83D\uDC64" : "\uD83D\uDC31"
        }
    }

    Row {
        anchors.left: parent.left
        anchors.bottom: inputBar.top
        anchors.bottomMargin: 8
        spacing: 4
        visible: root.isTyping
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Rectangle {
            width: 28
            height: 28
            radius: 14
            color: Theme.alpha("accent.base", 0.15)
            Text {
                anchors.centerIn: parent
                text: "\uD83D\uDC31"
                font.pixelSize: 14
            }
        }

        Rectangle {
            width: 56
            height: 28
            radius: 14
            color: Theme.glass(0.7)
            border.color: Theme.alpha("line.soft", 0.4)
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: 3
                Repeater {
                    model: 3
                    delegate: Rectangle {
                        width: 5
                        height: 5
                        radius: 2.5
                        color: Theme.color("accent.base")

                        SequentialAnimation on y {
                            loops: Animation.Infinite
                            PauseAnimation { duration: index * 150 }
                            NumberAnimation { to: -4; duration: 400; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 0; duration: 400; easing.type: Easing.InOutSine }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: inputBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 52
        radius: 26
        color: Theme.glass(0.85)
        border.color: Theme.alpha("line.soft", 0.5)
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 8
            spacing: 8

            TextField {
                id: textField
                Layout.fillWidth: true
                Layout.fillHeight: true
                background: Item {}
                placeholderText: "\u8DDF " + appController.characterName + " \u804A\u804A..."
                placeholderTextColor: Theme.color("text.tertiary")
                color: Theme.color("text.primary")
                font.pixelSize: 14
                font.family: Theme.fontUi
                verticalAlignment: TextInput.AlignVCenter

                Keys.onReturnPressed: {
                    if (text.trim() !== "") {
                        root.sendMessage(text)
                        text = ""
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 20
                color: sendMouse.containsPressed ? Theme.color("accent.strong")
                     : textField.text.trim() !== "" ? Theme.color("accent.base")
                     : Theme.alpha("accent.base", 0.1)

                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: "\u2191"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    color: textField.text.trim() !== "" ? Theme.color("text.onAccent") : Theme.color("text.tertiary")
                }

                MouseArea {
                    id: sendMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (textField.text.trim() !== "") {
                            root.sendMessage(textField.text)
                            textField.text = ""
                        }
                    }
                }
            }
        }
    }

    function sendMessage(text) {
        root.messages.unshift({ isUser: true, text: text })
        root.messages = root.messages
        appController.sendMessage(text)
        root.isTyping = true
        typingTimer.start()
    }

    Timer {
        id: typingTimer
        interval: 1500
        onTriggered: {
            root.isTyping = false
            root.messages.unshift({ isUser: false, text: "\u55B5\uFF5E \u6211\u542C\u5230\u4E86\uFF01" })
            root.messages = root.messages
        }
    }
}
