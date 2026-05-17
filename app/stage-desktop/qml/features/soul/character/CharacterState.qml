import QtQuick

QtObject {
    property var characters: [
        { name: "Lumia", affinity: 4, selected: true },
        { name: "Nyx", affinity: 2, selected: false },
        { name: "Aria", affinity: 3, selected: false }
    ]
    property int selectedIndex: 0
}
