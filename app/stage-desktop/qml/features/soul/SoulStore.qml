import QtQuick

QtObject {
    id: store
    property var state: SoulState {}

    function setTab(index: int) {
        state.currentTab = index
    }
}
