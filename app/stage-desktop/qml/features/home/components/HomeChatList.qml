import QtQuick

ListView {
    id: root
    clip: true
    verticalLayoutDirection: ListView.BottomToTop
    spacing: 10

    delegate: Item {
        width: root.width
        height: bubble.height + 4

        HomeChatBubble {
            id: bubble
            anchors.right: model.isUser ? parent.right : undefined
            anchors.left: model.isUser ? undefined : parent.left
            anchors.rightMargin: 8
            anchors.leftMargin: 8
            fromUser: model.isUser
            text: model.text
            bubbleScale: 1.0
            bubbleOpacity: 1.0
        }
    }
}
