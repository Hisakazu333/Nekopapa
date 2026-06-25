/*
 * Project: OpenNeko Engine (NNA Core)
 * Core Architecture by Nekonano-Aether
 * Copyright (c) 2026 Nekonano-Aether. All rights reserved.
 * SPDX-License-Identifier: MIT
 */

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickWindow>
#include <QScreen>
#include <QSettings>
#include <QSurfaceFormat>
#include <QTimer>
#ifdef _WIN32
#include <Windows.h>
#include <cstdio>
#endif
#include "app_controller.h"
#include "agent_workspace_service.h"
#include "nna_model_manager.h"
#include "nna_avatar_canvas.h"
#include "nna_macos_dock.h"
#include "nna_window_chrome.h"
#include "live2d_stage_profile.h"
#include "theme.h"
#include "icons.h"

using namespace Qt::StringLiterals;

namespace {

constexpr auto kMainWindowGeometryKey = "window/mainGeometry/v2";

void publishWindowChromeLeadingInset(QQmlApplicationEngine &engine, QWindow *window)
{
    engine.rootContext()->setContextProperty(
        QStringLiteral("windowChromeLeadingInset"),
        NNAWindowChrome::trafficLightsLeadingMargin(window));
}

void centerWindowOnScreen(QWindow *window)
{
    if (!window) {
        return;
    }

    QScreen *screen = window->screen();
    if (!screen) {
        screen = QGuiApplication::primaryScreen();
    }
    if (!screen) {
        return;
    }

    const QRect available = screen->availableGeometry();
    const QSize size = window->size();
    const QPoint position(
        available.x() + (available.width() - size.width()) / 2,
        available.y() + (available.height() - size.height()) / 2);
    window->setPosition(position);
}

void fitInitialWindowToScreen(QWindow *window)
{
    if (!window) {
        return;
    }

    QScreen *screen = window->screen();
    if (!screen) {
        screen = QGuiApplication::primaryScreen();
    }
    if (!screen) {
        return;
    }

    const QRect available = screen->availableGeometry();
    QSize size = window->size();
    const int maxWidth = qMax(680, int(available.width() * 0.92));
    const int maxHeight = qMax(820, int(available.height() * 0.92));

    if (size.width() > maxWidth) {
        size.setWidth(maxWidth);
    }
    if (size.height() > maxHeight) {
        size.setHeight(maxHeight);
    }

    window->resize(size);
    centerWindowOnScreen(window);
}

bool isFullscreenWindow(const QWindow *window)
{
    return window && window->visibility() == QWindow::FullScreen;
}

bool geometryIntersectsAnyScreen(const QRect& geometry)
{
    if (!geometry.isValid()) {
        return false;
    }

    const auto screens = QGuiApplication::screens();
    for (QScreen *screen : screens) {
        if (screen && screen->availableGeometry().intersects(geometry)) {
            return true;
        }
    }
    return false;
}

bool restoreMainWindowGeometry(QWindow *window)
{
    if (!window) {
        return false;
    }

    const QRect geometry = QSettings().value(QLatin1String(kMainWindowGeometryKey)).toRect();
    if (!geometryIntersectsAnyScreen(geometry)) {
        return false;
    }

    window->setGeometry(geometry);
    return true;
}

void saveMainWindowGeometry(QWindow *window)
{
    if (!window || isFullscreenWindow(window)) {
        return;
    }

    const QRect geometry = window->geometry();
    if (!geometry.isValid() || geometry.width() < 680 || geometry.height() < 820) {
        return;
    }

    QSettings settings;
    settings.setValue(QLatin1String(kMainWindowGeometryKey), geometry);
    settings.sync();
}

void installMainWindowGeometryPersistence(QGuiApplication& app, QWindow *window)
{
    if (!window) {
        return;
    }

    auto *saveTimer = new QTimer(window);
    saveTimer->setSingleShot(true);
    saveTimer->setInterval(350);

    QObject::connect(saveTimer, &QTimer::timeout, window, [window]() {
        saveMainWindowGeometry(window);
    });

    const auto scheduleSave = [window, saveTimer]() {
        if (!isFullscreenWindow(window)) {
            saveTimer->start();
        }
    };

    QObject::connect(window, &QWindow::xChanged, window, scheduleSave);
    QObject::connect(window, &QWindow::yChanged, window, scheduleSave);
    QObject::connect(window, &QWindow::widthChanged, window, scheduleSave);
    QObject::connect(window, &QWindow::heightChanged, window, scheduleSave);
    QObject::connect(window, &QWindow::visibilityChanged, window, scheduleSave);
    QObject::connect(&app, &QGuiApplication::aboutToQuit, window, [window]() {
        saveMainWindowGeometry(window);
    });
}
}

