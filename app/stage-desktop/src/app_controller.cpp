#include "app_controller.h"
#include "nna_model_manager.h"

#include <QCryptographicHash>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QSettings>
#include <QStringList>
#include <QUuid>

namespace {

QString firstNonEmpty(const QStringList& values) {
    for (const QString& value : values) {
        const QString trimmed = value.trimmed();
        if (!trimmed.isEmpty()) {
            return trimmed;
        }
    }
    return {};
}

QString jsonString(const QJsonObject& object, const QStringList& keys) {
    for (const QString& key : keys) {
        const QJsonValue value = object.value(key);
        if (value.isString()) {
            const QString trimmed = value.toString().trimmed();
            if (!trimmed.isEmpty()) {
                return trimmed;
            }
        }
    }
    return {};
}

void putIfNotEmpty(QJsonObject& object, const QString& key, const QString& value) {
    const QString trimmed = value.trimmed();
    if (!trimmed.isEmpty()) {
        object.insert(key, trimmed);
    }
}

QJsonObject readJsonObjectFile(const QString& path) {
    if (path.isEmpty()) {
        return {};
    }
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly)) {
        return {};
    }
    const QByteArray raw = file.readAll();
    file.close();
    const QJsonDocument document = QJsonDocument::fromJson(raw);
    return document.isObject() ? document.object() : QJsonObject();
}

QString findMetadataFile(const QString& modelPath) {
    if (modelPath.isEmpty()) {
        return {};
    }
    const QFileInfo modelInfo(modelPath);
    const QStringList candidateRoots = {
        modelPath,
        modelInfo.dir().absolutePath()
    };
    const QStringList candidateFiles = {
        QStringLiteral("companion.json"),
        QStringLiteral("neko_companion.json"),
        QStringLiteral("mobile_payload.json"),
        QStringLiteral("desktop_payload.json")
    };
    for (const QString& root : candidateRoots) {
        for (const QString& fileName : candidateFiles) {
            const QString candidatePath = root + QLatin1Char('/') + fileName;
            if (QFileInfo::exists(candidatePath)) {
                return candidatePath;
            }
        }
    }
    return {};
}

QString shortenOptional(const QString& value, int maxLength) {
    const QString trimmed = value.trimmed();
    if (trimmed.isEmpty() || trimmed.size() > maxLength) {
        return {};
    }
    return trimmed;
}

} // namespace

NNAAppController::NNAAppController(QObject* parent)
    : QObject(parent)
{
    m_engine.init();
    loadSyncSettings();
    QSettings settings;
    m_desktopCompanionEnabled = settings.value(QStringLiteral("desktop/companionEnabled"), false).toBool();

    connect(&m_tickTimer, &QTimer::timeout, this, [this]() {
        m_engine.tick(1.0f);
        emit stateChanged();
    });
    m_tickTimer.start(1000);
}

NNAAppController::~NNAAppController() {
    m_engine.shutdown();
}

float NNAAppController::pleasure() const { return m_engine.getState().pad.pleasure; }
float NNAAppController::arousal() const { return m_engine.getState().pad.arousal; }
float NNAAppController::dominance() const { return m_engine.getState().pad.dominance; }
float NNAAppController::satiety() const { return m_engine.getState().physio.satiety; }
float NNAAppController::hydration() const { return m_engine.getState().physio.hydration; }
float NNAAppController::energy() const { return m_engine.getState().physio.energy; }

QString NNAAppController::characterName() const {
    return QString::fromStdString(m_engine.getState().character.name);
}

QString NNAAppController::accentColor() const {
    return QString::fromStdString(m_engine.getState().character.accentColor);
}

QString NNAAppController::currentMood() const {
    return QString::fromStdString(m_engine.getState().currentMood);
}

int NNAAppController::interactionCount() const { return m_engine.getState().interactionCount; }
float NNAAppController::affinityDelta() const { return m_engine.getState().affinityDelta; }
int NNAAppController::memoryCount() const { return m_engine.getState().memoryCount; }

