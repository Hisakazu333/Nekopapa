#include "theme.h"

Theme::Theme(QObject* parent) : QObject(parent) {}

int Theme::mode() const { return m_mode; }

void Theme::setMode(int mode) {
    if (m_mode != mode) {
        m_mode = mode;
        emit modeChanged();
    }
}

bool Theme::isDark() const { return m_mode == 2; }

QColor Theme::color(const QString& role) const {
    auto p = palette(m_mode);
    auto it = p.find(role);
    if (it != p.end()) return it.value();
    return QColor(QStringLiteral("#FF00FF"));
}

QColor Theme::alpha(const QString& role, qreal a) const {
    QColor c = color(role);
    c.setAlphaF(a);
    return c;
}

QColor Theme::glass(qreal opacity) const {
    QColor base = color(QStringLiteral("surface.float"));
    base.setAlphaF(opacity);
    return base;
}

QColor Theme::shadow(const QString& role, int elevation) const {
    QColor c = color(role);
    qreal a = elevation == 1 ? 0.04 : elevation == 2 ? 0.08 : 0.12;
    c.setAlphaF(a);
    return c;
}

QColor Theme::gradient(const QString& role1, const QString& role2, qreal ratio) const {
    QColor c1 = color(role1);
    QColor c2 = color(role2);
    return QColor::fromRgbF(
        c1.redF() + (c2.redF() - c1.redF()) * ratio,
        c1.greenF() + (c2.greenF() - c1.greenF()) * ratio,
        c1.blueF() + (c2.blueF() - c1.blueF()) * ratio,
        c1.alphaF() + (c2.alphaF() - c1.alphaF()) * ratio
    );
}

QHash<QString, QColor> Theme::palette(int mode) const {
    QHash<QString, QColor> p;
    if (mode == 0) {
        p[QStringLiteral("bg.canvas")] = QColor(QStringLiteral("#F7F1ED"));
        p[QStringLiteral("bg.sidebar")] = QColor(QStringLiteral("#F2E8E2"));
        p[QStringLiteral("surface.sunken")] = QColor(QStringLiteral("#EFE3DD"));
        p[QStringLiteral("surface.base")] = QColor(QStringLiteral("#FFF9F7"));
        p[QStringLiteral("surface.raised")] = QColor(QStringLiteral("#FFFDFB"));
        p[QStringLiteral("surface.float")] = QColor(QStringLiteral("#FFFFFF"));
        p[QStringLiteral("line.soft")] = QColor(QStringLiteral("#D8CAC3"));
        p[QStringLiteral("line.strong")] = QColor(QStringLiteral("#BAA8A1"));
        p[QStringLiteral("text.primary")] = QColor(QStringLiteral("#241D1B"));
        p[QStringLiteral("text.secondary")] = QColor(QStringLiteral("#5F534E"));
        p[QStringLiteral("text.tertiary")] = QColor(QStringLiteral("#887872"));
        p[QStringLiteral("accent.base")] = QColor(QStringLiteral("#B56D70"));
        p[QStringLiteral("accent.strong")] = QColor(QStringLiteral("#9D5256"));
        p[QStringLiteral("accent.soft")] = QColor(QStringLiteral("#F2DDDC"));
        p[QStringLiteral("text.onAccent")] = QColor(QStringLiteral("#FFF9F8"));
        p[QStringLiteral("state.success")] = QColor(QStringLiteral("#67B68D"));
        p[QStringLiteral("state.warning")] = QColor(QStringLiteral("#DA9D54"));
        p[QStringLiteral("state.danger")] = QColor(QStringLiteral("#D75E61"));
        p[QStringLiteral("overlay.scrim")] = QColor(QStringLiteral("#140F0E"));
    } else if (mode == 1) {
        p[QStringLiteral("bg.canvas")] = QColor(QStringLiteral("#F4EDEB"));
        p[QStringLiteral("bg.sidebar")] = QColor(QStringLiteral("#ECE2DE"));
        p[QStringLiteral("surface.sunken")] = QColor(QStringLiteral("#E8DDD8"));
        p[QStringLiteral("surface.base")] = QColor(QStringLiteral("#FAF7F6"));
        p[QStringLiteral("surface.raised")] = QColor(QStringLiteral("#FCFBFA"));
        p[QStringLiteral("surface.float")] = QColor(QStringLiteral("#FFFFFF"));
        p[QStringLiteral("line.soft")] = QColor(QStringLiteral("#D7CDC8"));
        p[QStringLiteral("line.strong")] = QColor(QStringLiteral("#B7A8A2"));
        p[QStringLiteral("text.primary")] = QColor(QStringLiteral("#2B2422"));
        p[QStringLiteral("text.secondary")] = QColor(QStringLiteral("#615551"));
        p[QStringLiteral("text.tertiary")] = QColor(QStringLiteral("#8E817C"));
        p[QStringLiteral("accent.base")] = QColor(QStringLiteral("#B37977"));
        p[QStringLiteral("accent.strong")] = QColor(QStringLiteral("#9B5D5C"));
        p[QStringLiteral("accent.soft")] = QColor(QStringLiteral("#EEDDDC"));
        p[QStringLiteral("text.onAccent")] = QColor(QStringLiteral("#FFF9F8"));
        p[QStringLiteral("state.success")] = QColor(QStringLiteral("#71B591"));
        p[QStringLiteral("state.warning")] = QColor(QStringLiteral("#DFA25A"));
        p[QStringLiteral("state.danger")] = QColor(QStringLiteral("#D46866"));
        p[QStringLiteral("overlay.scrim")] = QColor(QStringLiteral("#171210"));
    } else {
        p[QStringLiteral("bg.canvas")] = QColor(QStringLiteral("#141014"));
        p[QStringLiteral("surface.sunken")] = QColor(QStringLiteral("#1D171C"));
        p[QStringLiteral("surface.base")] = QColor(QStringLiteral("#272026"));
        p[QStringLiteral("surface.raised")] = QColor(QStringLiteral("#312A30"));
        p[QStringLiteral("surface.float")] = QColor(QStringLiteral("#3C333B"));
        p[QStringLiteral("line.soft")] = QColor(QStringLiteral("#423A41"));
        p[QStringLiteral("line.strong")] = QColor(QStringLiteral("#716470"));
        p[QStringLiteral("text.primary")] = QColor(QStringLiteral("#F0E9E9"));
        p[QStringLiteral("text.secondary")] = QColor(QStringLiteral("#C5BBBA"));
        p[QStringLiteral("text.tertiary")] = QColor(QStringLiteral("#988C8C"));
        p[QStringLiteral("accent.base")] = QColor(QStringLiteral("#D89295"));
        p[QStringLiteral("accent.strong")] = QColor(QStringLiteral("#E9A6A9"));
        p[QStringLiteral("accent.soft")] = QColor(QStringLiteral("#46303E"));
        p[QStringLiteral("text.onAccent")] = QColor(QStringLiteral("#2C1D1F"));
        p[QStringLiteral("state.success")] = QColor(QStringLiteral("#82D2A8"));
        p[QStringLiteral("state.warning")] = QColor(QStringLiteral("#F9B96C"));
        p[QStringLiteral("state.danger")] = QColor(QStringLiteral("#F3817F"));
        p[QStringLiteral("overlay.scrim")] = QColor(QStringLiteral("#030303"));
    }
    return p;
}
