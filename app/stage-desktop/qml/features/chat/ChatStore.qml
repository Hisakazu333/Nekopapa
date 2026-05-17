import QtQuick

QtObject {
    id: store
    property var state: ChatState {}

    function sendMessage(text: string) {
        var trimmed = text.trim()
        if (!trimmed) return
        var msgs = state.messages.slice()
        msgs.push({ text: trimmed, isUser: true, time: Qt.formatTime(new Date(), "hh:mm") })
        state.messages = msgs
        state.isTyping = true

        replyTimer.interval = 600 + Math.random() * 800
        replyTimer.start()
    }

    function onReplyReceived() {
        var replies = [
            "我在听呢，你慢慢说就好。",
            "嗯嗯，这件事我想记下来。",
            "如果你愿意，我们可以继续聊这个。",
            "今天也辛苦啦，我会陪着你的。",
            "我明白了，听起来这对你很重要。"
        ]
        var reply = replies[Math.floor(Math.random() * replies.length)]
        var msgs = state.messages.slice()
        msgs.push({ text: reply, isUser: false, time: Qt.formatTime(new Date(), "hh:mm"), liked: true })
        state.messages = msgs
        state.isTyping = false
    }

    property var _timers: Item {
        Timer {
            id: replyTimer
            interval: 1000
            onTriggered: store.onReplyReceived()
        }
    }
}
