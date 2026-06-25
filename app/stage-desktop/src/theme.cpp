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
        p[QStringLiteral("bg.canvas")] = QColor(QStringLiteral("#F7F7F5"));
        p[QStringLiteral("bg.sidebar")] = QColor(QStringLiteral("#F1F0ED"));
        p[QStringLiteral("surface.sunken")] = QColor(QStringLiteral("#F1F0ED"));
        p[QStringLiteral("surface.base")] = QColor(QStringLiteral("#FFFFFF"));
        p[QStringLiteral("surface.raised")] = QColor(QStringLiteral("#FFFFFF"));
        p[QStringLiteral("surface.float")] = QColor(QStringLiteral("#FFFFFF"));
        p[QStringLiteral("line.soft")] = QColor(QStringLiteral("#E4E1DC"));
        p[QStringLiteral("line.strong")] = QColor(QStringLiteral("#D4D0C8"));
        p[QStringLiteral("text.primary")] = QColor(QStringLiteral("#202329"));
        p[QStringLiteral("text.secondary")] = QColor(QStringLiteral("#626873"));
        p[QStringLiteral("text.tertiary")] = QColor(QStringLiteral("#8B9099"));
        p[QStringLiteral("accent.base")] = QColor(QStringLiteral("#D95C82"));
        p[QStringLiteral("accent.strong")] = QColor(QStringLiteral("#B95A78"));
        p[QStringLiteral("accent.soft")] = QColor(QStringLiteral("#F4D8E2"));
        p[QStringLiteral("text.onAccent")] = QColor(QStringLiteral("#FFF9FB"));
        p[QStringLiteral("state.success")] = QColor(QStringLiteral("#2F8F63"));
        p[QStringLiteral("state.warning")] = QColor(QStringLiteral("#A96A25"));
        p[QStringLiteral("state.danger")] = QColor(QStringLiteral("#C94A4A"));
        p[QStringLiteral("info")] = QColor(QStringLiteral("#3E6EA8"));
        p[QStringLiteral("overlay.scrim")] = QColor(QStringLiteral("#0F141C"));
        p[QStringLiteral("apple.canvas")] = QColor(QStringLiteral("#F5F5F7"));
        p[QStringLiteral("apple.sidebar")] = QColor(QStringLiteral("#EBEBED"));
        p[QStringLiteral("apple.grouped")] = QColor(QStringLiteral("#FFFFFF"));
        p[QStringLiteral("apple.hairline")] = QColor(QStringLiteral("#D2D2D7"));
        p[QStringLiteral("apple.ink")] = QColor(QStringLiteral("#1D1D1F"));
        p[QStringLiteral("apple.secondary")] = QColor(QStringLiteral("#6E6E73"));
        p[QStringLiteral("apple.tertiary")] = QColor(QStringLiteral("#86868B"));
        p[QStringLiteral("apple.action")] = QColor(QStringLiteral("#007AFF"));
        p[QStringLiteral("apple.actionHover")] = QColor(QStringLiteral("#0066CC"));
        p[QStringLiteral("apple.selection")] = QColor(QStringLiteral("#E8E8ED"));
    } else if (mode == 1) {
        p[QStringLiteral("bg.canvas")] = QColor(QStringLiteral("#F7F7F5"));
        p[QStringLiteral("bg.sidebar")] = QColor(QStringLiteral("#F1F0ED"));
        p[QStringLiteral("surface.sunken")] = QColor(QStringLiteral("#F1F0ED"));
        p[QStringLiteral("surface.base")] = QColor(QStringLiteral("#FFFFFF"));
        p[QStringLiteral("surface.raised")] = QColor(QStringLiteral("#FFFFFF"));
        p[QStringLiteral("surface.float")] = QColor(QStringLiteral("#FFFFFF"));
        p[QStringLiteral("line.soft")] = QColor(QStringLiteral("#E4E1DC"));
        p[QStringLiteral("line.strong")] = QColor(QStringLiteral("#D4D0C8"));
        p[QStringLiteral("text.primary")] = QColor(QStringLiteral("#202329"));
        p[QStringLiteral("text.secondary")] = QColor(QStringLiteral("#626873"));
        p[QStringLiteral("text.tertiary")] = QColor(QStringLiteral("#8B9099"));
        p[QStringLiteral("accent.base")] = QColor(QStringLiteral("#D95C82"));
        p[QStringLiteral("accent.strong")] = QColor(QStringLiteral("#B95A78"));
        p[QStringLiteral("accent.soft")] = QColor(QStringLiteral("#F4D8E2"));
        p[QStringLiteral("text.onAccent")] = QColor(QStringLiteral("#FFF9FB"));
        p[QStringLiteral("state.success")] = QColor(QStringLiteral("#2F8F63"));
        p[QStringLiteral("state.warning")] = QColor(QStringLiteral("#A96A25"));
        p[QStringLiteral("state.danger")] = QColor(QStringLiteral("#C94A4A"));
        p[QStringLiteral("info")] = QColor(QStringLiteral("#3E6EA8"));
        p[QStringLiteral("overlay.scrim")] = QColor(QStringLiteral("#0F141C"));
        p[QStringLiteral("apple.canvas")] = QColor(QStringLiteral("#F5F5F7"));
        p[QStringLiteral("apple.sidebar")] = QColor(QStringLiteral("#EBEBED"));
        p[QStringLiteral("apple.grouped")] = QColor(QStringLiteral("#FFFFFF"));
        p[QStringLiteral("apple.hairline")] = QColor(QStringLiteral("#D2D2D7"));
        p[QStringLiteral("apple.ink")] = QColor(QStringLiteral("#1D1D1F"));
        p[QStringLiteral("apple.secondary")] = QColor(QStringLiteral("#6E6E73"));
        p[QStringLiteral("apple.tertiary")] = QColor(QStringLiteral("#86868B"));
        p[QStringLiteral("apple.action")] = QColor(QStringLiteral("#007AFF"));
        p[QStringLiteral("apple.actionHover")] = QColor(QStringLiteral("#0066CC"));
        p[QStringLiteral("apple.selection")] = QColor(QStringLiteral("#E8E8ED"));
    } else {
        p[QStringLiteral("bg.canvas")] = QColor(QStringLiteral("#0B0B0D"));
        p[QStringLiteral("bg.sidebar")] = QColor(QStringLiteral("#131316"));
        p[QStringLiteral("surface.sunken")] = QColor(QStringLiteral("#131316"));
        p[QStringLiteral("surface.base")] = QColor(QStringLiteral("#191A1E"));
        p[QStringLiteral("surface.raised")] = QColor(QStringLiteral("#212228"));
        p[QStringLiteral("surface.float")] = QColor(QStringLiteral("#2A2D33"));
        p[QStringLiteral("line.soft")] = QColor(QStringLiteral("#31343C"));
        p[QStringLiteral("line.strong")] = QColor(QStringLiteral("#4A505B"));
        p[QStringLiteral("text.primary")] = QColor(QStringLiteral("#F5F7FA"));
        p[QStringLiteral("text.secondary")] = QColor(QStringLiteral("#C6CBD4"));
        p[QStringLiteral("text.tertiary")] = QColor(QStringLiteral("#8E96A3"));
        p[QStringLiteral("accent.base")] = QColor(QStringLiteral("#E995B6"));
        p[QStringLiteral("accent.strong")] = QColor(QStringLiteral("#E06B97"));
        p[QStringLiteral("accent.soft")] = QColor(QStringLiteral("#331A25"));
        p[QStringLiteral("text.onAccent")] = QColor(QStringLiteral("#FFF9FB"));
        p[QStringLiteral("state.success")] = QColor(QStringLiteral("#63C58A"));
        p[QStringLiteral("state.warning")] = QColor(QStringLiteral("#E0A24D"));
        p[QStringLiteral("state.danger")] = QColor(QStringLiteral("#EA6E75"));
        p[QStringLiteral("info")] = QColor(QStringLiteral("#74B9F0"));
        p[QStringLiteral("overlay.scrim")] = QColor(QStringLiteral("#000000"));
        p[QStringLiteral("apple.canvas")] = QColor(QStringLiteral("#1C1C1E"));
        p[QStringLiteral("apple.sidebar")] = QColor(QStringLiteral("#161618"));
        p[QStringLiteral("apple.grouped")] = QColor(QStringLiteral("#2C2C2E"));
        p[QStringLiteral("apple.hairline")] = QColor(QStringLiteral("#3A3A3C"));
        p[QStringLiteral("apple.ink")] = QColor(QStringLiteral("#F5F5F7"));
        p[QStringLiteral("apple.secondary")] = QColor(QStringLiteral("#AEAEB2"));
        p[QStringLiteral("apple.tertiary")] = QColor(QStringLiteral("#8E8E93"));
        p[QStringLiteral("apple.action")] = QColor(QStringLiteral("#0A84FF"));
        p[QStringLiteral("apple.actionHover")] = QColor(QStringLiteral("#409CFF"));
        p[QStringLiteral("apple.selection")] = QColor(QStringLiteral("#3A3A3C"));
    }
    return p;
}