QString NNAAppController::currentModelPath() const {
    return m_modelManager ? m_modelManager->currentModelPath() : QString();
}

QString NNAAppController::syncBackendBaseUrl() const {
    return m_syncBackendBaseUrl;
}

QString NNAAppController::syncAuthToken() const {
    return m_syncAuthToken;
}

bool NNAAppController::syncBusy() const {
    return m_syncBusy;
}

QString NNAAppController::syncStatusText() const {
    return m_syncStatusText;
}

QString NNAAppController::syncLastError() const {
    return m_syncLastError;
}

bool NNAAppController::desktopCompanionEnabled() const {
    return m_desktopCompanionEnabled;
}

void NNAAppController::setDesktopCompanionEnabled(bool enabled) {
    if (m_desktopCompanionEnabled == enabled) {
        return;
    }
    m_desktopCompanionEnabled = enabled;
    QSettings settings;
    settings.setValue(QStringLiteral("desktop/companionEnabled"), m_desktopCompanionEnabled);
    settings.sync();
    emit desktopCompanionEnabledChanged();
}

void NNAAppController::feedPet(const QString& foodType) {
    m_engine.feedPet(foodType.toStdString());
    emit stateChanged();
}

void NNAAppController::giveWater() {
    m_engine.giveWater();
    emit stateChanged();
}

void NNAAppController::touchPet(float x, float y, float duration) {
    m_engine.touchPet(x, y, duration);
    emit stateChanged();
}

void NNAAppController::sendMessage(const QString& text) {
    m_engine.sendMessage(text.toStdString());
    emit stateChanged();
}

void NNAAppController::setModelManager(NNAModelManager* manager) {
    m_modelManager = manager;
    if (m_modelManager) {
        connect(m_modelManager, &NNAModelManager::currentModelChanged,
                this, &NNAAppController::currentModelPathChanged);
    }
}

void NNAAppController::saveSyncSettings(const QString& baseUrl, const QString& token) {
    m_syncBackendBaseUrl = normalizeBaseUrl(baseUrl);
    m_syncAuthToken = token.trimmed();

    QSettings settings;
    settings.setValue(QStringLiteral("mobileSync/baseUrl"), m_syncBackendBaseUrl);
    settings.setValue(QStringLiteral("mobileSync/authToken"), m_syncAuthToken);
    settings.sync();

    emit syncSettingsChanged();
}

