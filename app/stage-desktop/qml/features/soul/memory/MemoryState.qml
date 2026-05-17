import QtQuick

QtObject {
    property var memories: [
        { summary: "\u4E00\u8D77\u770B\u4E86\u65E5\u843D", date: "2026-05-10", intensity: 0.8 },
        { summary: "\u4ECA\u5929\u7684\u65E9\u9910\u5F88\u597D\u5403", date: "2026-05-12", intensity: 0.5 },
        { summary: "\u804A\u4E86\u5F88\u4E45\u7684\u5929", date: "2026-05-13", intensity: 0.7 },
        { summary: "\u5B66\u4E60\u4E86\u65B0\u7684\u77E5\u8BC6", date: "2026-05-14", intensity: 0.6 }
    ]
    property int selectedIndex: -1
}
