/*
 * Project: OpenNeko Engine (NNA Core)
 * Core Architecture by Nekonano-Aether
 * Copyright (c) 2026 Nekonano-Aether. All rights reserved.
 * SPDX-License-Identifier: MIT
 */

#include "nna/graphics/live2d/live2d_model.h"
#include "nna/graphics/live2d/live2d_pal.h"
#include <CubismModelSettingJson.hpp>
#include <Motion/CubismMotion.hpp>
#include <Physics/CubismPhysics.hpp>
#include <Id/CubismIdManager.hpp>
#include <Rendering/OpenGL/CubismRenderer_OpenGLES2.hpp>
#include <algorithm>
#include <cctype>
#include <cstdio>
#include <cstring>
#include <sstream>

using namespace Csm;

namespace {

std::string escapeJsonString(const char* value) {
    if (!value) {
        return "";
    }

    std::ostringstream out;
    for (const char* cursor = value; *cursor; ++cursor) {
        const char ch = *cursor;
        switch (ch) {
        case '"':
            out << "\\\"";
            break;
        case '\\':
            out << "\\\\";
            break;
        case '\b':
            out << "\\b";
            break;
        case '\f':
            out << "\\f";
            break;
        case '\n':
            out << "\\n";
            break;
        case '\r':
            out << "\\r";
            break;
        case '\t':
            out << "\\t";
            break;
        default:
            out << ch;
            break;
        }
    }
    return out.str();
}

std::string cubismIdToString(CubismIdHandle id) {
    if (!id) {
        return "";
    }
    return id->GetString().GetRawString();
}

std::string inferParameterRole(const std::string& parameterId) {
    std::string normalized = parameterId;
    std::transform(normalized.begin(), normalized.end(), normalized.begin(),
        [](unsigned char c) { return static_cast<char>(std::tolower(c)); });

    if (normalized.find("mouthform") != std::string::npos || normalized.find("mouth_form") != std::string::npos) {
        return "mouthForm";
    }
    if (normalized.find("mouthopen") != std::string::npos || normalized.find("mouth_open") != std::string::npos
        || normalized.find("mouth") != std::string::npos) {
        return "mouth";
    }
    if (normalized.find("eyeballx") != std::string::npos) return "eyeBallX";
    if (normalized.find("eyebally") != std::string::npos) return "eyeBallY";
    if (normalized.find("eyelopen") != std::string::npos || normalized.find("eyeopenl") != std::string::npos
        || normalized.find("eyel_open") != std::string::npos) {
        return "eyeOpenLeft";
    }
    if (normalized.find("eyeropen") != std::string::npos || normalized.find("eyeopenr") != std::string::npos
        || normalized.find("eyer_open") != std::string::npos) {
        return "eyeOpenRight";
    }
    if (normalized.find("bodyanglex") != std::string::npos) return "bodyAngleX";
    if (normalized.find("bodyangley") != std::string::npos) return "bodyAngleY";
    if (normalized.find("bodyanglez") != std::string::npos) return "bodyAngleZ";
    if (normalized.find("anglex") != std::string::npos) return "angleX";
    if (normalized.find("angley") != std::string::npos) return "angleY";
    if (normalized.find("anglez") != std::string::npos) return "angleZ";
    if (normalized.find("breath") != std::string::npos) return "breath";
    if (normalized.find("shoulder") != std::string::npos) return "shoulder";
    if (normalized.find("paramarmla") != std::string::npos || normalized.find("armlefta") != std::string::npos) {
        return "armLeftA";
    }
    if (normalized.find("paramarmra") != std::string::npos || normalized.find("armrighta") != std::string::npos) {
        return "armRightA";
    }
    if (normalized.find("paramarmlb") != std::string::npos || normalized.find("armleftb") != std::string::npos) {
        return "armLeftB";
    }
    if (normalized.find("paramarmrb") != std::string::npos || normalized.find("armrightb") != std::string::npos) {
        return "armRightB";
    }
    if (normalized.find("paramhandlb") != std::string::npos || normalized.find("handleftb") != std::string::npos) {
        return "handLeftB";
    }
    if (normalized.find("paramhandrb") != std::string::npos || normalized.find("handrightb") != std::string::npos) {
        return "handRightB";
    }
    if (normalized.find("paramhandl") != std::string::npos || normalized.find("handleft") != std::string::npos) {
        return "handLeft";
    }
    if (normalized.find("paramhandr") != std::string::npos || normalized.find("handright") != std::string::npos) {
        return "handRight";
    }
    if (normalized.find("hairahoge") != std::string::npos || normalized.find("ahoge") != std::string::npos) {
        return "hairAhoge";
    }
    if (normalized.find("earl") != std::string::npos || normalized.find("earleft") != std::string::npos
        || normalized.find("ear_left") != std::string::npos) {
        return "earLeft";
    }
    if (normalized.find("earr") != std::string::npos || normalized.find("earright") != std::string::npos
        || normalized.find("ear_right") != std::string::npos) {
        return "earRight";
    }
    if (normalized.find("tailx") != std::string::npos || normalized.find("tail_x") != std::string::npos) {
        return "tailX";
    }
    if (normalized.find("taily") != std::string::npos || normalized.find("tail_y") != std::string::npos) {
        return "tailY";
    }
    if (normalized.find("cheek") != std::string::npos || normalized.find("blush") != std::string::npos) {
        return "cheek";
    }
    return "";
}

} // namespace

