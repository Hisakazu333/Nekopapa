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
    Q_PROPERTY(QString user READ user CONSTANT)
    Q_PROPERTY(QString users READ users CONSTANT)
    Q_PROPERTY(QString cat READ cat CONSTANT)
    Q_PROPERTY(QString monitor READ monitor CONSTANT)
    Q_PROPERTY(QString cloud READ cloud CONSTANT)
    Q_PROPERTY(QString lock READ lock CONSTANT)
    Q_PROPERTY(QString database READ database CONSTANT)
    Q_PROPERTY(QString infoCircle READ infoCircle CONSTANT)
    Q_PROPERTY(QString phone READ phone CONSTANT)
    Q_PROPERTY(QString box READ box CONSTANT)
    Q_PROPERTY(QString wallet READ wallet CONSTANT)
    Q_PROPERTY(QString shieldCheck READ shieldCheck CONSTANT)
    Q_PROPERTY(QString keyRound READ keyRound CONSTANT)
    Q_PROPERTY(QString scale READ scale CONSTANT)
    Q_PROPERTY(QString pin READ pin CONSTANT)
    Q_PROPERTY(QString cursor READ cursor CONSTANT)
    Q_PROPERTY(QString clock READ clock CONSTANT)
    Q_PROPERTY(QString refresh READ refresh CONSTANT)
    Q_PROPERTY(QString play READ play CONSTANT)

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
    QString user() const;
    QString users() const;
    QString cat() const;
    QString monitor() const;
    QString cloud() const;
    QString lock() const;
    QString database() const;
    QString infoCircle() const;
    QString phone() const;
    QString box() const;
    QString wallet() const;
    QString shieldCheck() const;
    QString keyRound() const;
    QString scale() const;
    QString pin() const;
    QString cursor() const;
    QString clock() const;
    QString refresh() const;
    QString play() const;
};
