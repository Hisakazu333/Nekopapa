#pragma once

#include <QObject>
#include <QVariantMap>

class Live2DStageProfile : public QObject {
    Q_OBJECT

public:
    explicit Live2DStageProfile(QObject* parent = nullptr);

    Q_INVOKABLE QVariantMap resolveHomeResidentProfile(qreal width, qreal height,
        qreal bottomReservedHeight = 0) const;
    Q_INVOKABLE QVariantMap resolveCabinProfile(qreal width, qreal height,
        qreal bottomReservedHeight = 0) const;

private:
    enum class AspectBucket {
        PortraitTall,
        PortraitNormal,
        PortraitWide,
        Landscape
    };

    static QVariantMap resolveProfile(const QString& scene, qreal width, qreal height,
        qreal bottomReservedHeight);
    static AspectBucket resolveBucket(int width, int height, qreal* ratioOut = nullptr);
    static QString bucketName(AspectBucket bucket);
    static qreal clamp(qreal value, qreal minValue, qreal maxValue);
    static qreal clamp01(qreal value);
    static qreal lerp(qreal from, qreal to, qreal t);
    static qreal round3(qreal value);
    static qreal round4(qreal value);
    static int roundDimension(qreal value);
};
