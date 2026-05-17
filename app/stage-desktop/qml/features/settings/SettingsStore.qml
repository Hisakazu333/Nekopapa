import QtQuick

QtObject {
    id: store
    property var state: SettingsState {}

    function setCategory(index: int) {
        state.activeCategory = index
    }

    function setTheme(mode: int) {
        state.themeMode = mode
        Theme.mode = mode
    }
}
