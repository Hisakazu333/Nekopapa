pragma Singleton
import QtQuick

QtObject {
    id: theme

    property int mode: 0 // 0=light, 1=fog, 2=dark
    readonly property bool isDark: mode === 2

    readonly property var palettes: ({
        0: {
            "bg.canvas":       "#F7F7F5",
            "bg.sidebar":      "#F1F0ED",
            "surface.sunken":  "#F1F0ED",
            "surface.base":    "#FFFFFF",
            "surface.raised":  "#FFFFFF",
            "surface.float":   "#FFFFFF",
            "line.soft":       "#E4E1DC",
            "line.strong":     "#D4D0C8",
            "text.primary":    "#202329",
            "text.secondary":  "#626873",
            "text.tertiary":   "#8B9099",
            "accent.base":     "#D95C82",
            "accent.strong":   "#B95A78",
            "accent.soft":     "#F4D8E2",
            "text.onAccent":   "#FFF9FB",
            "state.success":   "#2F8F63",
            "state.warning":   "#A96A25",
            "state.danger":    "#C94A4A",
            "info":            "#3E6EA8",
            "overlay.scrim":   "#0F141C"
        },
        1: {
            "bg.canvas":       "#F7F7F5",
            "bg.sidebar":      "#F1F0ED",
            "surface.sunken":  "#F1F0ED",
            "surface.base":    "#FFFFFF",
            "surface.raised":  "#FFFFFF",
            "surface.float":   "#FFFFFF",
            "line.soft":       "#E4E1DC",
            "line.strong":     "#D4D0C8",
            "text.primary":    "#202329",
            "text.secondary":  "#626873",
            "text.tertiary":   "#8B9099",
            "accent.base":     "#D95C82",
            "accent.strong":   "#B95A78",
            "accent.soft":     "#F4D8E2",
            "text.onAccent":   "#FFF9FB",
            "state.success":   "#2F8F63",
            "state.warning":   "#A96A25",
            "state.danger":    "#C94A4A",
            "info":            "#3E6EA8",
            "overlay.scrim":   "#0F141C"
        },
        2: {
            "bg.canvas":       "#0B0B0D",
            "bg.sidebar":      "#131316",
            "surface.sunken":  "#131316",
            "surface.base":    "#191A1E",
            "surface.raised":  "#212228",
            "surface.float":   "#2A2D33",
            "line.soft":       "#31343C",
            "line.strong":     "#4A505B",
            "text.primary":    "#F5F7FA",
            "text.secondary":  "#C6CBD4",
            "text.tertiary":   "#8E96A3",
            "accent.base":     "#E995B6",
            "accent.strong":   "#E06B97",
            "accent.soft":     "#331A25",
            "text.onAccent":   "#FFF9FB",
            "state.success":   "#63C58A",
            "state.warning":   "#E0A24D",
            "state.danger":    "#EA6E75",
            "info":            "#74B9F0",
            "overlay.scrim":   "#000000"
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
