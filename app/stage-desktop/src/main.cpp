#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "app_controller.h"

using namespace Qt::StringLiterals;

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("OpenNeko Engine");
    app.setOrganizationName("NNA");

    QQuickStyle::setStyle("Basic");

    NNAAppController controller;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("appController", &controller);

    engine.load(QUrl(u"qrc:/qt/qml/OpenNeko/qml/main.qml"_s));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