void NNAAppController::pushCurrentCompanionToMobile() {
    if (m_syncBusy) {
        return;
    }
    if (!m_modelManager) {
        m_syncLastError = QStringLiteral("Model manager is not ready");
        m_syncStatusText.clear();
        emit syncStateChanged();
        return;
    }

    const QString baseUrl = normalizeBaseUrl(m_syncBackendBaseUrl);
    const QString authHeader = normalizeAuthorizationValue(m_syncAuthToken);
    const QString modelPath = m_modelManager->currentModelPath().trimmed();
    const QString modelId = m_modelManager->currentModelId().trimmed();
    const QString modelName = m_modelManager->currentModelName().trimmed();
    const QString thumbnailUrl = m_modelManager->currentModelThumbnailUrl().trimmed();
    const QString metadataPath = findMetadataFile(modelPath);
    const QJsonObject metadata = readJsonObjectFile(metadataPath);

    if (baseUrl.isEmpty()) {
        m_syncLastError = QStringLiteral("Please set the mobile backend URL first");
        m_syncStatusText.clear();
        emit syncStateChanged();
        return;
    }
    if (authHeader.isEmpty()) {
        m_syncLastError = QStringLiteral("Please set the mobile Bearer token first");
        m_syncStatusText.clear();
        emit syncStateChanged();
        return;
    }
    if (modelPath.isEmpty()) {
        m_syncLastError = QStringLiteral("No current model is selected");
        m_syncStatusText.clear();
        emit syncStateChanged();
        return;
    }

    const QString displayName = firstNonEmpty({
        jsonString(metadata, {QStringLiteral("displayName"), QStringLiteral("name")}),
        modelName,
        characterName()
    });
    const QString promptText = jsonString(metadata, {
        QStringLiteral("promptText"),
        QStringLiteral("prompt"),
        QStringLiteral("persona"),
        QStringLiteral("systemPrompt")
    });
    const QString openingLine = jsonString(metadata, {
        QStringLiteral("openingLine"),
        QStringLiteral("openingMessage"),
        QStringLiteral("initialMessage"),
        QStringLiteral("firstMessage"),
        QStringLiteral("welcomeMessage"),
        QStringLiteral("welcome")
    });
    const QString loraModelId = jsonString(metadata, {
        QStringLiteral("loraModelId"),
        QStringLiteral("loraId"),
        QStringLiteral("loraAdapterId"),
        QStringLiteral("adapterId")
    });
    const QString portraitUrl = firstNonEmpty({
        jsonString(metadata, {
            QStringLiteral("portraitUrl"),
            QStringLiteral("avatarUrl"),
            QStringLiteral("coverUrl")
        }),
        shortenOptional(thumbnailUrl, 512)
    });

    QJsonObject mobilePayload;
    putIfNotEmpty(mobilePayload, QStringLiteral("displayName"), displayName);
    putIfNotEmpty(mobilePayload, QStringLiteral("name"), displayName);
    putIfNotEmpty(mobilePayload, QStringLiteral("portraitUrl"), portraitUrl);
    putIfNotEmpty(mobilePayload, QStringLiteral("coverUrl"), portraitUrl);
    putIfNotEmpty(mobilePayload, QStringLiteral("promptText"), promptText);
    putIfNotEmpty(mobilePayload, QStringLiteral("openingLine"), openingLine);
    putIfNotEmpty(mobilePayload, QStringLiteral("loraModelId"), loraModelId);

    QJsonObject desktopPayload;
    putIfNotEmpty(desktopPayload, QStringLiteral("displayName"), displayName);
    putIfNotEmpty(desktopPayload, QStringLiteral("name"), displayName);
    putIfNotEmpty(desktopPayload, QStringLiteral("characterName"), characterName());
    putIfNotEmpty(desktopPayload, QStringLiteral("modelId"), modelId);
    putIfNotEmpty(desktopPayload, QStringLiteral("modelPath"), modelPath);
    putIfNotEmpty(desktopPayload, QStringLiteral("thumbnailUrl"), thumbnailUrl);
    putIfNotEmpty(desktopPayload, QStringLiteral("metadataPath"), metadataPath);
    putIfNotEmpty(desktopPayload, QStringLiteral("promptText"), promptText);
    putIfNotEmpty(desktopPayload, QStringLiteral("openingLine"), openingLine);
    putIfNotEmpty(desktopPayload, QStringLiteral("loraModelId"), loraModelId);

    QByteArray assetBasis = modelId.toUtf8();
    assetBasis.append('|');
    assetBasis.append(modelPath.toUtf8());
    const QString assetCode = QStringLiteral("desktop_")
        + QString::fromLatin1(QCryptographicHash::hash(assetBasis, QCryptographicHash::Sha256).toHex().left(24));
    QByteArray payloadBasis = QJsonDocument(mobilePayload).toJson(QJsonDocument::Compact);
    payloadBasis.append('\n');
    payloadBasis.append(QJsonDocument(desktopPayload).toJson(QJsonDocument::Compact));
    const QString payloadHash = QString::fromLatin1(
        QCryptographicHash::hash(payloadBasis, QCryptographicHash::Sha256).toHex());

    QJsonObject requestBody;
    requestBody.insert(QStringLiteral("deviceId"), m_syncDeviceId);
    requestBody.insert(QStringLiteral("assetCode"), assetCode);
    requestBody.insert(QStringLiteral("assetName"), displayName.isEmpty() ? QFileInfo(modelPath).baseName() : displayName);
    requestBody.insert(QStringLiteral("payloadHash"), payloadHash);
    requestBody.insert(QStringLiteral("desktopAssetRef"),
                       firstNonEmpty({shortenOptional(modelId, 512), shortenOptional(QFileInfo(modelPath).baseName(), 512)}));
    const QString coverUrl = shortenOptional(portraitUrl, 512);
    if (!coverUrl.isEmpty()) {
        requestBody.insert(QStringLiteral("coverUrl"), coverUrl);
    }
    if (!mobilePayload.isEmpty()) {
        requestBody.insert(QStringLiteral("mobilePayload"), mobilePayload);
    }
    if (!desktopPayload.isEmpty()) {
        requestBody.insert(QStringLiteral("desktopPayload"), desktopPayload);
    }
    requestBody.insert(QStringLiteral("versionNo"), 1);

    QNetworkRequest request(QUrl(baseUrl + QStringLiteral("/api/desktop/companion/sync/push")));
    request.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
    request.setRawHeader("Authorization", authHeader.toUtf8());

    m_syncBusy = true;
    m_syncLastError.clear();
    m_syncStatusText = QStringLiteral("Syncing current desktop companion to mobile...");
    emit syncStateChanged();

    QNetworkReply* reply = m_networkManager.post(request, QJsonDocument(requestBody).toJson(QJsonDocument::Compact));
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        const int httpStatus = reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        const QByteArray raw = reply->readAll();
        const QJsonDocument document = QJsonDocument::fromJson(raw);
        QString message = reply->error() == QNetworkReply::NoError
            ? QStringLiteral("Desktop companion sync completed")
            : reply->errorString();
        bool success = reply->error() == QNetworkReply::NoError;

        if (document.isObject()) {
            const QJsonObject object = document.object();
            if (object.value(QStringLiteral("msg")).isString()) {
                message = object.value(QStringLiteral("msg")).toString().trimmed();
            }
            const int code = object.value(QStringLiteral("code")).toInt(httpStatus);
            if (code != 200) {
                success = false;
                if (message.isEmpty() && object.value(QStringLiteral("message")).isString()) {
                    message = object.value(QStringLiteral("message")).toString().trimmed();
                }
            }
        }

        m_syncBusy = false;
        if (success) {
            m_syncLastError.clear();
            m_syncStatusText = message.isEmpty()
                ? QStringLiteral("Desktop companion has been synced to the mobile cloud queue")
                : message;
        } else {
            m_syncStatusText.clear();
            m_syncLastError = message.isEmpty()
                ? QStringLiteral("Desktop companion sync failed")
                : message;
        }
        emit syncStateChanged();
        reply->deleteLater();
    });
}

