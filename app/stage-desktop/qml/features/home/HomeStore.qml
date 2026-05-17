import QtQuick

QtObject {
    id: store

    property var state: HomeState {}

    Component.onCompleted: {
        refreshPhysiology()
        refreshGreeting()
        refreshCatSpeech()
    }

    function refreshPhysiology() {
        state.pleasure = appController.pleasure
        state.arousal = appController.arousal
        state.dominance = appController.dominance
        state.satiety = appController.satiety
        state.hydration = appController.hydration
        state.energy = appController.energy
        state.mood = appController.currentMood
        state.characterName = appController.characterName
    }

    function refreshGreeting() {
        var h = new Date().getHours()
        if (h < 6) state.greetingText = "\u591C\u6DF1\u4E86\u2026"
        else if (h < 11) state.greetingText = "\u65E9\u4E0A\u597D\u2728"
        else if (h < 14) state.greetingText = "\u4E2D\u5348\u597D\u2600"
        else if (h < 18) state.greetingText = "\u4E0B\u5348\u597D\u2615"
        else if (h < 22) state.greetingText = "\u665A\u4E0A\u597D\U0001F319"
        else state.greetingText = "\u591C\u6DF1\u4E86\u2026"

        state.dateText = Qt.formatDateTime(new Date(), "M\u6708d\u65E5 dddd")
    }

    function refreshCatSpeech() {
        var lines = [
            "\u4ECA\u5929\u8FC7\u5F97\u600E\u4E48\u6837\uFF1F\u8981\u4E0D\u8981\u804A\u804A\uFF1F",
            "\u6211\u521A\u624D\u5728\u60F3\u4F60\u5462\uFF5E",
            "\u6709\u4EC0\u4E48\u70E6\u5FC3\u4E8B\u53EF\u4EE5\u544A\u8BC9\u6211\u54E6",
            "\u5462\u5462\u2026\u4ECA\u5929\u5929\u6C14\u771F\u597D\u5440",
            "\u8981\u4E0D\u8981\u4E00\u8D77\u505A\u70B9\u4EC0\u4E48\uFF1F",
            "\u6211\u6709\u70B9\u65E0\u804A\u2026\u964D\u4F60\u6765\u964D\u4F60\u6765\uFF01"
        ]
        state.catSpeech = lines[Math.floor(Math.random() * lines.length)]
    }

    function sendMessage(text: string) {
        var trimmed = text.trim()
        if (!trimmed) return

        var msgs = state.messages.slice()
        msgs.push({ text: trimmed, isUser: true, time: new Date() })
        state.messages = msgs
        state.isTyping = true

        appController.sendMessage(trimmed)

        replyTimer.interval = 600 + Math.random() * 800
        replyTimer.start()
    }

    function onReplyReceived() {
        var replies = [
            "\u55B5\uFF5E\u6211\u77E5\u9053\u4E86\uFF01",
            "\u563F\u563F\uFF0C\u4F60\u8BF4\u5F97\u5BF9\u5462\uFF5E",
            "\u8981\u4E0D\u8981\u4F11\u606F\u4E00\u4E0B\u5440\uFF1F",
            "\u6211\u5728\u542C\u5462\uFF0C\u7EE7\u7EED\u8BF4\u5427\uFF5E",
            "\u4ECA\u5929\u8FC7\u5F97\u600E\u4E48\u6837\u5440\uFF1F",
            "\u8FD9\u6837\u554A\u2026\u2026\u6211\u8BB0\u4F4F\u4E86\uFF01",
            "\u5462\u5462\uFF0C\u7136\u540E\u5462\uFF1F"
        ]
        var reply = replies[Math.floor(Math.random() * replies.length)]
        var msgs = state.messages.slice()
        msgs.push({ text: reply, isUser: false, time: new Date() })
        state.messages = msgs
        state.isTyping = false
    }

    property var _timers: Item {
        Timer {
            id: replyTimer
            interval: 1000
            onTriggered: store.onReplyReceived()
        }
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: store.refreshPhysiology()
        }
    }
}
