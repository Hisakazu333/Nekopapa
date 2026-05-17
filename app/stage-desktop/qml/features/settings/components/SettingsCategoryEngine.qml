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
            title: "\u5F15\u64CE\u53C2\u6570"
            SettingsRow {
                label: "Tick \u9891\u7387"
                description: "\u6BCF\u79D2\u66F4\u65B0\u6B21\u6570"
                Slider {
                    from: 1; to: 60; value: 1
                    Layout.preferredWidth: 120
                }
            }
            SettingsRow {
                label: "\u9AD8\u7EA7\u6A21\u5F0F"
                description: "\u663E\u793A\u66F4\u591A\u8C03\u8BD5\u53C2\u6570"
                Switch {
                    checked: settingsStore.state.advancedMode
                    onCheckedChanged: settingsStore.state.advancedMode = checked
                }
            }
        }
    }
}
