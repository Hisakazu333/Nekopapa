/*
 * Project: OpenNeko Engine (NNA Core)
 * Core Architecture by Nekonano-Aether
 * Copyright (c) 2026 Nekonano-Aether. All rights reserved.
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include <CubismFramework.hpp>
#include <Model/CubismUserModel.hpp>
#include <CubismModelSettingJson.hpp>
#include <Effect/CubismEyeBlink.hpp>
#include <Effect/CubismBreath.hpp>
#include <Effect/CubismPose.hpp>
#include <Id/CubismId.hpp>
#include <Type/csmVector.hpp>
#include "live2d_texture.h"
#include <map>
#include <string>

namespace nna::graphics {

class Live2DModel : public Csm::CubismUserModel {
public:
    Live2DModel();
    virtual ~Live2DModel();

    void loadAssets(const std::string& dir, const std::string& fileName);
    void update();
    void draw(Csm::CubismMatrix44& projection);

    std::string resolveTouchArea(float x, float y);
    void onTouch(float x, float y);
    void setMouthOpen(Csm::csmFloat32 value);
    void setExpression(const Csm::csmChar* expressionId);
    void setParameterValue(const Csm::csmChar* parameterId, Csm::csmFloat32 value,
        Csm::csmFloat32 weight = 1.0f);
    void addParameterValue(const Csm::csmChar* parameterId, Csm::csmFloat32 value,
        Csm::csmFloat32 weight = 1.0f);
    void clearParameterValue(const Csm::csmChar* parameterId);
    bool hasParameter(const Csm::csmChar* parameterId) const;
    Csm::csmInt32 motionCount(const Csm::csmChar* group) const;
    std::string getCapabilityJson();
    Csm::CubismMotionQueueEntryHandle startMotion(
        const Csm::csmChar* group, Csm::csmInt32 no, Csm::csmInt32 priority);

protected:
    void DoDraw();

private:
    struct ParameterDriveState {
        Csm::CubismIdHandle parameterId = nullptr;
        Csm::csmFloat32 value = 0.0f;
        Csm::csmFloat32 weight = 1.0f;
        bool additive = true;
    };

    Live2DTextureManager* m_textureManager;
    Csm::CubismModelSettingJson* m_modelSetting;
    std::string m_modelHomeDir;
    Csm::csmFloat32 m_userTimeSeconds;

    Csm::CubismEyeBlink* m_eyeBlink;
    Csm::CubismBreath* m_breath;
    Csm::CubismPose* m_pose;
    std::map<std::string, Csm::ACubismMotion*> m_motions;
    std::map<std::string, Csm::ACubismMotion*> m_expressions;
    std::map<std::string, ParameterDriveState> m_parameterDrives;
    Csm::csmVector<Csm::CubismIdHandle> m_lipSyncIds;
    Csm::csmFloat32 m_mouthOpen = 0.0f;
};

} // namespace nna::graphics
