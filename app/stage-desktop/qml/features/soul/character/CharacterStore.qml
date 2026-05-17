import QtQuick

QtObject {
    id: store
    property var state: CharacterState {}

    function selectCharacter(index: int) {
        var chars = state.characters.slice()
        for (var i = 0; i < chars.length; i++) {
            chars[i].selected = (i === index)
        }
        state.characters = chars
        state.selectedIndex = index
    }
}
