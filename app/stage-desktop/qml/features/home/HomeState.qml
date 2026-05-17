import QtQuick

QtObject {
    id: state

    // Greeting
    property string greetingText: ""
    property string dateText: ""
    property string catSpeech: ""

    // Chat
    property var messages: []
    property bool isTyping: false

    // Physiology
    property real pleasure: 0
    property real arousal: 0
    property real dominance: 0
    property real satiety: 0
    property real hydration: 0
    property real energy: 0

    // Mood & character
    property string mood: ""
    property string characterName: ""

    // Model adjustment
    property real modelScaleFactor: 1.0
    property real modelOffsetXAdjust: 0.0
    property real modelOffsetYAdjust: 0.0
    property bool modelAdjustOpen: false
}
