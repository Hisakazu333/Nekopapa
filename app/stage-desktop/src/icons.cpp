#include "icons.h"

Icons::Icons(QObject* parent) : QObject(parent) {}

// Navigation
QString Icons::home() const {
    return QStringLiteral("M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V9z M9 22V12h6v10");
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
    return QStringLiteral("M5 12.55a11 11 0 0 1 14.08 0 M1.42 9a16 16 0 0 1 21.16 0 M8.53 16.11a6 6 0 0 1 6.95 0");
}
QString Icons::settings() const {
    return QStringLiteral("M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z");
}

// Actions
QString Icons::send() const {
    return QStringLiteral("M22 2L11 13 M22 2l-7 20-4-9-9-4 20-7z");
}
QString Icons::mic() const {
    return QStringLiteral("M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3z M19 10v2a7 7 0 0 1-14 0v-2 M12 19v4 M8 23h8");
}
QString Icons::volume() const {
    return QStringLiteral("M11 5L6 9H2v6h4l5 4V5z M19.07 4.93a10 10 0 0 1 0 14.14M15.54 8.46a5 5 0 0 1 0 7.07");
}
QString Icons::moon() const {
    return QStringLiteral("M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z");
}
QString Icons::sun() const {
    return QStringLiteral("M12 1v2 M12 21v2 M4.22 4.22l1.42 1.42 M18.36 18.36l1.42 1.42 M1 12h2 M21 12h2 M4.22 19.78l1.42-1.42 M18.36 5.64l1.42-1.42 M12 17a5 5 0 1 0 0-10 5 5 0 0 0 0 10z");
}
QString Icons::search() const {
    return QStringLiteral("M11 19a8 8 0 1 0 0-16 8 8 0 0 0 0 16z M21 21l-4.35-4.35");
}
QString Icons::close() const {
    return QStringLiteral("M18 6L6 18 M6 6l12 12");
}
QString Icons::check() const {
    return QStringLiteral("M20 6L9 17l-5-5");
}
QString Icons::chevronRight() const {
    return QStringLiteral("M9 18l6-6-6-6");
}
QString Icons::chevronLeft() const {
    return QStringLiteral("M15 18l-6-6 6-6");
}
QString Icons::chevronDown() const {
    return QStringLiteral("M6 9l6 6 6-6");
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
    return QStringLiteral("M8.25 9.05c1.06 0 1.92-1.08 1.92-2.42S9.31 4.21 8.25 4.21 6.33 5.29 6.33 6.63s.86 2.42 1.92 2.42z M15.75 9.05c1.06 0 1.92-1.08 1.92-2.42s-.86-2.42-1.92-2.42-1.92 1.08-1.92 2.42.86 2.42 1.92 2.42z M5.05 13.45c.99 0 1.8-.96 1.8-2.15s-.81-2.15-1.8-2.15-1.8.96-1.8 2.15.81 2.15 1.8 2.15z M18.95 13.45c.99 0 1.8-.96 1.8-2.15s-.81-2.15-1.8-2.15-1.8.96-1.8 2.15.81 2.15 1.8 2.15z M12 11.1c-2.7 0-5.45 2.46-5.45 5.05 0 1.47 1.05 2.42 2.36 2.42.95 0 1.71-.47 3.09-.47s2.14.47 3.09.47c1.31 0 2.36-.95 2.36-2.42 0-2.59-2.75-5.05-5.45-5.05z");
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