int main(int argc, char *argv[])
{
#ifdef _WIN32
    // Always show a console window for debug output on Windows
    AllocConsole();
    freopen("CONOUT$", "w", stdout);
    freopen("CONOUT$", "w", stderr);
#endif
    // Force OpenGL rendering backend (required for QQuickFramebufferObject / Live2D)
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    QSurfaceFormat format;
#ifdef Q_OS_MACOS
    // macOS: request 2.1 legacy profile (Apple's GL compat layer)
    format.setMajorVersion(2);
    format.setMinorVersion(1);
    format.setProfile(QSurfaceFormat::NoProfile);
#else
    // Windows/Linux: request 3.3 compatibility profile
    // (drivers support this well, and #version 120 shaders still work)
    format.setMajorVersion(3);
    format.setMinorVersion(3);
    format.setProfile(QSurfaceFormat::CompatibilityProfile);
#endif
    format.setDepthBufferSize(24);
    format.setStencilBufferSize(8);
    QSurfaceFormat::setDefaultFormat(format);

    QGuiApplication app(argc, argv);
    app.setApplicationName("OpenNeko Engine");
    app.setOrganizationName("NNA");

    QQuickStyle::setStyle("Basic");

    // Register QML types
    qmlRegisterType<NNAAvatarCanvas>("NNA.Core", 1, 0, "NNAAvatarCanvas");
    qmlRegisterType<NNAMacOSDockView>("NNA.Core", 1, 0, "NNAMacOSDockView");

    NNAModelManager modelManager;
    NNAAppController controller;
    controller.setModelManager(&modelManager);
    AgentWorkspaceService agentWorkspace;

    QQmlApplicationEngine engine;

    // Register C++ singletons for global Theme and Icons access
    qmlRegisterSingletonType<Theme>("OpenNeko", 1, 0, "Theme",
        [](QQmlEngine*, QJSEngine*) -> QObject* { return new Theme(); });
    qmlRegisterSingletonType<Icons>("OpenNeko", 1, 0, "Icons",
        [](QQmlEngine*, QJSEngine*) -> QObject* { return new Icons(); });
    qmlRegisterSingletonType<Live2DStageProfile>("OpenNeko", 1, 0, "Live2DStageProfile",
        [](QQmlEngine*, QJSEngine*) -> QObject* { return new Live2DStageProfile(); });

    engine.rootContext()->setContextProperty("appController", &controller);
    engine.rootContext()->setContextProperty("modelManager", &modelManager);
    engine.rootContext()->setContextProperty("agentWorkspace", &agentWorkspace);

    qDebug() << "[main] Loading QML...";
    engine.load(QUrl(u"qrc:/qt/qml/OpenNeko/qml/main.qml"_s));
    qDebug() << "[main] QML loaded, rootObjects:" << engine.rootObjects().size();

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "[main] QML load failed!";
        return -1;
    }

    if (auto *window = qobject_cast<QWindow *>(engine.rootObjects().constFirst())) {
        NNAWindowChrome::applyMainWindowChrome(window);
        const bool restoredGeometry = restoreMainWindowGeometry(window);
        if (!restoredGeometry) {
            fitInitialWindowToScreen(window);
        }
        installMainWindowGeometryPersistence(app, window);
        window->show();
        publishWindowChromeLeadingInset(engine, window);
        QTimer::singleShot(0, &app, [&engine, window]() {
            publishWindowChromeLeadingInset(engine, window);
        });
        QTimer::singleShot(200, &app, [&engine, window]() {
            publishWindowChromeLeadingInset(engine, window);
        });
        if (!restoredGeometry) {
            QTimer::singleShot(0, window, [window]() {
                fitInitialWindowToScreen(window);
            });
        }
    }

    qDebug() << "[main] Entering event loop...";
    return app.exec();
}
