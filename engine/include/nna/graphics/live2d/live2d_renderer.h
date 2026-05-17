/*
 * Project: OpenNeko Engine (NNA Core)
 * Core Architecture by Nekonano-Aether
 * Copyright (c) 2026 Nekonano-Aether. All rights reserved.
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include "live2d_model.h"
#include "live2d_stage_driver.h"
#include "live2d_allocator.h"
#include "nna/export.h"
#include <mutex>
#include <string>

namespace nna::graphics {

class NNA_EXPORT Live2DRenderer {
public:
    Live2DRenderer();
    ~Live2DRenderer();

    /// Initialize Cubism Framework (call once before any model loading)
    bool initFramework();

    /// Shutdown Cubism Framework
    void disposeFramework();

    /// Load a model from directory
    bool loadModel(const std::string& modelDir, const std::string& modelFileName);

    /// Unload current model
    void unloadModel();

    /// Update model state (call per frame)
    void update();

    /// Render model into current OpenGL context/FBO
    void draw(int width, int height, float scale = 1.0f, float offsetX = 0.0f, float offsetY = 0.0f,
        float projectionWidthHint = 0.0f, float projectionHeightHint = 0.0f);

    /// Touch interaction
    void onTouch(float screenX, float screenY, int viewWidth, int viewHeight,
        float projectionWidthHint = 0.0f, float projectionHeightHint = 0.0f);

    /// Lip sync / mouth driving
    void setMouthOpen(float value);

    /// Motion control
    void startMotion(const char* group, int no, int priority);
    void setExpression(const char* expressionId);
    void setParameterValue(const char* parameterId, float value, float weight = 1.0f);
    void addParameterValue(const char* parameterId, float value, float weight = 1.0f);
    void clearParameterValue(const char* parameterId);
    std::string capabilityJson();
    void triggerLookAt(float x, float y, float strength = 1.0f, int durationMs = 1800);
    void startLookTracking(float x, float y, float strength = 1.0f);
    void updateLookTracking(float x, float y, float strength = 1.0f);
    void releaseLookTracking(int durationMs = 900);

    /// Check if a model is loaded
    bool isModelLoaded() const;

private:
    Live2DAllocator m_allocator;
    Live2DModel* m_model = nullptr;
    std::mutex m_modelMutex;
    bool m_frameworkInitialized = false;
    float m_lastScale = 1.0f;
    float m_lastOffsetX = 0.0f;
    float m_lastOffsetY = 0.0f;
    int m_lastViewWidth = 0;
    int m_lastViewHeight = 0;
    float m_lastProjectionWidthHint = 0.0f;
    float m_lastProjectionHeightHint = 0.0f;
    float m_mouthOpen = 0.0f;
    Live2DStageDriver m_stageDriver;
    double m_nextIdleMotionAtMs = 0.0;
    int m_idleMotionIndex = 0;
};

} // namespace nna::graphics
