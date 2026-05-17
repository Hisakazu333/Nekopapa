/*
 * Project: OpenNeko Engine (NNA Core)
 * Core Architecture by Nekonano-Aether
 * Copyright (c) 2026 Nekonano-Aether. All rights reserved.
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include "live2d_model.h"
#include <map>
#include <string>

namespace nna::graphics {

class Live2DStageDriver {
public:
    Live2DStageDriver();

    void reset();
    void setMouthOpen(float value);
    void triggerTouch(const std::string& hitArea);
    void triggerLookAt(float x, float y, float strength = 1.0f, int durationMs = 1800);
    void startLookTracking(float x, float y, float strength = 1.0f);
    void updateLookTracking(float x, float y, float strength = 1.0f);
    void releaseLookTracking(int durationMs = 900);
    void update(Live2DModel& model, float deltaSeconds);

private:
    enum class TouchArea {
        None,
        Head,
        Body,
        FlickUp,
        FlickDown
    };

public:
    struct ParameterBinding {
        const char* role;
        const char* parameterId;
        float minValue;
        float maxValue;
        float weight;
        float smoothing;
    };

private:
    static float clamp(float value, float minValue, float maxValue);
    static float clampUnit(float value);
    static float smoothValue(float current, float target, float factor);
    static double nowMs();
    static TouchArea resolveTouchArea(const std::string& hitArea);
    static const ParameterBinding* bindingForRole(const std::string& role);
    static float resolveNativeValue(const ParameterBinding& binding, float normalizedValue);
    static float clampFrameValue(const std::string& role, float value);

    void applyTrackingTarget(float x, float y, float strength, bool restart);
    void updateIdleGaze(double now);
    bool isTrackingActive(double now) const;
    void applyRole(Live2DModel& model, const std::string& role, float targetValue, float deltaSeconds);

    float m_mouthOpen = 0.0f;
    float m_gazeX = 0.0f;
    float m_gazeY = 0.0f;
    float m_headX = 0.0f;
    float m_headY = 0.0f;
    float m_bodyX = 0.0f;
    float m_bodyY = 0.0f;
    float m_gazeTargetX = 0.0f;
    float m_gazeTargetY = 0.0f;
    double m_seconds = 0.0;
    double m_touchStartedAtMs = 0.0;
    double m_touchImpulseStartedAtMs = 0.0;
    double m_trackingStartedAtMs = 0.0;
    double m_trackingActiveUntilMs = 0.0;
    double m_releaseStartedAtMs = 0.0;
    double m_releaseDurationMs = 0.0;
    double m_nextIdleGazeAtMs = 0.0;
    float m_releaseStartX = 0.0f;
    float m_releaseStartY = 0.0f;
    bool m_trackingActive = false;
    TouchArea m_touchArea = TouchArea::None;
    std::map<std::string, float> m_parameterValues;
};

} // namespace nna::graphics
