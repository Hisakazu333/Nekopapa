import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

ScrollView {
    clip: true
    contentHeight: col.height + 40

    ColumnLayout {
        id: col
        width: parent.width
        spacing: 24

        SettingsGroup {
            title: "\u684C\u5BA0\u8BBE\u7F6E"
            SettingsRow {
                label: "\u7A97\u53E3\u5927\u5C0F"
                Slider {
                    from: 100; to: 500; value: 300
                    Layout.preferredWidth: 120
                }
            }
            SettingsRow {
                label: "\u52A8\u753B\u5E27\u7387"
                Slider {
                    from: 15; to: 120; value: 60
                    Layout.preferredWidth: 120
                }
            }
        }
    }
}
