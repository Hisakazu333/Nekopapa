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
            title: "AI \u914D\u7F6E"
            SettingsRow {
                label: "LLM Provider"
                ComboBox {
                    model: ["OpenAI", "Claude", "Local"]
                    currentIndex: 0
                }
            }
            SettingsRow {
                label: "API Key"
                NNABaseInput {
                    placeholderText: "sk-..."
                    echoMode: TextInput.Password
                    Layout.preferredWidth: 240
                }
            }
            SettingsRow {
                label: "TTS \u8BED\u97F3\u5408\u6210"
                Switch {
                    checked: settingsStore.state.ttsEnabled
                    onCheckedChanged: settingsStore.state.ttsEnabled = checked
                }
            }
            SettingsRow {
                label: "STT \u8BED\u97F3\u8F93\u5165"
                Switch {
                    checked: settingsStore.state.sttEnabled
                    onCheckedChanged: settingsStore.state.sttEnabled = checked
                }
            }
        }
    }
}
