#pragma once

#include <QObject>
#include <QColor>
#include <QHash>

class Theme : public QObject {
    Q_OBJECT
    Q_PROPERTY(int mode READ mode WRITE setMode NOTIFY modeChanged)
    Q_PROPERTY(bool isDark READ isDark NOTIFY modeChanged)
    Q_PROPERTY(QString fontUi READ fontUi CONSTANT)
    Q_PROPERTY(QString fontMono READ fontMono CONSTANT)
    Q_PROPERTY(int radiusSm READ radiusSm CONSTANT)
    Q_PROPERTY(int radiusMd READ radiusMd CONSTANT)
    Q_PROPERTY(int radiusLg READ radiusLg CONSTANT)
    Q_PROPERTY(int radiusXl READ radiusXl CONSTANT)
    Q_PROPERTY(int appleRadiusGroup READ appleRadiusGroup CONSTANT)
    Q_PROPERTY(int appleRadiusButton READ appleRadiusButton CONSTANT)
    Q_PROPERTY(int appleSidebarWidth READ appleSidebarWidth CONSTANT)
    Q_PROPERTY(int appleContentMaxWidth READ appleContentMaxWidth CONSTANT)

public:
    explicit Theme(QObject* parent = nullptr);

    int mode() const;
    void setMode(int mode);
    bool isDark() const;

    Q_INVOKABLE QColor color(const QString& role) const;
    Q_INVOKABLE QColor alpha(const QString& role, qreal a) const;
    Q_INVOKABLE QColor glass(qreal opacity) const;
    Q_INVOKABLE QColor shadow(const QString& role, int elevation) const;
    Q_INVOKABLE QColor gradient(const QString& role1, const QString& role2, qreal ratio) const;

    QString fontUi() const { return QStringLiteral("PingFang SC"); }
    QString fontMono() const { return QStringLiteral("Menlo"); }

    int radiusSm() const { return 10; }
    int radiusMd() const { return 16; }
    int radiusLg() const { return 24; }
    int radiusXl() const { return 32; }
    int appleRadiusGroup() const { return 10; }
    int appleRadiusButton() const { return 8; }
    int appleSidebarWidth() const { return 260; }
    int appleContentMaxWidth() const { return 720; }

signals:
    void modeChanged();

private:
    QHash<QString, QColor> palette(int mode) const;
    int m_mode = 0;
};