void NNAAppController::loadSyncSettings() {
    QSettings settings;
    m_syncBackendBaseUrl = normalizeBaseUrl(settings.value(QStringLiteral("mobileSync/baseUrl")).toString());
    m_syncAuthToken = settings.value(QStringLiteral("mobileSync/authToken")).toString().trimmed();
    m_syncDeviceId = settings.value(QStringLiteral("mobileSync/deviceId")).toString().trimmed();
    if (m_syncDeviceId.isEmpty()) {
        m_syncDeviceId = QStringLiteral("desktop_%1")
            .arg(QUuid::createUuid().toString(QUuid::WithoutBraces));
        settings.setValue(QStringLiteral("mobileSync/deviceId"), m_syncDeviceId);
        settings.sync();
    }
}

QString NNAAppController::normalizeBaseUrl(const QString& value) const {
    QString normalized = value.trimmed();
    while (normalized.endsWith(QLatin1Char('/'))) {
        normalized.chop(1);
    }
    return normalized;
}

QVariantList NNAAppController::recentMemories(int limit) {
    QVariantList list;
    list.append(QVariantMap({{"summary", QString::fromUtf8("\u4E00\u8D77\u770B\u4E86\u65E5\u843D")}, {"date", "2026-05-10"}, {"intensity", 0.8}}));
    list.append(QVariantMap({{"summary", QString::fromUtf8("\u4ECA\u5929\u7684\u65E9\u9910\u5F88\u597D\u5403")}, {"date", "2026-05-12"}, {"intensity", 0.5}}));
    list.append(QVariantMap({{"summary", QString::fromUtf8("\u804A\u4E86\u5F88\u4E45\u7684\u5929")}, {"date", "2026-05-13"}, {"intensity", 0.7}}));
    if (limit > 0 && limit < list.size()) list = list.mid(0, limit);
    return list;
}