namespace nna::graphics {

Live2DModel::Live2DModel()
    : m_textureManager(new Live2DTextureManager())
    , m_modelSetting(nullptr)
    , m_userTimeSeconds(0.0f)
    , m_eyeBlink(nullptr)
    , m_breath(nullptr)
    , m_pose(nullptr)
{
    // _modelMatrix is created by CubismUserModel::LoadModel() with proper canvas dimensions
}

Live2DModel::~Live2DModel() {
    DeleteRenderer();

    if (m_modelSetting) { delete m_modelSetting; m_modelSetting = nullptr; }
    if (m_textureManager) { delete m_textureManager; m_textureManager = nullptr; }
    if (m_eyeBlink) { CubismEyeBlink::Delete(m_eyeBlink); m_eyeBlink = nullptr; }
    if (m_breath) { CubismBreath::Delete(m_breath); m_breath = nullptr; }
    if (m_pose) { CubismPose::Delete(m_pose); m_pose = nullptr; }

    for (auto& item : m_motions) {
        if (item.second) {
            CubismMotion::Delete(item.second);
        }
    }
    m_motions.clear();

    for (auto& item : m_expressions) {
        if (item.second) {
            ACubismMotion::Delete(item.second);
        }
    }
    m_expressions.clear();
}

void Live2DModel::loadAssets(const std::string& dir, const std::string& fileName) {
    m_modelHomeDir = dir;

    Live2DPal::printLog("LoadAssets: dir=%s file=%s", dir.c_str(), fileName.c_str());

    // 1. Load .model3.json
    csmSizeInt size;
    const std::string path = dir + fileName;
    csmByte* buffer = Live2DPal::loadFileAsBytes(path, &size);
    if (!buffer) {
        Live2DPal::printLog("ERROR: Failed to load model setting: %s", path.c_str());
        return;
    }

    m_modelSetting = new CubismModelSettingJson(buffer, size);
    Live2DPal::releaseBytes(buffer);

    // 2. Load .moc3
    const std::string modelFileName = m_modelSetting->GetModelFileName();
    if (!modelFileName.empty()) {
        const std::string modelPath = dir + modelFileName;
        buffer = Live2DPal::loadFileAsBytes(modelPath, &size);
        if (buffer) {
            LoadModel(buffer, size);
            Live2DPal::releaseBytes(buffer);
        }
    }

    // 3. Create renderer
    if (_model) {
        CreateRenderer();
        auto* renderer = GetRenderer<Rendering::CubismRenderer_OpenGLES2>();
        if (renderer) {
            renderer->UseHighPrecisionMask(true);
            renderer->SetClippingMaskBufferSize(2048.0f, 2048.0f);
            renderer->IsPremultipliedAlpha(true);
        }
    }

    // 4. Load textures
    int textureCount = m_modelSetting->GetTextureCount();
    for (int i = 0; i < textureCount; i++) {
        std::string texturePath = dir + m_modelSetting->GetTextureFileName(i);
        auto* tex = m_textureManager->createTextureFromPngFile(texturePath);
        if (tex) {
            GetRenderer<Rendering::CubismRenderer_OpenGLES2>()->BindTexture(i, tex->m_id);
        }
    }

    // 5. Pose
    if (std::strcmp(m_modelSetting->GetPoseFileName(), "") != 0) {
        std::string posePath = dir + m_modelSetting->GetPoseFileName();
        buffer = Live2DPal::loadFileAsBytes(posePath, &size);
        if (buffer) {
            m_pose = CubismPose::Create(buffer, size);
            Live2DPal::releaseBytes(buffer);
        }
    }

    // 6. Eye blink
    if (m_modelSetting->GetEyeBlinkParameterCount() > 0) {
        m_eyeBlink = CubismEyeBlink::Create(m_modelSetting);
    }

    const csmInt32 lipSyncIdCount = m_modelSetting->GetLipSyncParameterCount();
    for (csmInt32 i = 0; i < lipSyncIdCount; ++i) {
        m_lipSyncIds.PushBack(m_modelSetting->GetLipSyncParameterId(i));
    }

    if (m_modelSetting->GetExpressionCount() > 0) {
        const csmInt32 count = m_modelSetting->GetExpressionCount();
        for (csmInt32 i = 0; i < count; ++i) {
            const csmString expressionName = m_modelSetting->GetExpressionName(i);
            const csmString expressionRelativePath = m_modelSetting->GetExpressionFileName(i);
            const std::string expressionPath = m_modelHomeDir + expressionRelativePath.GetRawString();

            csmSizeInt expressionSize;
            csmByte* expressionBuffer = Live2DPal::loadFileAsBytes(expressionPath, &expressionSize);
            if (!expressionBuffer) {
                continue;
            }

            ACubismMotion* expressionMotion = LoadExpression(expressionBuffer, expressionSize,
                expressionName.GetRawString());
            Live2DPal::releaseBytes(expressionBuffer);

            if (expressionMotion) {
                if (m_expressions[expressionName.GetRawString()] != nullptr) {
                    ACubismMotion::Delete(m_expressions[expressionName.GetRawString()]);
                }
                m_expressions[expressionName.GetRawString()] = expressionMotion;
            }
        }
    }

    // 7. Breath
    m_breath = CubismBreath::Create();
    csmVector<CubismBreath::BreathParameterData> breathParams;

    CubismBreath::BreathParameterData p5;
    p5.ParameterId = CubismFramework::GetIdManager()->GetId("ParamBreath");
    p5.Offset = 0.5f;
    p5.Peak = 0.22f;
    p5.Cycle = 4.8f;
    p5.Weight = 0.35f;
    breathParams.PushBack(p5);

    m_breath->SetParameters(breathParams);

    // 8. Physics
    if (std::strcmp(m_modelSetting->GetPhysicsFileName(), "") != 0) {
        std::string physicsPath = dir + m_modelSetting->GetPhysicsFileName();
        buffer = Live2DPal::loadFileAsBytes(physicsPath, &size);
        if (buffer) {
            _physics = CubismPhysics::Create(buffer, size);
            Live2DPal::releaseBytes(buffer);
        }
    }

    // 9. Layout — let Cubism's default model matrix handle scaling
    // CubismUserModel::LoadModel() sets _modelMatrix with SetHeight(2.0)
    // which maps the model to fill NDC space. Do NOT reset to identity.

    Live2DPal::printLog("LoadAssets complete");
}

void Live2DModel::update() {
    const csmFloat32 dt = static_cast<csmFloat32>(Live2DPal::getDeltaTime());
    m_userTimeSeconds += dt;

    if (!_model) {
        return;
    }

    bool motionUpdated = false;
    _model->LoadParameters();

    if (_motionManager) {
        motionUpdated = _motionManager->UpdateMotion(_model, dt);
    }

    _model->SaveParameters();

    if (!motionUpdated && m_eyeBlink) {
        m_eyeBlink->UpdateParameters(_model, dt);
    }

    if (_expressionManager) {
        _expressionManager->UpdateMotion(_model, dt);
    }

    if (m_breath) {
        m_breath->UpdateParameters(_model, dt);
    }

    if (_physics) {
        _physics->Evaluate(_model, dt);
    }

    for (const auto& item : m_parameterDrives) {
        const ParameterDriveState& state = item.second;
        if (!state.parameterId || state.weight <= 0.001f) {
            continue;
        }
        if (state.additive) {
            _model->AddParameterValue(state.parameterId, state.value, state.weight);
        } else {
            _model->SetParameterValue(state.parameterId, state.value, state.weight);
        }
    }

    if (m_mouthOpen > 0.001f) {
        for (csmUint32 i = 0; i < m_lipSyncIds.GetSize(); ++i) {
            _model->AddParameterValue(m_lipSyncIds[i], m_mouthOpen, 0.8f);
        }
    }

    if (m_pose) {
        m_pose->UpdateParameters(_model, dt);
    }

    _model->Update();
}

void Live2DModel::draw(CubismMatrix44& projection) {
    if (!_model) return;
    projection.MultiplyByMatrix(_modelMatrix);
    GetRenderer<Rendering::CubismRenderer_OpenGLES2>()->SetMvpMatrix(&projection);
    GetRenderer<Rendering::CubismRenderer_OpenGLES2>()->DrawModel();
}

void Live2DModel::DoDraw() {
    // Rendering handled in draw()
}

std::string Live2DModel::resolveTouchArea(float x, float y) {
    if (m_modelSetting) {
        const csmInt32 hitAreaCount = m_modelSetting->GetHitAreasCount();
        for (csmInt32 i = 0; i < hitAreaCount; ++i) {
            const csmChar* hitAreaName = m_modelSetting->GetHitAreaName(i);
            if (!hitAreaName) {
                continue;
            }
            CubismIdHandle hitAreaId = m_modelSetting->GetHitAreaId(i);
            if (IsHit(hitAreaId, x, y)) {
                return hitAreaName;
            }
        }
    }
    return "";
}

void Live2DModel::onTouch(float x, float y) {
    const std::string hitArea = resolveTouchArea(x, y);
    Live2DPal::printLog("OnTouch x:%.2f y:%.2f area:%s", x, y, hitArea.c_str());

    if (hitArea == "Body") {
        startMotion("Tap@Body", 0, 3);
    } else {
        startMotion("Tap", 0, 3);
    }
}

void Live2DModel::setMouthOpen(Csm::csmFloat32 value) {
    if (value < 0.0f) {
        m_mouthOpen = 0.0f;
        return;
    }
    if (value > 1.0f) {
        m_mouthOpen = 1.0f;
        return;
    }
    m_mouthOpen = value;
}

void Live2DModel::setExpression(const Csm::csmChar* expressionId) {
    if (!_expressionManager) {
        return;
    }
    if (!expressionId || std::strlen(expressionId) <= 0) {
        _expressionManager->StopAllMotions();
        return;
    }
    const auto expressionIt = m_expressions.find(expressionId);
    if (expressionIt == m_expressions.end() || !expressionIt->second) {
        return;
    }
    _expressionManager->StartMotion(expressionIt->second, false);
}

void Live2DModel::setParameterValue(const Csm::csmChar* parameterId, Csm::csmFloat32 value,
    Csm::csmFloat32 weight) {
    if (!parameterId || std::strlen(parameterId) <= 0) {
        return;
    }
    if (_model && !hasParameter(parameterId)) {
        return;
    }
    ParameterDriveState state;
    state.parameterId = CubismFramework::GetIdManager()->GetId(parameterId);
    state.value = value;
    state.weight = weight < 0.0f ? 0.0f : (weight > 1.0f ? 1.0f : weight);
    state.additive = false;
    m_parameterDrives[parameterId] = state;
}

void Live2DModel::addParameterValue(const Csm::csmChar* parameterId, Csm::csmFloat32 value,
    Csm::csmFloat32 weight) {
    if (!parameterId || std::strlen(parameterId) <= 0) {
        return;
    }
    if (_model && !hasParameter(parameterId)) {
        return;
    }
    ParameterDriveState state;
    state.parameterId = CubismFramework::GetIdManager()->GetId(parameterId);
    state.value = value;
    state.weight = weight < 0.0f ? 0.0f : (weight > 1.0f ? 1.0f : weight);
    state.additive = true;
    m_parameterDrives[parameterId] = state;
}

void Live2DModel::clearParameterValue(const Csm::csmChar* parameterId) {
    if (!parameterId || std::strlen(parameterId) <= 0) {
        return;
    }
    m_parameterDrives.erase(parameterId);
}

bool Live2DModel::hasParameter(const Csm::csmChar* parameterId) const {
    if (!_model || !parameterId || std::strlen(parameterId) <= 0) {
        return false;
    }

    const csmInt32 parameterCount = _model->GetParameterCount();
    for (csmInt32 i = 0; i < parameterCount; ++i) {
        const CubismIdHandle currentId = _model->GetParameterId(static_cast<csmUint32>(i));
        if (cubismIdToString(currentId) == parameterId) {
            return true;
        }
    }
    return false;
}

Csm::csmInt32 Live2DModel::motionCount(const Csm::csmChar* group) const {
    if (!m_modelSetting || !group || std::strlen(group) <= 0) {
        return 0;
    }
    return m_modelSetting->GetMotionCount(group);
}

std::string Live2DModel::getCapabilityJson() {
    std::ostringstream out;
    out << "{";
    out << "\"loaded\":" << (_model ? "true" : "false");
    out << ",\"hasPhysics\":" << (_physics ? "true" : "false");
    out << ",\"hasPose\":" << (m_pose ? "true" : "false");

    out << ",\"parameters\":[";
    if (_model) {
        const csmInt32 parameterCount = _model->GetParameterCount();
        for (csmInt32 i = 0; i < parameterCount; ++i) {
            if (i > 0) {
                out << ",";
            }
            const CubismIdHandle parameterId = _model->GetParameterId(static_cast<csmUint32>(i));
            const std::string id = cubismIdToString(parameterId);
            out << "{";
            out << "\"id\":\"" << escapeJsonString(id.c_str()) << "\"";
            out << ",\"min\":" << _model->GetParameterMinimumValue(static_cast<csmUint32>(i));
            out << ",\"max\":" << _model->GetParameterMaximumValue(static_cast<csmUint32>(i));
            out << ",\"defaultValue\":" << _model->GetParameterDefaultValue(static_cast<csmUint32>(i));
            out << ",\"currentValue\":" << _model->GetParameterValue(i);
            out << ",\"role\":\"" << escapeJsonString(inferParameterRole(id).c_str()) << "\"";
            out << "}";
        }
    }
    out << "]";

    out << ",\"lipSyncParameterIds\":[";
    if (m_modelSetting) {
        const csmInt32 count = m_modelSetting->GetLipSyncParameterCount();
        for (csmInt32 i = 0; i < count; ++i) {
            if (i > 0) {
                out << ",";
            }
            out << "\"" << escapeJsonString(cubismIdToString(m_modelSetting->GetLipSyncParameterId(i)).c_str()) << "\"";
        }
    }
    out << "]";

    out << ",\"eyeBlinkParameterIds\":[";
    if (m_modelSetting) {
        const csmInt32 count = m_modelSetting->GetEyeBlinkParameterCount();
        for (csmInt32 i = 0; i < count; ++i) {
            if (i > 0) {
                out << ",";
            }
            out << "\"" << escapeJsonString(cubismIdToString(m_modelSetting->GetEyeBlinkParameterId(i)).c_str()) << "\"";
        }
    }
    out << "]";

    out << ",\"motionGroups\":[";
    if (m_modelSetting) {
        const csmInt32 groupCount = m_modelSetting->GetMotionGroupCount();
        for (csmInt32 i = 0; i < groupCount; ++i) {
            if (i > 0) {
                out << ",";
            }
            const csmChar* group = m_modelSetting->GetMotionGroupName(i);
            const csmInt32 motionCount = m_modelSetting->GetMotionCount(group);
            out << "{";
            out << "\"group\":\"" << escapeJsonString(group) << "\"";
            out << ",\"count\":" << motionCount;
            out << ",\"files\":[";
            for (csmInt32 motionIndex = 0; motionIndex < motionCount; ++motionIndex) {
                if (motionIndex > 0) {
                    out << ",";
                }
                out << "\"" << escapeJsonString(m_modelSetting->GetMotionFileName(group, motionIndex)) << "\"";
            }
            out << "]}";
        }
    }
    out << "]";

    out << ",\"expressions\":[";
    if (m_modelSetting) {
        const csmInt32 expressionCount = m_modelSetting->GetExpressionCount();
        for (csmInt32 i = 0; i < expressionCount; ++i) {
            if (i > 0) {
                out << ",";
            }
            out << "{";
            out << "\"id\":\"" << escapeJsonString(m_modelSetting->GetExpressionName(i)) << "\"";
            out << ",\"file\":\"" << escapeJsonString(m_modelSetting->GetExpressionFileName(i)) << "\"";
            out << "}";
        }
    }
    out << "]";

    out << ",\"hitAreas\":[";
    if (m_modelSetting) {
        const csmInt32 hitAreaCount = m_modelSetting->GetHitAreasCount();
        for (csmInt32 i = 0; i < hitAreaCount; ++i) {
            if (i > 0) {
                out << ",";
            }
            out << "{";
            out << "\"name\":\"" << escapeJsonString(m_modelSetting->GetHitAreaName(i)) << "\"";
            out << ",\"id\":\"" << escapeJsonString(cubismIdToString(m_modelSetting->GetHitAreaId(i)).c_str()) << "\"";
            out << "}";
        }
    }
    out << "]";
    out << "}";
    return out.str();
}

CubismMotionQueueEntryHandle Live2DModel::startMotion(
    const csmChar* group, csmInt32 no, csmInt32 priority) {
    if (!m_modelSetting || !_motionManager || !group || std::strlen(group) <= 0 || no < 0) {
        return InvalidMotionQueueEntryHandleValue;
    }
    if (no >= m_modelSetting->GetMotionCount(group)) {
        return InvalidMotionQueueEntryHandleValue;
    }

    if (priority == 3) {
        _motionManager->SetReservePriority(priority);
    } else if (!_motionManager->ReserveMotion(priority)) {
        return InvalidMotionQueueEntryHandleValue;
    }

    const std::string fileName = m_modelSetting->GetMotionFileName(group, no);
    if (fileName.empty()) {
        return InvalidMotionQueueEntryHandleValue;
    }

    char buf[64];
    std::snprintf(buf, sizeof(buf), "%s_%d", group, no);
    std::string name = buf;

    auto* motion = static_cast<CubismMotion*>(m_motions[name]);
    if (!motion) {
        std::string motionPath = m_modelHomeDir + fileName;
        csmSizeInt size;
        csmByte* data = Live2DPal::loadFileAsBytes(motionPath, &size);
        if (!data) return InvalidMotionQueueEntryHandleValue;

        motion = static_cast<CubismMotion*>(CubismMotion::Create(data, size));
        Live2DPal::releaseBytes(data);

        if (motion) {
            csmFloat32 fadeIn = m_modelSetting->GetMotionFadeInTimeValue(group, no);
            csmFloat32 fadeOut = m_modelSetting->GetMotionFadeOutTimeValue(group, no);
            motion->SetFadeInTime(fadeIn >= 0.0f ? fadeIn : 1.0f);
            motion->SetFadeOutTime(fadeOut >= 0.0f ? fadeOut : 1.0f);
        }
        m_motions[name] = motion;
    }

    if (motion) {
        return _motionManager->StartMotionPriority(motion, false, priority);
    }
    return InvalidMotionQueueEntryHandleValue;
}

} // namespace nna::graphics
