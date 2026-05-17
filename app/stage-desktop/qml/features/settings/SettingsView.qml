import QtQuick
import QtQuick.Layouts

Item {
    SettingsStore { id: settingsStore }
    readonly property var s: settingsStore.state

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