QVariantList NNAAppController::dreamLogs(int limit) {
    QVariantList list;
    list.append(QVariantMap({{"date", "2026-05-14"}, {"content", QString::fromUtf8("\u68A6\u89C1\u4E86\u4E00\u7247\u6A31\u82B1\u6811\u6797\u2026")}, {"pad", "P:0.72 A:0.31"}}));
    list.append(QVariantMap({{"date", "2026-05-12"}, {"content", QString::fromUtf8("\u68A6\u89C1\u81EA\u5DF1\u5728\u4E91\u6735\u4E0A\u8DF3\u6765\u8DF3\u53BB\u2026")}, {"pad", "P:0.85 A:0.42"}}));
    if (limit > 0 && limit < list.size()) list = list.mid(0, limit);
    return list;
}

QVariantList NNAAppController::perceptionEvents(int limit) {
    QVariantList list;
    list.append(QVariantMap({{"source", QString::fromUtf8("\u89C6\u89C9")}, {"event", QString::fromUtf8("\u68C0\u6D4B\u5230\u7528\u6237\u9762\u90E8")}, {"time", "2s ago"}}));
    list.append(QVariantMap({{"source", QString::fromUtf8("\u58F0\u97F3")}, {"event", QString::fromUtf8("\u73AF\u5883\u566A\u97F3: 35dB")}, {"time", "5s ago"}}));
    if (limit > 0 && limit < list.size()) list = list.mid(0, limit);
    return list;
}

QVariantList NNAAppController::iotDevices() {
    QVariantList list;
    list.append(QVariantMap({{"name", QString::fromUtf8("\u667A\u80FD\u706F\u5E26")}, {"connected", true}, {"value", QString::fromUtf8("\u6A59\u8272")}}));
    list.append(QVariantMap({{"name", QString::fromUtf8("\u98CE\u6247")}, {"connected", true}, {"value", "60%"}}));
    list.append(QVariantMap({{"name", QString::fromUtf8("\u6E29\u5EA6\u8BA1")}, {"connected", false}, {"value", "--"}}));
    return list;
}

QVariantList NNAAppController::availableTools() {
    QVariantList list;
    list.append(QVariantMap({{"name", "Web Search"}, {"desc", QString::fromUtf8("\u5728\u7F51\u4E0A\u641C\u7D22\u4FE1\u606F")}, {"enabled", true}}));
    list.append(QVariantMap({{"name", "File Read"}, {"desc", QString::fromUtf8("\u8BFB\u53D6\u672C\u5730\u6587\u4EF6")}, {"enabled", false}}));
    list.append(QVariantMap({{"name", "System Info"}, {"desc", QString::fromUtf8("\u83B7\u53D6\u7CFB\u7EDF\u4FE1\u606F")}, {"enabled", true}}));
    return list;
}

QStringList NNAAppController::memoryTags() {
    return QStringList()
        << QString::fromUtf8("\u5168\u90E8")
        << QString::fromUtf8("\u9AD8\u5174")
        << QString::fromUtf8("\u96BE\u8FC7")
        << QString::fromUtf8("\u91CD\u8981")
        << QString::fromUtf8("\u65E5\u5E38");
}

QString NNAAppController::normalizeAuthorizationValue(const QString& value) const {
    const QString normalized = value.trimmed();
    if (normalized.isEmpty()) {
        return {};
    }
    if (normalized.startsWith(QStringLiteral("Bearer "), Qt::CaseInsensitive)) {
        return normalized;
    }
    return QStringLiteral("Bearer ") + normalized;
}
