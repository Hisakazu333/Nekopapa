/*
 * Project: OpenNeko Engine (NNA Core)
 * Core Architecture by Nekonano-Aether
 * Copyright (c) 2026 Nekonano-Aether. All rights reserved.
 * SPDX-License-Identifier: MIT
 */

#include "nna/graphics/live2d/live2d_stage_driver.h"
#include <algorithm>
#include <chrono>
#include <cctype>
#include <cmath>

namespace nna::graphics {

namespace {

constexpr float kIdleAmplitudeX = 0.055f;
constexpr float kIdleAmplitudeY = 0.036f;
constexpr float kIdleAmplitudeZ = 0.028f;
constexpr float kBodyAmplitudeX = 0.024f;
constexpr float kBodyAmplitudeY = 0.015f;
constexpr float kBodyAmplitudeZ = 0.013f;
constexpr float kSmoothing = 0.24f;
constexpr float kGazeFollowScale = 0.64f;
constexpr float kGazeStrengthScale = 0.94f;
constexpr float kGazeReleaseScale = 1.08f;
constexpr float kEyeFollowScaleX = 0.92f;
constexpr float kEyeFollowScaleY = 0.86f;
constexpr float kHeadFollowScaleX = 0.54f;
constexpr float kHeadFollowScaleY = 0.48f;
constexpr float kHeadFollowScaleZ = 0.36f;
constexpr float kBodyFollowScaleX = 0.40f;
constexpr float kBodyFollowScaleY = 0.33f;
constexpr float kBodyFollowScaleZ = 0.28f;
constexpr float kTrackingEyeSmoothingScale = 1.32f;
constexpr float kTrackingHeadSmoothingScale = 0.82f;
constexpr float kTrackingBodySmoothingScale = 0.66f;
constexpr float kTouchImpulseScale = 0.68f;
constexpr float kSpeechBodyScale = 0.58f;
constexpr float kDeadZone = 0.01f;
constexpr float kPhaseSeed = 713.0f;
constexpr float kPi = 3.14159265358979323846f;

constexpr Live2DStageDriver::ParameterBinding kBindings[] = {
    {"angleX", "ParamAngleX", -30.0f, 30.0f, 0.90f, 0.38f},
    {"angleY", "ParamAngleY", -18.0f, 18.0f, 0.86f, 0.38f},
    {"angleZ", "ParamAngleZ", -12.0f, 12.0f, 0.74f, 0.42f},
    {"bodyAngleX", "ParamBodyAngleX", -10.0f, 10.0f, 0.82f, 0.40f},
    {"bodyAngleY", "ParamBodyAngleY", -10.0f, 10.0f, 0.66f, 0.42f},
    {"bodyAngleZ", "ParamBodyAngleZ", -10.0f, 10.0f, 0.58f, 0.44f},
    {"breath", "ParamBreath", 0.0f, 1.0f, 0.68f, 0.28f},
    {"eyeBallX", "ParamEyeBallX", -1.0f, 1.0f, 0.92f, 0.32f},
    {"eyeBallY", "ParamEyeBallY", -1.0f, 1.0f, 0.92f, 0.32f},
    {"eyeOpenLeft", "ParamEyeLOpen", 0.0f, 1.0f, 0.90f, 0.22f},
    {"eyeOpenRight", "ParamEyeROpen", 0.0f, 1.0f, 0.90f, 0.22f},
    {"mouthForm", "ParamMouthForm", -1.0f, 1.0f, 0.56f, 0.34f},
    {"shoulder", "ParamShoulder", -1.0f, 1.0f, 0.74f, 0.24f},
    {"armLeftA", "ParamArmLA", -10.0f, 10.0f, 0.76f, 0.24f},
    {"armRightA", "ParamArmRA", -10.0f, 10.0f, 0.76f, 0.24f},
    {"armLeftB", "ParamArmLB", -10.0f, 10.0f, 0.68f, 0.26f},
    {"armRightB", "ParamArmRB", -10.0f, 10.0f, 0.68f, 0.26f},
    {"handLeft", "ParamHandL", -10.0f, 10.0f, 0.62f, 0.28f},
    {"handRight", "ParamHandR", -10.0f, 10.0f, 0.62f, 0.28f},
    {"handLeftB", "ParamHandLB", -10.0f, 10.0f, 0.58f, 0.30f},
    {"handRightB", "ParamHandRB", -10.0f, 10.0f, 0.58f, 0.30f},
    {"hairAhoge", "ParamHairAhoge", -10.0f, 10.0f, 0.58f, 0.32f},
    {"cheek", "ParamCheek", 0.0f, 1.0f, 0.45f, 0.28f},
};

float deadZone(float value) {
    return std::fabs(value) < kDeadZone ? 0.0f : value;
}

void add(std::map<std::string, float>& values, const std::string& role, float value) {
    values[role] = values[role] + value;
}

} // namespace

Live2DStageDriver::Live2DStageDriver() {
    reset();
}

void Live2DStageDriver::reset() {
    m_mouthOpen = 0.0f;
    m_gazeX = 0.0f;
    m_gazeY = 0.0f;
    m_headX = 0.0f;
    m_headY = 0.0f;
    m_bodyX = 0.0f;
    m_bodyY = 0.0f;
    m_gazeTargetX = 0.0f;
    m_gazeTargetY = 0.0f;
    m_seconds = 0.0;
    m_touchStartedAtMs = 0.0;
    m_touchImpulseStartedAtMs = 0.0;
    m_trackingStartedAtMs = 0.0;
    m_trackingActiveUntilMs = 0.0;
    m_releaseStartedAtMs = 0.0;
    m_releaseDurationMs = 0.0;
    m_nextIdleGazeAtMs = nowMs() + 800.0;
    m_releaseStartX = 0.0f;
    m_releaseStartY = 0.0f;
    m_trackingActive = false;
    m_touchArea = TouchArea::None;
    m_parameterValues.clear();
}

void Live2DStageDriver::setMouthOpen(float value) {
    m_mouthOpen = clampUnit(value);
}

void Live2DStageDriver::triggerTouch(const std::string& hitArea) {
    m_touchArea = resolveTouchArea(hitArea);
    const double now = nowMs();
    m_touchStartedAtMs = now;
    m_touchImpulseStartedAtMs = now;

    if (m_touchArea == TouchArea::Head) {
        triggerLookAt(0.0f, 0.32f, 0.96f, 1700);
    } else if (m_touchArea == TouchArea::FlickUp) {
        triggerLookAt(0.16f, 0.44f, 1.06f, 1500);
    } else if (m_touchArea == TouchArea::FlickDown) {
        triggerLookAt(-0.12f, -0.32f, 1.02f, 1500);
    } else {
        triggerLookAt(0.20f, -0.08f, 0.92f, 1500);
    }
}

void Live2DStageDriver::triggerLookAt(float x, float y, float strength, int durationMs) {
    const float safeStrength = clamp(strength * kGazeStrengthScale, 0.2f, 1.4f);
    const float safeX = clamp(x, -1.0f, 1.0f);
    const float safeY = clamp(y, -1.0f, 1.0f);
    const double now = nowMs();
    m_trackingActive = false;
    m_trackingStartedAtMs = 0.0;
    m_releaseStartedAtMs = 0.0;
    m_releaseDurationMs = 0.0;
    m_touchStartedAtMs = now;
    m_gazeTargetX = clamp(safeX * safeStrength, -0.96f, 0.96f);
    m_gazeTargetY = clamp(safeY * safeStrength, -0.92f, 0.92f);
    m_nextIdleGazeAtMs = now + clamp(static_cast<float>(durationMs), 600.0f, 3600.0f);
}

void Live2DStageDriver::startLookTracking(float x, float y, float strength) {
    applyTrackingTarget(x, y, strength, true);
}

void Live2DStageDriver::updateLookTracking(float x, float y, float strength) {
    applyTrackingTarget(x, y, strength, false);
}

void Live2DStageDriver::releaseLookTracking(int durationMs) {
    const double now = nowMs();
    m_trackingActive = false;
    m_releaseStartedAtMs = now;
    m_releaseDurationMs = clamp(static_cast<float>(durationMs) * kGazeReleaseScale, 360.0f, 1800.0f);
    m_releaseStartX = m_gazeTargetX;
    m_releaseStartY = m_gazeTargetY;
    m_touchStartedAtMs = now;
    m_trackingStartedAtMs = 0.0;
    m_nextIdleGazeAtMs = now + m_releaseDurationMs + 600.0;
}

void Live2DStageDriver::update(Live2DModel& model, float deltaSeconds) {
    const float dt = clamp(deltaSeconds, 0.016f, 0.12f);
    m_seconds += dt;
    const double now = nowMs();

    updateIdleGaze(now);
    const bool tracking = isTrackingActive(now);
    const float speechDamp = m_mouthOpen > 0.02f ? (tracking ? 0.90f : 0.76f) : 1.0f;
    const float baseSmoothing = clamp(kSmoothing * 0.72f, 0.10f, 0.34f);
    const float trackingHold = tracking
        ? clamp(static_cast<float>(now - m_trackingStartedAtMs) / 420.0f, 0.0f, 1.0f)
        : 0.0f;
    const float eyeSmoothing = tracking
        ? clamp(kSmoothing * kTrackingEyeSmoothingScale * (3.15f + trackingHold * 0.5f), 0.78f, 0.98f)
        : baseSmoothing;
    const float headSmoothing = tracking
        ? clamp(kSmoothing * kTrackingHeadSmoothingScale * (1.42f + trackingHold * 0.26f), 0.28f, 0.58f)
        : baseSmoothing * 0.64f;
    const float bodySmoothing = tracking
        ? clamp(kSmoothing * kTrackingBodySmoothingScale * (0.62f + trackingHold * 0.16f), 0.07f, 0.32f)
        : baseSmoothing * 0.44f;

    m_gazeX = smoothValue(m_gazeX, m_gazeTargetX, eyeSmoothing);
    m_gazeY = smoothValue(m_gazeY, m_gazeTargetY, eyeSmoothing);
    m_headX = smoothValue(m_headX, m_gazeX, headSmoothing);
    m_headY = smoothValue(m_headY, m_gazeY, headSmoothing);
    m_bodyX = smoothValue(m_bodyX, m_headX, bodySmoothing);
    m_bodyY = smoothValue(m_bodyY, m_headY, bodySmoothing);

    std::map<std::string, float> frame = {
        {"angleX", 0.0f},
        {"angleY", 0.0f},
        {"angleZ", 0.0f},
        {"bodyAngleX", 0.0f},
        {"bodyAngleY", 0.0f},
        {"bodyAngleZ", 0.0f},
        {"breath", 0.54f},
        {"eyeBallX", 0.0f},
        {"eyeBallY", 0.0f},
        {"mouthForm", 0.0f},
        {"shoulder", 0.0f},
        {"armLeftA", 0.0f},
        {"armRightA", 0.0f},
        {"armLeftB", 0.0f},
        {"armRightB", 0.0f},
        {"handLeft", 0.0f},
        {"handRight", 0.0f},
        {"handLeftB", 0.0f},
        {"handRightB", 0.0f},
        {"hairAhoge", 0.0f},
        {"cheek", 0.0f},
    };

    const float idleSpeechDamp = m_mouthOpen > 0.02f ? 0.72f : 1.0f;
    add(frame, "angleX", std::sin(m_seconds * 0.74f + kPhaseSeed * 0.0007f) * kIdleAmplitudeX * idleSpeechDamp);
    add(frame, "angleY", std::sin(m_seconds * 0.47f + 1.6f + kPhaseSeed * 0.0003f) * kIdleAmplitudeY * idleSpeechDamp);
    add(frame, "angleZ", std::sin(m_seconds * 0.58f + 0.9f + kPhaseSeed * 0.0005f) * kIdleAmplitudeZ * idleSpeechDamp);
    add(frame, "bodyAngleX", std::sin(m_seconds * 0.38f + 0.7f + kPhaseSeed * 0.0004f) * kBodyAmplitudeX * idleSpeechDamp);
    add(frame, "bodyAngleY", std::sin(m_seconds * 0.34f + 1.4f + kPhaseSeed * 0.0006f) * kBodyAmplitudeY * idleSpeechDamp);
    add(frame, "bodyAngleZ", std::sin(m_seconds * 0.42f + 2.1f + kPhaseSeed * 0.0008f) * kBodyAmplitudeZ * idleSpeechDamp);
    frame["breath"] = clamp(0.54f + std::sin(m_seconds * 1.08f + kPhaseSeed * 0.0009f) * 0.055f, 0.0f, 1.0f);

    const float eyeTrackingBoost = tracking ? 1.12f + trackingHold * 0.08f : 1.0f;
    const float eyeX = clamp(deadZone(m_gazeX * eyeTrackingBoost * speechDamp * kEyeFollowScaleX), -0.96f, 0.96f);
    const float eyeY = clamp(deadZone(m_gazeY * eyeTrackingBoost * speechDamp * kEyeFollowScaleY), -0.94f, 0.94f);
    const float followScale = clamp(0.58f + kGazeFollowScale * 0.82f, 0.48f, 1.65f);
    const float trackingBoost = tracking ? 1.18f + trackingHold * 0.1f : 1.0f;
    frame["eyeBallX"] = eyeX;
    frame["eyeBallY"] = eyeY;
    add(frame, "angleX", deadZone(m_headX * speechDamp * 0.28f * followScale * trackingBoost * kHeadFollowScaleX));
    add(frame, "angleY", deadZone(m_headY * speechDamp * 0.22f * followScale * trackingBoost * kHeadFollowScaleY));
    add(frame, "angleZ", deadZone((-m_headX * 0.06f + m_headY * 0.024f) * followScale * trackingBoost * kHeadFollowScaleZ));
    add(frame, "bodyAngleX", deadZone(m_bodyX * speechDamp * 0.16f * followScale * kBodyFollowScaleX));
    add(frame, "bodyAngleY", deadZone(m_bodyY * speechDamp * 0.12f * followScale * kBodyFollowScaleY));
    add(frame, "bodyAngleZ", deadZone((-m_bodyX * 0.038f + m_bodyY * 0.018f) * followScale * kBodyFollowScaleZ));

    if (m_mouthOpen > 0.02f) {
        const float speechEnergy = clamp(m_mouthOpen * 1.05f + 0.18f, 0.22f, 1.1f);
        const float nod = std::sin(m_seconds * 3.6f + kPhaseSeed * 0.6f) * 0.032f * speechEnergy;
        const float roll = std::sin(m_seconds * 2.7f + kPhaseSeed * 0.8f) * 0.018f * speechEnergy;
        add(frame, "angleX", deadZone(nod * 0.4f * kSpeechBodyScale));
        add(frame, "angleY", deadZone(0.018f * speechEnergy * kSpeechBodyScale));
        add(frame, "angleZ", deadZone(roll * kSpeechBodyScale));
        add(frame, "bodyAngleX", deadZone(nod * 0.3f * kSpeechBodyScale));
        add(frame, "bodyAngleY", deadZone(nod * kSpeechBodyScale));
        add(frame, "bodyAngleZ", deadZone(roll * 0.8f * kSpeechBodyScale));
        frame["mouthForm"] = std::sin(m_seconds * 8.0f + kPhaseSeed * 0.01f) * clamp(m_mouthOpen, 0.0f, 0.42f);
    }

    const double touchElapsed = now - m_touchImpulseStartedAtMs;
    if (touchElapsed >= 0.0 && touchElapsed <= 900.0 && m_touchArea != TouchArea::None) {
        const float t = static_cast<float>(touchElapsed / 900.0);
        const float impulse = std::sin(kPi * t) * (1.0f - t * 0.18f) * kTouchImpulseScale;
        if (m_touchArea == TouchArea::Head) {
            add(frame, "angleY", 0.42f * impulse);
            add(frame, "angleZ", -0.24f * impulse);
            add(frame, "bodyAngleY", 0.18f * impulse);
            add(frame, "bodyAngleZ", -0.08f * impulse);
            add(frame, "shoulder", 0.10f * impulse);
            add(frame, "armLeftA", -0.16f * impulse);
            add(frame, "armRightA", -0.14f * impulse);
            add(frame, "hairAhoge", 0.18f * impulse);
        } else if (m_touchArea == TouchArea::FlickUp) {
            add(frame, "angleY", 0.56f * impulse);
            add(frame, "bodyAngleX", 0.34f * impulse);
            add(frame, "bodyAngleY", 0.22f * impulse);
        } else if (m_touchArea == TouchArea::FlickDown) {
            add(frame, "angleY", -0.42f * impulse);
            add(frame, "bodyAngleX", -0.28f * impulse);
            add(frame, "bodyAngleY", -0.20f * impulse);
        } else {
            add(frame, "angleX", 0.42f * impulse);
            add(frame, "bodyAngleX", 0.30f * impulse);
            add(frame, "bodyAngleZ", 0.14f * impulse);
            add(frame, "shoulder", 0.14f * impulse);
            add(frame, "armLeftA", -0.18f * impulse);
            add(frame, "armRightA", -0.16f * impulse);
            add(frame, "handLeft", -0.08f * impulse);
            add(frame, "handRight", 0.04f * impulse);
            add(frame, "hairAhoge", 0.08f * impulse);
        }
    }

    for (const auto& item : frame) {
        applyRole(model, item.first, item.second, dt);
    }
}

float Live2DStageDriver::clamp(float value, float minValue, float maxValue) {
    if (!std::isfinite(value)) {
        return minValue;
    }
    return std::max(minValue, std::min(maxValue, value));
}

float Live2DStageDriver::clampUnit(float value) {
    return clamp(value, 0.0f, 1.0f);
}

float Live2DStageDriver::smoothValue(float current, float target, float factor) {
    const float bounded = clamp(factor, 0.0f, 1.0f);
    return current + (target - current) * bounded;
}

double Live2DStageDriver::nowMs() {
    const auto now = std::chrono::steady_clock::now().time_since_epoch();
    return std::chrono::duration<double, std::milli>(now).count();
}

Live2DStageDriver::TouchArea Live2DStageDriver::resolveTouchArea(const std::string& hitArea) {
    std::string normalized = hitArea;
    std::transform(normalized.begin(), normalized.end(), normalized.begin(),
        [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
    if (normalized.find("head") != std::string::npos) {
        return TouchArea::Head;
    }
    if (normalized.find("flickup") != std::string::npos || normalized.find("flick_up") != std::string::npos) {
        return TouchArea::FlickUp;
    }
    if (normalized.find("flickdown") != std::string::npos || normalized.find("flick_down") != std::string::npos) {
        return TouchArea::FlickDown;
    }
    if (normalized.find("body") != std::string::npos) {
        return TouchArea::Body;
    }
    return TouchArea::Body;
}

const Live2DStageDriver::ParameterBinding* Live2DStageDriver::bindingForRole(const std::string& role) {
    for (const auto& binding : kBindings) {
        if (role == binding.role) {
            return &binding;
        }
    }
    return nullptr;
}

float Live2DStageDriver::resolveNativeValue(const ParameterBinding& binding, float normalizedValue) {
    if (binding.minValue < 0.0f && binding.maxValue > 0.0f) {
        const float center = (binding.minValue + binding.maxValue) * 0.5f;
        const float radius = (binding.maxValue - binding.minValue) * 0.5f;
        return center + radius * clamp(normalizedValue, -1.0f, 1.0f);
    }
    return binding.minValue + (binding.maxValue - binding.minValue) * clampUnit(normalizedValue);
}

float Live2DStageDriver::clampFrameValue(const std::string& role, float value) {
    const float bounded = clamp(value, -1.0f, 1.0f);
    if (role == "breath" || role.find("eyeOpen") != std::string::npos || role == "cheek") {
        return clampUnit(bounded);
    }
    if (role.find("eyeBall") != std::string::npos) {
        return clamp(bounded, -0.90f, 0.90f);
    }
    if (role.find("bodyAngle") != std::string::npos) {
        return clamp(bounded, -0.72f, 0.72f);
    }
    if (role.find("angle") != std::string::npos) {
        return clamp(bounded, -0.84f, 0.84f);
    }
    return bounded;
}

void Live2DStageDriver::applyTrackingTarget(float x, float y, float strength, bool restart) {
    const double now = nowMs();
    const float safeStrength = clamp(strength * kGazeStrengthScale, 0.2f, 1.62f);
    const float safeX = clamp(x, -1.0f, 1.0f);
    const float safeY = clamp(y, -1.0f, 1.0f);
    const bool shouldRestart = restart || !m_trackingActive;
    m_trackingActive = true;
    if (shouldRestart || m_trackingStartedAtMs <= 0.0) {
        m_trackingStartedAtMs = now;
    }
    m_trackingActiveUntilMs = now + (shouldRestart ? 12000.0 : 3200.0);
    m_releaseStartedAtMs = 0.0;
    m_releaseDurationMs = 0.0;
    m_gazeTargetX = clamp(safeX * safeStrength, -0.98f, 0.98f);
    m_gazeTargetY = clamp(safeY * safeStrength, -0.94f, 0.94f);
    m_touchStartedAtMs = now;
    m_nextIdleGazeAtMs = now + 2600.0;
}

void Live2DStageDriver::updateIdleGaze(double now) {
    if (m_trackingActive && now <= m_trackingActiveUntilMs) {
        m_nextIdleGazeAtMs = now + 900.0;
        return;
    }
    if (m_trackingActive && now > m_trackingActiveUntilMs) {
        m_trackingActive = false;
        m_trackingStartedAtMs = 0.0;
        m_releaseStartedAtMs = now;
        m_releaseDurationMs = 900.0;
        m_releaseStartX = m_gazeTargetX;
        m_releaseStartY = m_gazeTargetY;
        m_nextIdleGazeAtMs = now + 1600.0;
    }
    if (m_releaseStartedAtMs > 0.0 && m_releaseDurationMs > 0.0) {
        const double elapsed = now - m_releaseStartedAtMs;
        if (elapsed >= 0.0 && elapsed <= m_releaseDurationMs) {
            const float t = clamp(static_cast<float>(elapsed / m_releaseDurationMs), 0.0f, 1.0f);
            const float eased = 1.0f - std::pow(1.0f - t, 2.0f);
            m_gazeTargetX = m_releaseStartX * (1.0f - eased);
            m_gazeTargetY = m_releaseStartY * (1.0f - eased);
            m_nextIdleGazeAtMs = now + 700.0;
            return;
        }
        m_releaseStartedAtMs = 0.0;
        m_releaseDurationMs = 0.0;
        m_releaseStartX = 0.0f;
        m_releaseStartY = 0.0f;
        m_gazeTargetX = 0.0f;
        m_gazeTargetY = 0.0f;
    }
    if (now < m_nextIdleGazeAtMs || now - m_touchStartedAtMs < 1200.0) {
        return;
    }
    m_gazeTargetX = 0.0f;
    m_gazeTargetY = 0.0f;
    m_nextIdleGazeAtMs = now + 5200.0;
}

bool Live2DStageDriver::isTrackingActive(double now) const {
    return m_trackingActive && now <= m_trackingActiveUntilMs;
}

void Live2DStageDriver::applyRole(Live2DModel& model, const std::string& role, float targetValue,
    float deltaSeconds) {
    const ParameterBinding* binding = bindingForRole(role);
    if (!binding || !model.hasParameter(binding->parameterId)) {
        return;
    }

    const float previous = m_parameterValues[role];
    const float factor = clamp(binding->smoothing * deltaSeconds * 12.0f, 0.02f, 1.0f);
    const float next = smoothValue(previous, clampFrameValue(role, targetValue), factor);
    m_parameterValues[role] = next;
    model.setParameterValue(binding->parameterId, resolveNativeValue(*binding, next), binding->weight);
}

} // namespace nna::graphics
