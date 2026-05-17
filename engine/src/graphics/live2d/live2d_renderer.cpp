/*
 * Project: OpenNeko Engine (NNA Core)
 * Core Architecture by Nekonano-Aether
 * Copyright (c) 2026 Nekonano-Aether. All rights reserved.
 * SPDX-License-Identifier: MIT
 */

#include "nna/graphics/live2d/live2d_renderer.h"
#include "nna/graphics/live2d/live2d_pal.h"
#include <CubismFramework.hpp>
#include <chrono>

#ifdef _WIN32
#include <GL/glew.h>
#endif

namespace nna::graphics {

namespace {

double monotonicMs() {
    const auto now = std::chrono::steady_clock::now().time_since_epoch();
    return std::chrono::duration<double, std::milli>(now).count();
}

} // namespace

static Csm::csmByte* s_loadFile(const std::string fileName, Csm::csmSizeInt* outSize) {
    return Live2DPal::loadFileAsBytes(fileName, outSize);
}

static void s_releaseBytes(Csm::csmByte* address) {
    Live2DPal::releaseBytes(address);
}

Live2DRenderer::Live2DRenderer() {}

Live2DRenderer::~Live2DRenderer() {
    unloadModel();
    disposeFramework();
}

bool Live2DRenderer::initFramework() {
    if (m_frameworkInitialized) return true;

#ifdef _WIN32
    // Load GL 2.0+ function pointers via wglGetProcAddress
    if (glewInit() != GLEW_OK) {
        Live2DPal::printLog("ERROR: glewInit() failed");
        return false;
    }
    Live2DPal::printLog("GL functions loaded (GLEW shim)");
#endif

    Csm::CubismFramework::Option option;
    option.LogFunction = Live2DPal::printMessage;
    option.LoadFileFunction = s_loadFile;
    option.ReleaseBytesFunction = s_releaseBytes;
    option.LoggingLevel = Csm::CubismFramework::Option::LogLevel_Warning;

    Csm::CubismFramework::StartUp(&m_allocator, &option);
    Csm::CubismFramework::Initialize();
    m_frameworkInitialized = true;

    Live2DPal::printLog("CubismFramework initialized");
    return true;
}

void Live2DRenderer::disposeFramework() {
    if (!m_frameworkInitialized) return;
    Csm::CubismFramework::Dispose();
    m_frameworkInitialized = false;
}

bool Live2DRenderer::loadModel(const std::string& modelDir, const std::string& modelFileName) {
    std::lock_guard<std::mutex> lock(m_modelMutex);

    if (m_model) {
        delete m_model;
        m_model = nullptr;
    }

    m_model = new Live2DModel();
    m_model->loadAssets(modelDir, modelFileName);
    m_stageDriver.reset();
    m_nextIdleMotionAtMs = 0.0;
    m_idleMotionIndex = 0;

    if (!m_model->GetModel()) {
        Live2DPal::printLog("ERROR: Model load failed: %s%s", modelDir.c_str(), modelFileName.c_str());
        delete m_model;
        m_model = nullptr;
        m_stageDriver.reset();
        m_nextIdleMotionAtMs = 0.0;
        m_idleMotionIndex = 0;
        return false;
    }

    Live2DPal::printLog("Model loaded: %s%s", modelDir.c_str(), modelFileName.c_str());
    return true;
}

void Live2DRenderer::unloadModel() {
    std::lock_guard<std::mutex> lock(m_modelMutex);
    if (m_model) {
        delete m_model;
        m_model = nullptr;
    }
    m_stageDriver.reset();
    m_nextIdleMotionAtMs = 0.0;
    m_idleMotionIndex = 0;
}

void Live2DRenderer::update() {
    Live2DPal::updateTime();
    std::lock_guard<std::mutex> lock(m_modelMutex);
    if (m_model) {
        const float dt = static_cast<float>(Live2DPal::getDeltaTime());
        const double now = monotonicMs();
        if (m_nextIdleMotionAtMs <= 0.0 || now >= m_nextIdleMotionAtMs) {
            const int idleCount = static_cast<int>(m_model->motionCount("Idle"));
            if (idleCount > 0) {
                m_model->startMotion("Idle", m_idleMotionIndex % idleCount, 1);
                m_idleMotionIndex = (m_idleMotionIndex + 1) % idleCount;
            }
            m_nextIdleMotionAtMs = now + 7200.0;
        }
        m_stageDriver.setMouthOpen(m_mouthOpen);
        m_stageDriver.update(*m_model, dt);
        m_model->setMouthOpen(m_mouthOpen);
        m_model->update();
    }
}

void Live2DRenderer::draw(int width, int height, float scale, float offsetX, float offsetY,
    float projectionWidthHint, float projectionHeightHint) {
    std::lock_guard<std::mutex> lock(m_modelMutex);
    if (!m_model || !m_model->GetModel() || width <= 0 || height <= 0) return;

    m_lastViewWidth = width;
    m_lastViewHeight = height;
    m_lastScale = scale;
    m_lastOffsetX = offsetX;
    m_lastOffsetY = offsetY;
    m_lastProjectionWidthHint = projectionWidthHint;
    m_lastProjectionHeightHint = projectionHeightHint;

    const float projectionWidth = projectionWidthHint > 0.0f ? projectionWidthHint : static_cast<float>(width);
    const float projectionHeight = projectionHeightHint > 0.0f ? projectionHeightHint : static_cast<float>(height);
    float screenRatio = projectionHeight > 0.0f ? projectionWidth / projectionHeight : 1.0f;

    Csm::CubismMatrix44 projection;
    projection.LoadIdentity();

    // Combine user scale with aspect ratio correction in one call
    // Scale() sets values directly (not multiplicative), so compute final values
    float scaleX = scale;
    float scaleY = scale;
    if (screenRatio > 1.0f) {
        scaleX /= screenRatio;
    } else {
        scaleY *= screenRatio;
    }
    projection.Scale(scaleX, scaleY);

    // User-controlled offset
    projection.TranslateX(offsetX);
    projection.TranslateY(offsetY);

    m_model->draw(projection);
}

void Live2DRenderer::onTouch(float screenX, float screenY, int viewWidth, int viewHeight,
    float projectionWidthHint, float projectionHeightHint) {
    std::lock_guard<std::mutex> lock(m_modelMutex);
    if (!m_model || !m_model->GetModel() || viewWidth <= 0 || viewHeight <= 0) return;

    const int resolvedWidth = m_lastViewWidth > 0 ? m_lastViewWidth : viewWidth;
    const int resolvedHeight = m_lastViewHeight > 0 ? m_lastViewHeight : viewHeight;
    const float resolvedProjectionWidth = projectionWidthHint > 0.0f
        ? projectionWidthHint
        : (m_lastProjectionWidthHint > 0.0f ? m_lastProjectionWidthHint : static_cast<float>(resolvedWidth));
    const float resolvedProjectionHeight = projectionHeightHint > 0.0f
        ? projectionHeightHint
        : (m_lastProjectionHeightHint > 0.0f ? m_lastProjectionHeightHint : static_cast<float>(resolvedHeight));
    float screenRatio = resolvedProjectionHeight > 0.0f
        ? resolvedProjectionWidth / resolvedProjectionHeight
        : 1.0f;
    float totalScaleX = m_lastScale;
    float totalScaleY = m_lastScale;
    if (screenRatio > 1.0f) {
        totalScaleX /= screenRatio;
    } else {
        totalScaleY *= screenRatio;
    }

    float ndcX = (screenX / resolvedWidth) * 2.0f - 1.0f;
    float ndcY = -((screenY / resolvedHeight) * 2.0f - 1.0f);
    float modelX = (ndcX - m_lastOffsetX) / totalScaleX;
    float modelY = (ndcY - m_lastOffsetY) / totalScaleY;

    const std::string hitArea = m_model->resolveTouchArea(modelX, modelY);
    m_stageDriver.triggerTouch(hitArea);
    m_model->onTouch(modelX, modelY);
}

void Live2DRenderer::setMouthOpen(float value) {
    std::lock_guard<std::mutex> lock(m_modelMutex);
    if (value < 0.0f) {
        m_mouthOpen = 0.0f;
    } else if (value > 1.0f) {
        m_mouthOpen = 1.0f;
    } else {
        m_mouthOpen = value;
    }
    m_stageDriver.setMouthOpen(m_mouthOpen);
}

void Live2DRenderer::startMotion(const char* group, int no, int priority) {
    std::lock_guard<std::mutex> lock(m_modelMutex);
    if (m_model) {
        m_model->startMotion(group, no, priority);
    }
}

void Live2DRenderer::setExpression(const char* expressionId) {
    std::lock_guard<std::mutex> lock(m_modelMutex);
    if (m_model) {
        m_model->setExpression(expressionId ? expressionId : "");
    }
}

void Live2DRenderer::setParameterValue(const char* parameterId, float value, float weight) {
    std::lock_guard<std::mutex> lock(m_modelMutex);
    if (m_model) {
        m_model->setParameterValue(parameterId, value, weight);
    }
}

void Live2DRenderer::addParameterValue(const char* parameterId, float value, float weight) {
    std::lock_guard<std::mutex> lock(m_modelMutex);
    if (m_model) {
        m_model->addParameterValue(parameterId, value, weight);
    }
}

void Live2DRenderer::clearParameterValue(const char* parameterId) {
    std::lock_guard<std::mutex> lock(m_modelMutex);
    if (m_model) {
        m_model->clearParameterValue(parameterId);
    }
}

std::string Live2DRenderer::capabilityJson() {
    std::lock_guard<std::mutex> lock(m_modelMutex);
    if (!m_model) {
        return "{\"loaded\":false}";
    }
    return m_model->getCapabilityJson();
}

void Live2DRenderer::triggerLookAt(float x, float y, float strength, int durationMs) {
    std::lock_guard<std::mutex> lock(m_modelMutex);
    m_stageDriver.triggerLookAt(x, y, strength, durationMs);
}

void Live2DRenderer::startLookTracking(float x, float y, float strength) {
    std::lock_guard<std::mutex> lock(m_modelMutex);
    m_stageDriver.startLookTracking(x, y, strength);
}

void Live2DRenderer::updateLookTracking(float x, float y, float strength) {
    std::lock_guard<std::mutex> lock(m_modelMutex);
    m_stageDriver.updateLookTracking(x, y, strength);
}

void Live2DRenderer::releaseLookTracking(int durationMs) {
    std::lock_guard<std::mutex> lock(m_modelMutex);
    m_stageDriver.releaseLookTracking(durationMs);
}

bool Live2DRenderer::isModelLoaded() const {
    return m_model != nullptr;
}

} // namespace nna::graphics
