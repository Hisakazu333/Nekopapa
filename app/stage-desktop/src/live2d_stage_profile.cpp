#include "live2d_stage_profile.h"

#include <QtMath>

Live2DStageProfile::Live2DStageProfile(QObject* parent)
    : QObject(parent) {}

QVariantMap Live2DStageProfile::resolveHomeResidentProfile(qreal width, qreal height,
    qreal bottomReservedHeight) const {
    return resolveProfile(QStringLiteral("home_resident"), width, height, bottomReservedHeight);
}

QVariantMap Live2DStageProfile::resolveCabinProfile(qreal width, qreal height,
    qreal bottomReservedHeight) const {
    return resolveProfile(QStringLiteral("companion_cabin"), width, height, bottomReservedHeight);
}

QVariantMap Live2DStageProfile::resolveProfile(const QString& scene, qreal width, qreal height,
    qreal bottomReservedHeight) {
    const int safeWidth = qMax(1, roundDimension(width));
    const int safeHeight = qMax(1, roundDimension(height));
    const int reserved = qBound(0, roundDimension(bottomReservedHeight),
        static_cast<int>(qRound(safeHeight * 0.45)));
    const int stageHeight = qMax(1, safeHeight - reserved);

    qreal bucketRatio = 0.0;
    const AspectBucket bucket = resolveBucket(safeWidth, stageHeight, &bucketRatio);
    const qreal stageRatio = bucketRatio > 0.0 ? bucketRatio : static_cast<qreal>(safeWidth) / stageHeight;
    const qreal screenRatio = round4(static_cast<qreal>(safeWidth) / safeHeight);
    const qreal reservedRatio = static_cast<qreal>(reserved) / safeHeight;
    const qreal bottomLoad = clamp01(reservedRatio / 0.34);
    const qreal compactStage = clamp01((stageRatio - 0.49) / 0.27);
    const qreal tallStage = clamp01((0.49 - stageRatio) / 0.18);
    const qreal baseScale = screenRatio > 1.0 ? 0.95 : 2.05;

    QVariantMap profile;
    profile.insert(QStringLiteral("scene"), scene);
    profile.insert(QStringLiteral("bucket"), bucketName(bucket));
    profile.insert(QStringLiteral("width"), safeWidth);
    profile.insert(QStringLiteral("height"), safeHeight);
    profile.insert(QStringLiteral("reservedHeight"), reserved);
    profile.insert(QStringLiteral("stageHeight"), stageHeight);
    profile.insert(QStringLiteral("screenRatio"), screenRatio);
    profile.insert(QStringLiteral("stageRatio"), round4(stageRatio));
    profile.insert(QStringLiteral("bottomLoad"), round3(bottomLoad));
    profile.insert(QStringLiteral("offsetX"), 0.0);
    profile.insert(QStringLiteral("baseScale"), baseScale);

    if (bucket != AspectBucket::Landscape) {
        const qreal offsetY = round3(
            -0.58 - compactStage * 0.18 - bottomLoad * 0.12 - tallStage * 0.12
        );
        const qreal viewScale = round3(clamp(
            0.99 - compactStage * 0.08 - bottomLoad * 0.02 + tallStage * 0.06,
            0.94,
            1.08
        ));
        const qreal safeTop = round3(lerp(0.10, 0.06, compactStage));
        const qreal safeBottom = round3(lerp(0.84, 0.78, compactStage));
        profile.insert(QStringLiteral("offsetY"), offsetY);
        profile.insert(QStringLiteral("viewScale"), viewScale);
        profile.insert(QStringLiteral("renderScale"), round3(baseScale * viewScale));
        profile.insert(QStringLiteral("safeTopRatio"), safeTop);
        profile.insert(QStringLiteral("safeBottomRatio"), safeBottom);
        profile.insert(QStringLiteral("touchTopRatio"), qMax(0.06, safeTop - 0.02));
        profile.insert(QStringLiteral("touchBottomRatio"), qMin(0.88, safeBottom + 0.04));
        return profile;
    }

    const qreal span = clamp01((stageRatio - 1.0) / 0.7);
    const qreal offsetY = round3(lerp(-0.32, -0.46, span) - bottomLoad * 0.08);
    const qreal viewScale = round3(lerp(0.72, 0.64, span) - bottomLoad * 0.04);
    profile.insert(QStringLiteral("offsetY"), offsetY);
    profile.insert(QStringLiteral("viewScale"), viewScale);
    profile.insert(QStringLiteral("renderScale"), round3(baseScale * viewScale));
    profile.insert(QStringLiteral("safeTopRatio"), 0.08);
    profile.insert(QStringLiteral("safeBottomRatio"), 0.82);
    profile.insert(QStringLiteral("touchTopRatio"), 0.06);
    profile.insert(QStringLiteral("touchBottomRatio"), 0.84);
    return profile;
}

Live2DStageProfile::AspectBucket Live2DStageProfile::resolveBucket(int width, int height,
    qreal* ratioOut) {
    const int safeWidth = qMax(1, width);
    const int safeHeight = qMax(1, height);
    const qreal ratio = static_cast<qreal>(safeWidth) / safeHeight;

    if (ratioOut) {
        *ratioOut = round4(ratio);
    }

    if (ratio >= 1.0) {
        return AspectBucket::Landscape;
    }
    if (ratio >= 0.58) {
        return AspectBucket::PortraitWide;
    }
    if (ratio >= 0.49) {
        return AspectBucket::PortraitNormal;
    }
    return AspectBucket::PortraitTall;
}

QString Live2DStageProfile::bucketName(AspectBucket bucket) {
    switch (bucket) {
    case AspectBucket::PortraitTall:
        return QStringLiteral("portraitTall");
    case AspectBucket::PortraitNormal:
        return QStringLiteral("portraitNormal");
    case AspectBucket::PortraitWide:
        return QStringLiteral("portraitWide");
    case AspectBucket::Landscape:
    default:
        return QStringLiteral("landscape");
    }
}

qreal Live2DStageProfile::clamp(qreal value, qreal minValue, qreal maxValue) {
    if (!qIsFinite(value)) {
        return minValue;
    }
    return qMax(minValue, qMin(maxValue, value));
}

qreal Live2DStageProfile::clamp01(qreal value) {
    return clamp(value, 0.0, 1.0);
}

qreal Live2DStageProfile::lerp(qreal from, qreal to, qreal t) {
    const qreal bounded = clamp01(t);
    return round3(from + (to - from) * bounded);
}

qreal Live2DStageProfile::round3(qreal value) {
    if (!qIsFinite(value)) {
        return 0.0;
    }
    return qRound64(value * 1000.0) / 1000.0;
}

qreal Live2DStageProfile::round4(qreal value) {
    if (!qIsFinite(value)) {
        return 0.0;
    }
    return qRound64(value * 10000.0) / 10000.0;
}

int Live2DStageProfile::roundDimension(qreal value) {
    if (!qIsFinite(value)) {
        return 0;
    }
    return qMax(0, static_cast<int>(qRound(value)));
}
