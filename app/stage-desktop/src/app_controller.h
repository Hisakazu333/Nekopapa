#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QTimer>
#include <QString>
#include <memory>
#include "nna/core/engine.h"

class NNAModelManager;

class NNAAppController : public QObject {
    Q_OBJECT

    // PAD
    Q_PROPERTY(float pleasure READ pleasure NOTIFY stateChanged)
    Q_PROPERTY(float arousal READ arousal NOTIFY stateChanged)
    Q_PROPERTY(float dominance READ dominance NOTIFY stateChanged)

    // Physiology
    Q_PROPERTY(float satiety READ satiety NOTIFY stateChanged)
    Q_PROPERTY(float hydration READ hydration NOTIFY stateChanged)
    Q_PROPERTY(float energy READ energy NOTIFY stateChanged)

    // Character
    Q_PROPERTY(QString characterName READ characterName NOTIFY stateChanged)
    Q_PROPERTY(QString accentColor READ accentColor NOTIFY stateChanged)
    Q_PROPERTY(QString currentMood READ currentMood NOTIFY stateChanged)

    // Summary
    Q_PROPERTY(int interactionCount READ interactionCount NOTIFY stateChanged)
    Q_PROPERTY(float affinityDelta READ affinityDelta NOTIFY stateChanged)
    Q_PROPERTY(int memoryCount READ memoryCount NOTIFY stateChanged)

    // Live2D model
    Q_PROPERTY(QString currentModelPath READ currentModelPath NOTIFY currentModelPathChanged)
    Q_PROPERTY(QString syncBackendBaseUrl READ syncBackendBaseUrl NOTIFY syncSettingsChanged)
    Q_PROPERTY(QString syncAuthToken READ syncAuthToken NOTIFY syncSettingsChanged)
    Q_PROPERTY(bool syncBusy READ syncBusy NOTIFY syncStateChanged)
    Q_PROPERTY(QString syncStatusText READ syncStatusText NOTIFY syncStateChanged)
    Q_PROPERTY(QString syncLastError READ syncLastError NOTIFY syncStateChanged)
    Q_PROPERTY(bool desktopCompanionEnabled READ desktopCompanionEnabled WRITE setDesktopCompanionEnabled NOTIFY desktopCompanionEnabledChanged)

public:
    explicit NNAAppController(QObject* parent = nullptr);
    ~NNAAppController() override;

    void setModelManager(NNAModelManager* manager);

    float pleasure() const;
    float arousal() const;
    float dominance() const;
    float satiety() const;
    float hydration() const;
    float energy() const;
    QString characterName() const;
    QString accentColor() const;
    QString currentMood() const;
    int interactionCount() const;
    float affinityDelta() const;
    int memoryCount() const;
    QString currentModelPath() const;
    QString syncBackendBaseUrl() const;
    QString syncAuthToken() const;
    bool syncBusy() const;
    QString syncStatusText() const;
    QString syncLastError() const;
    bool desktopCompanionEnabled() const;
    void setDesktopCompanionEnabled(bool enabled);

    Q_INVOKABLE void feedPet(const QString& foodType);
    Q_INVOKABLE void giveWater();
    Q_INVOKABLE void touchPet(float x, float y, float duration);
    Q_INVOKABLE void sendMessage(const QString& text);
    Q_INVOKABLE void saveSyncSettings(const QString& baseUrl, const QString& token);
    Q_INVOKABLE void pushCurrentCompanionToMobile();

    // Mock data sources for UI development (will be replaced by real engine APIs)
    Q_INVOKABLE QVariantList recentMemories(int limit);
    Q_INVOKABLE QVariantList dreamLogs(int limit);
    Q_INVOKABLE QVariantList perceptionEvents(int limit);
    Q_INVOKABLE QVariantList iotDevices();
    Q_INVOKABLE QVariantList availableTools();
    Q_INVOKABLE QStringList memoryTags();

signals:
    void stateChanged();
    void currentModelPathChanged();
    void syncSettingsChanged();
    void syncStateChanged();
    void desktopCompanionEnabledChanged();

private:
    void loadSyncSettings();
    QString normalizeBaseUrl(const QString& value) const;
    QString normalizeAuthorizationValue(const QString& value) const;

    nna::core::NNAEngine m_engine;
    QTimer m_tickTimer;
    NNAModelManager* m_modelManager = nullptr;
    QNetworkAccessManager m_networkManager;
    QString m_syncBackendBaseUrl;
    QString m_syncAuthToken;
    QString m_syncDeviceId;
    bool m_syncBusy = false;
    QString m_syncStatusText;
    QString m_syncLastError;
    bool m_desktopCompanionEnabled = false;
};
