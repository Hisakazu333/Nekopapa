import QtQuick

QtObject {
    property int activeCategory: 0
    property int themeMode: 0 // 0=light, 1=diary, 2=dark
    property bool autoStart: false
    property bool advancedMode: false
    property bool ttsEnabled: true
    property bool sttEnabled: false
    property string language: "zh-CN"
    property string llmProvider: "OpenAI"
}
