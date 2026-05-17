#pragma once

#include <QObject>

class Icons : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString home READ home CONSTANT)
    Q_PROPERTY(QString chat READ chat CONSTANT)
    Q_PROPERTY(QString character READ character CONSTANT)
    Q_PROPERTY(QString memory READ memory CONSTANT)
    Q_PROPERTY(QString status READ status CONSTANT)
    Q_PROPERTY(QString ability READ ability CONSTANT)
    Q_PROPERTY(QString world READ world CONSTANT)
    Q_PROPERTY(QString iot READ iot CONSTANT)
    Q_PROPERTY(QString settings READ settings CONSTANT)
    Q_PROPERTY(QString send READ send CONSTANT)
    Q_PROPERTY(QString mic READ mic CONSTANT)
    Q_PROPERTY(QString volume READ volume CONSTANT)
    Q_PROPERTY(QString moon READ moon CONSTANT)
    Q_PROPERTY(QString sun READ sun CONSTANT)
    Q_PROPERTY(QString search READ search CONSTANT)
    Q_PROPERTY(QString close READ close CONSTANT)
    Q_PROPERTY(QString check READ check CONSTANT)
    Q_PROPERTY(QString chevronRight READ chevronRight CONSTANT)
    Q_PROPERTY(QString chevronLeft READ chevronLeft CONSTANT)
    Q_PROPERTY(QString chevronDown READ chevronDown CONSTANT)
    Q_PROPERTY(QString more READ more CONSTANT)
    Q_PROPERTY(QString plus READ plus CONSTANT)
    Q_PROPERTY(QString filter READ filter CONSTANT)
    Q_PROPERTY(QString heart READ heart CONSTANT)
    Q_PROPERTY(QString sparkle READ sparkle CONSTANT)
    Q_PROPERTY(QString zap READ zap CONSTANT)
    Q_PROPERTY(QString paw READ paw CONSTANT)
    Q_PROPERTY(QString satiety READ satiety CONSTANT)
    Q_PROPERTY(QString hydration READ hydration CONSTANT)
    Q_PROPERTY(QString energy READ energy CONSTANT)
    Q_PROPERTY(QString pleasure READ pleasure CONSTANT)
    Q_PROPERTY(QString dominance READ dominance CONSTANT)
    Q_PROPERTY(QString gamepad READ gamepad CONSTANT)
    Q_PROPERTY(QString music READ music CONSTANT)
    Q_PROPERTY(QString sleep READ sleep CONSTANT)
    Q_PROPERTY(QString bell READ bell CONSTANT)

public:
    explicit Icons(QObject* parent = nullptr);

    QString home() const;
    QString chat() const;
    QString character() const;
    QString memory() const;
    QString status() const;
    QString ability() const;
    QString world() const;
    QString iot() const;
    QString settings() const;
    QString send() const;
    QString mic() const;
    QString volume() const;
    QString moon() const;
    QString sun() const;
    QString search() const;
    QString close() const;
    QString check() const;
    QString chevronRight() const;
    QString chevronLeft() const;
    QString chevronDown() const;
    QString more() const;
    QString plus() const;
    QString filter() const;
    QString heart() const;
    QString sparkle() const;
    QString zap() const;
    QString paw() const;
    QString satiety() const;
    QString hydration() const;
    QString energy() const;
    QString pleasure() const;
    QString dominance() const;
    QString gamepad() const;
    QString music() const;
    QString sleep() const;
    QString bell() const;
};
