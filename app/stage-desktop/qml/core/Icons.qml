import QtQuick
import QtQuick.Shapes

QtObject {
    id: icons

    // Returns a reusable Shape component for an icon
    // Usage: Icons.createIcon(parent, Icons.home, 24, Theme.cAccentBase)

    function createIcon(parent: Item, pathData: string, size: real, colorStr: string): Shape {
        var shape = Qt.createQmlObject('
            import QtQuick
            import QtQuick.Shapes
            Shape {
                width: ' + size + '
                height: ' + size + '
                ShapePath {
                    strokeWidth: 1.8
                    strokeColor: "' + colorStr + '"
                    fillColor: "transparent"
                    pathElements: PathSvg { path: "' + pathData + '" }
                }
            }
        ', parent, "DynamicIcon")
        return shape
    }

    // Navigation icons (24x24 viewport)
    readonly property string home:       "M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V9z M9 22V12h6v10"
    readonly property string chat:       "M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7A8.38 8.38 0 0 1 4 11.5a8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"
    readonly property string character:  "M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2 M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z"
    readonly property string memory:     "M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"
    readonly property string status:     "M22 12h-4l-3 9L9 3l-3 9H2"
    readonly property string ability:    "M13 2L3 14h9l-1 8 10-12h-9l1-8z"
    readonly property string world:      "M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20z M2 12h20 M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"
    readonly property string iot:        "M5 12.55a11 11 0 0 1 14.08 0 M1.42 9a16 16 0 0 1 21.16 0 M8.53 16.11a6 6 0 0 1 6.95 0"
    readonly property string settings:   "M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"

    // Action icons
    readonly property string send:       "M22 2L11 13 M22 2l-7 20-4-9-9-4 20-7z"
    readonly property string mic:        "M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z M19 10v2a7 7 0 0 1-14 0v-2 M12 19v4 M8 23h8"
    readonly property string volume:     "M11 5L6 9H2v6h4l5 4V5z M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07"
    readonly property string moon:       "M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"
    readonly property string sun:        "M12 1v2 M12 21v2 M4.22 4.22l1.42 1.42 M18.36 18.36l1.42 1.42 M1 12h2 M21 12h2 M4.22 19.78l1.42-1.42 M18.36 5.64l1.42-1.42 M12 17a5 5 0 1 0 0-10 5 5 0 0 0 0 10z"
    readonly property string search:     "M11 19a8 8 0 1 0 0-16 8 8 0 0 0 0 16z M21 21l-4.35-4.35"
    readonly property string close:      "M18 6L6 18 M6 6l12 12"
    readonly property string check:      "M20 6L9 17l-5-5"
    readonly property string chevronRight: "M9 18l6-6-6-6"
    readonly property string chevronLeft:  "M15 18l-6-6 6-6"
    readonly property string chevronDown:  "M6 9l6 6 6-6"
    readonly property string more:       "M12 13a1 1 0 1 0 0-2 1 1 0 0 0 0 2z M19 13a1 1 0 1 0 0-2 1 1 0 0 0 0 2z M5 13a1 1 0 1 0 0-2 1 1 0 0 0 0 2z"
    readonly property string plus:       "M12 5v14 M5 12h14"
    readonly property string filter:     "M22 3H2l8 9.46V19l4 2v-8.54L22 3z"

    // Physiological / emotional icons
    readonly property string heart:      "M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"
    readonly property string sparkle:    "M12 2l2.4 7.2h7.6l-6 4.8 2.4 7.2-6-4.8-6 4.8 2.4-7.2-6-4.8h7.6z"
    readonly property string zap:        "M13 2L3 14h9l-1 8 10-12h-9l1-8z"
    readonly property string paw:        "M8.25 9.05c1.06 0 1.92-1.08 1.92-2.42S9.31 4.21 8.25 4.21 6.33 5.29 6.33 6.63s.86 2.42 1.92 2.42z M15.75 9.05c1.06 0 1.92-1.08 1.92-2.42s-.86-2.42-1.92-2.42-1.92 1.08-1.92 2.42.86 2.42 1.92 2.42z M5.05 13.45c.99 0 1.8-.96 1.8-2.15s-.81-2.15-1.8-2.15-1.8.96-1.8 2.15.81 2.15 1.8 2.15z M18.95 13.45c.99 0 1.8-.96 1.8-2.15s-.81-2.15-1.8-2.15-1.8.96-1.8 2.15.81 2.15 1.8 2.15z M12 11.1c-2.7 0-5.45 2.46-5.45 5.05 0 1.47 1.05 2.42 2.36 2.42.95 0 1.71-.47 3.09-.47s2.14.47 3.09.47c1.31 0 2.36-.95 2.36-2.42 0-2.59-2.75-5.05-5.45-5.05z"
    readonly property string satiety:    "M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20z M8 12h8 M12 8v8"
    readonly property string hydration:  "M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"
    readonly property string energy:     "M13 2L3 14h9l-1 8 10-12h-9l1-8z"
    readonly property string pleasure:   "M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"
    readonly property string dominance:  "M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"
    readonly property string gamepad:    "M6 11h4M8 9v4 M15 12a1 1 0 1 0 0-2 1 1 0 0 0 0 2z M18 10a1 1 0 1 0 0-2 1 1 0 0 0 0 2z M2 6h20a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2z"
    readonly property string monitor:    "M4 5h16a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2z M8 21h8"
    readonly property string cloud:      "M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z"
    readonly property string lock:       "M7 11V7a5 5 0 0 1 10 0v4 M5 11h14a2 2 0 0 1 2 2v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-7a2 2 0 0 1 2-2z"
    readonly property string cat:        "M12 5c-2.2 0-4.2 1.2-5.2 3.1-.8 1.4-.8 3.1 0 4.5C7.8 14.8 9.8 16 12 16s4.2-1.2 5.2-3.1c.8-1.4.8-3.1 0-4.5C16.2 6.2 14.2 5 12 5z M8.5 8.5c.6 0 1.1-.5 1.1-1.1S9.1 6.3 8.5 6.3s-1.1.5-1.1 1.1.5 1.1 1.1 1.1z M15.5 8.5c.6 0 1.1-.5 1.1-1.1s-.5-1.1-1.1-1.1-1.1.5-1.1 1.1.5 1.1 1.1 1.1z"
    readonly property string laptop:     "M4 6h16v9H4z M2 18h20"
    readonly property string smartphone: "M8 3h8a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2z M11 18h2"
    readonly property string music:      "M9 18V5l12-2v13 M6 21a3 3 0 1 0 0-6 3 3 0 0 0 0 6z M18 19a3 3 0 1 0 0-6 3 3 0 0 0 0 6z"
    readonly property string sleep:      "M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"
    readonly property string bell:       "M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9 M13.73 21a2 2 0 0 1-3.46 0"
}
