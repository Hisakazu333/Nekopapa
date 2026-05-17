import QtQuick

QtObject {
    property var messages: [
        {
            "text": "今天肚子怎么样呀，Lumia？",
            "isUser": true,
            "time": "21:12"
        },
        {
            "text": "今天阳光很温暖呢～ 我在窗边看书，还闻到了你泡的红茶，感觉特别幸福。",
            "isUser": false,
            "time": "21:13",
            "liked": true
        },
        {
            "text": "听起来真不错！最喜欢今天的哪个时刻？",
            "isUser": true,
            "time": "21:14"
        },
        {
            "text": "大概是我们一起做晚饭的时候吧～ 你切菜的样子，好认真呢。",
            "isUser": false,
            "time": "21:15",
            "liked": true
        },
        {
            "text": "嘿嘿，没发现哦",
            "isUser": true,
            "time": "21:15"
        }
    ]
    property bool isTyping: false
    property string characterName: "Lumia"
}
