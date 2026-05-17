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
            title: "\u9690\u79C1\u4E0E\u5B89\u5168"
            SettingsRow {
                label: "\u52A0\u5BC6\u7B97\u6CD5"
                ComboBox {
                    model: ["AES-256", "ChaCha20"]
                    currentIndex: 0
                }
            }
            SettingsRow {
                label: "LDP \u9690\u79C1\u9884\u7B97 \u03B5"
                Slider {
                    from: 0.1; to: 10.0; value: 1.0
                    Layout.preferredWidth: 120
                }
            }
        }

        SettingsGroup {
            title: "\u6570\u636E\u7BA1\u7406"
            Row {
                spacing: 12
                NNABaseButton {
                    text: "\u5BFC\u51FA\u6570\u636E"
                    buttonType: NNABaseButton.ButtonType.Secondary
                }
                NNABaseButton {
                    text: "\u5220\u9664\u6240\u6709\u6570\u636E"
                    buttonType: NNABaseButton.ButtonType.Ghost
                }
            }
        }
    }
}
