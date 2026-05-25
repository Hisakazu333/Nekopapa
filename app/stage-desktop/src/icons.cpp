#include "icons.h"

Icons::Icons(QObject* parent) : QObject(parent) {}

#define NNA_LINE_ICON(name) QStringLiteral("qrc:/qt/qml/OpenNeko/qml/assets/icons/line/" name ".svg")

// Navigation
QString Icons::home() const {
    return NNA_LINE_ICON("home");
}
QString Icons::chat() const {
    return QStringLiteral("M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7A8.38 8.38 0 0 1 4 11.5a8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z");
}
QString Icons::character() const {
    return QStringLiteral("M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2 M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z");
}
QString Icons::memory() const {
    return QStringLiteral("M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z");
}
QString Icons::status() const {
    return QStringLiteral("M22 12h-4l-3 9L9 3l-3 9H2");
}
QString Icons::ability() const {
    return QStringLiteral("M13 2L3 14h9l-1 8 10-12h-9l1-8z");
}
QString Icons::world() const {
    return QStringLiteral("M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20z M2 12h20 M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z");
}
QString Icons::iot() const {
    return NNA_LINE_ICON("iot");
}
QString Icons::settings() const {
    return NNA_LINE_ICON("settings");
}

// Actions
QString Icons::send() const {
    return NNA_LINE_ICON("send");
}
QString Icons::mic() const {
    return QStringLiteral("M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z M19 10v2a7 7 0 0 1-14 0v-2 M12 19v4 M8 23h8");
}
QString Icons::volume() const {
    return NNA_LINE_ICON("volume");
}
QString Icons::moon() const {
    return NNA_LINE_ICON("moon");
}
QString Icons::sun() const {
    return NNA_LINE_ICON("sun");
}
QString Icons::search() const {
    return NNA_LINE_ICON("search");
}
QString Icons::close() const {
    return NNA_LINE_ICON("close");
}
QString Icons::check() const {
    return NNA_LINE_ICON("check");
}
QString Icons::chevronRight() const {
    return NNA_LINE_ICON("chevron-right");
}
QString Icons::chevronLeft() const {
    return NNA_LINE_ICON("chevron-left");
}
QString Icons::chevronDown() const {
    return NNA_LINE_ICON("chevron-down");
}
QString Icons::more() const {
    return QStringLiteral("M12 13a1 1 0 1 0 0-2 1 1 0 0 0 0 2z M19 13a1 1 0 1 0 0-2 1 1 0 0 0 0 2z M5 13a1 1 0 1 0 0-2 1 1 0 0 0 0 2z");
}
QString Icons::plus() const {
    return QStringLiteral("M12 5v14 M5 12h14");
}
QString Icons::filter() const {
    return QStringLiteral("M22 3H2l8 9.46V19l4 2v-8.54L22 3z");
}

// Emotional / physio
QString Icons::heart() const {
    return QStringLiteral("M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z");
}
QString Icons::sparkle() const {
    return QStringLiteral("M12 2l2.4 7.2h7.6l-6 4.8 2.4 7.2-6-4.8-6 4.8 2.4-7.2-6-4.8h7.6z");
}
QString Icons::zap() const {
    return QStringLiteral("M13 2L3 14h9l-1 8 10-12h-9l1-8z");
}
QString Icons::paw() const {
    return NNA_LINE_ICON("paw");
}
QString Icons::satiety() const {
    return QStringLiteral("M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20z M8 12h8 M12 8v8");
}
QString Icons::hydration() const {
    return QStringLiteral("M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z");
}
QString Icons::energy() const {
    return QStringLiteral("M13 2L3 14h9l-1 8 10-12h-9l1-8z");
}
QString Icons::pleasure() const {
    return QStringLiteral("M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z");
}
QString Icons::dominance() const {
    return QStringLiteral("M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z");
}
QString Icons::gamepad() const {
    return QStringLiteral("M6 11h4M8 9v4 M15 12a1 1 0 1 0 0-2 1 1 0 0 0 0 2z M18 10a1 1 0 1 0 0-2 1 1 0 0 0 0 2z M2 6h20a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2z");
}
QString Icons::music() const {
    return QStringLiteral("M9 18V5l12-2v13 M6 21a3 3 0 1 0 0-6 3 3 0 0 0 0 6z M18 19a3 3 0 1 0 0-6 3 3 0 0 0 0 6z");
}
QString Icons::sleep() const {
    return QStringLiteral("M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z");
}
QString Icons::bell() const {
    return QStringLiteral("M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9 M13.73 21a2 2 0 0 1-3.46 0");
}

// OpenNeko desktop product icons, kept on a 24x24 line grid.
QString Icons::user() const {
    return NNA_LINE_ICON("user");
}
QString Icons::users() const {
    return QStringLiteral("M16 21v-1.2a4.8 4.8 0 0 0-4.8-4.8H6.8A4.8 4.8 0 0 0 2 19.8V21 M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z M22 21v-1.4a4.2 4.2 0 0 0-3.2-4.1 M16 3.2a4 4 0 0 1 0 7.6");
}
QString Icons::cat() const {
    return NNA_LINE_ICON("cat");
}
QString Icons::monitor() const {
    return NNA_LINE_ICON("monitor");
}
QString Icons::cloud() const {
    return NNA_LINE_ICON("cloud");
}
QString Icons::lock() const {
    return NNA_LINE_ICON("lock");
}
QString Icons::database() const {
    return NNA_LINE_ICON("database");
}
QString Icons::infoCircle() const {
    return NNA_LINE_ICON("info-circle");
}
QString Icons::phone() const {
    return NNA_LINE_ICON("phone");
}
QString Icons::box() const {
    return QStringLiteral("M21 8l-9-5-9 5 9 5 9-5z M3 8v8l9 5 9-5V8 M12 13v8");
}
QString Icons::wallet() const {
    return NNA_LINE_ICON("wallet");
}
QString Icons::shieldCheck() const {
    return NNA_LINE_ICON("shield-check");
}
QString Icons::keyRound() const {
    return NNA_LINE_ICON("key-round");
}
QString Icons::scale() const {
    return NNA_LINE_ICON("scale");
}
QString Icons::pin() const {
    return NNA_LINE_ICON("pin");
}
QString Icons::cursor() const {
    return NNA_LINE_ICON("cursor");
}
QString Icons::clock() const {
    return NNA_LINE_ICON("clock");
}
QString Icons::refresh() const {
    return NNA_LINE_ICON("refresh");
}
QString Icons::play() const {
    return NNA_LINE_ICON("play");
}
