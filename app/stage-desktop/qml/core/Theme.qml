pragma Singleton
import QtQuick

QtObject {
    id: theme

    property int mode: 0 // 0=light, 1=dark
    readonly property bool isDark: mode === 1

    readonly property var palettes: ({
        0: {
            "bg.canvas":       "#F7F1ED",
            "bg.sidebar":      "#F2E8E2",
            "surface.sunken":  "#EFE3DD",
            "surface.base":    "#FFF9F7",
            "surface.raised":  "#FFFDFB",
            "surface.float":   "#FFFFFF",
            "line.soft":       "#D8CAC3",
            "line.strong":     "#BAA8A1",
            "text.primary":    "#241D1B",
            "text.secondary":  "#5F534E",
            "text.tertiary":   "#887872",
            "accent.base":     "#B56D70",
            "accent.strong":   "#9D5256",
            "accent.soft":     "#F2DDDC",
            "text.onAccent":   "#FFF9F8",
            "state.success":   "#67B68D",
            "state.warning":   "#DA9D54",
            "state.danger":    "#D75E61",
            "overlay.scrim":   "#140F0E"
        },
        1: {
            "bg.canvas":       "#F4EDEB",
            "bg.sidebar":      "#ECE2DE",
            "surface.sunken":  "#E8DDD8",
            "surface.base":    "#FAF7F6",
            "surface.raised":  "#FCFBFA",
            "surface.float":   "#FFFFFF",
            "line.soft":       "#D7CDC8",
            "line.strong":     "#B7A8A2",
            "text.primary":    "#2B2422",
            "text.secondary":  "#615551",
            "text.tertiary":   "#8E817C",
            "accent.base":     "#B37977",
            "accent.strong":   "#9B5D5C",
            "accent.soft":     "#EEDDDC",
            "text.onAccent":   "#FFF9F8",
            "state.success":   "#71B591",
            "state.warning":   "#DFA25A",
            "state.danger":    "#D46866",
            "overlay.scrim":   "#171210"
        }
    })

    function color(role: string): color {
        var p = palettes[mode]
        return p[role] || "#FF00FF"
    }

    function alpha(role: string, opacity: real): color {
        var c = color(role)
        return Qt.rgba(c.r, c.g, c.b, opacity)
    }

    readonly property string cCanvas:      color("bg.canvas")
    readonly property string cSidebar:     color("bg.sidebar")
    readonly property string cSurface:     color("surface.base")
    readonly property string cSunken:      color("surface.sunken")
    readonly property string cRaised:      color("surface.raised")
    readonly property string cFloat:       color("surface.float")
    readonly property string cLineSoft:    color("line.soft")
    readonly property string cLineStrong:  color("line.strong")
    readonly property string cText:        color("text.primary")
    readonly property string cText2:       color("text.secondary")
    readonly property string cText3:       color("text.tertiary")
    readonly property string cAccent:      color("accent.base")
    readonly property string cAccentStrong:color("accent.strong")
    readonly property string cAccentSoft:  color("accent.soft")
    readonly property string cOnAccent:    color("text.onAccent")
    readonly property string cSuccess:     color("state.success")
    readonly property string cWarning:     color("state.warning")
    readonly property string cDanger:      color("state.danger")

    readonly property int radiusSm:  8
    readonly property int radiusMd:  14
    readonly property int radiusLg:  22
    readonly property int radiusXl:  30

    // Backward compat — avoid breaking unused components
    function glass(opacity: real): color {
        var base = color("surface.float")
        return Qt.rgba(base.r, base.g, base.b, opacity)
    }

    function shadow(colorRole: string, elevation: int): color {
        var c = color(colorRole)
        var a = elevation === 1 ? 0.05 : elevation === 2 ? 0.10 : elevation === 3 ? 0.15 : 0.20
        return Qt.rgba(c.r, c.g, c.b, a)
    }

    readonly property string fontUi:  "PingFang SC"
    readonly property string fontMono: "Menlo"
}
