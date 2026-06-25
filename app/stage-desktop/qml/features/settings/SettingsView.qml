import QtQuick
import QtQuick.Layouts

Item {
    id: root

    SettingsStore { id: settingsStore }
    readonly property var s: settingsStore.state

    function openCategory(index) {
        settingsStore.setCategory(index)
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        SettingsSidebar {
            currentIndex: s.activeCategory
            onCategorySelected: function(idx) { settingsStore.setCategory(idx) }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.color("bg.canvas")

            // Right content area
            StackLayout {
                anchors.fill: parent
                anchors.margins: 24
                currentIndex: s.activeCategory

                SettingsCategoryGeneral {}
                SettingsCategoryEngine {}
                SettingsCategoryAI {}
                SettingsCategoryPrivacy {}
                SettingsCategoryPet {}
                SettingsCategoryAbout {}
            }
        }
    }
}
