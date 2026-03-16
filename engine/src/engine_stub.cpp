#include "nna/core/engine.h"
#include <cmath>

namespace nna::core {

NNAEngine::NNAEngine() = default;
NNAEngine::~NNAEngine() = default;

void NNAEngine::init() {
    m_state = EngineState{};
    m_state.character = CharacterInfo{"Lumia", "#FF7AA2", 85, 95, 15};
    m_state.pad = {0.6f, 0.3f, 0.4f};
    m_state.physio = {82.0f, 91.0f, 67.0f};
    m_state.currentMood = "happy";
    m_state.interactionCount = 12;
    m_state.affinityDelta = 0.3f;
    m_state.memoryCount = 5;
    m_elapsed = 0.0;
}

void NNAEngine::tick(float deltaSeconds) {
    m_elapsed += deltaSeconds;
    double t = m_elapsed;

    // Gentle sin-wave oscillation to simulate a living system
    m_state.pad.pleasure  = 0.6f  + 0.15f * static_cast<float>(std::sin(t * 0.3));
    m_state.pad.arousal   = 0.3f  + 0.1f  * static_cast<float>(std::sin(t * 0.5 + 1.0));
    m_state.pad.dominance = 0.4f  + 0.08f * static_cast<float>(std::sin(t * 0.2 + 2.0));

    m_state.physio.satiety   = 82.0f + 5.0f * static_cast<float>(std::sin(t * 0.1));
    m_state.physio.hydration = 91.0f + 3.0f * static_cast<float>(std::sin(t * 0.15 + 0.5));
    m_state.physio.energy    = 67.0f + 8.0f * static_cast<float>(std::sin(t * 0.08 + 1.5));

    // Mood based on pleasure
    if (m_state.pad.pleasure > 0.5f)
        m_state.currentMood = "happy";
    else if (m_state.pad.pleasure > 0.0f)
        m_state.currentMood = "calm";
    else
        m_state.currentMood = "sad";
}

void NNAEngine::shutdown() {
    m_elapsed = 0.0;
}

const EngineState& NNAEngine::getState() const {
    return m_state;
}

void NNAEngine::feedPet(const std::string&) {
    m_state.physio.satiety = std::min(100.0f, m_state.physio.satiety + 15.0f);
    m_state.pad.pleasure += 0.1f;
    m_state.interactionCount++;
}

void NNAEngine::giveWater() {
    m_state.physio.hydration = std::min(100.0f, m_state.physio.hydration + 10.0f);
    m_state.pad.pleasure += 0.05f;
    m_state.interactionCount++;
}

void NNAEngine::touchPet(float, float, float) {
    m_state.pad.pleasure += 0.08f;
    m_state.pad.arousal += 0.03f;
    m_state.interactionCount++;
}

void NNAEngine::sendMessage(const std::string&) {
    m_state.interactionCount++;
}

} // namespace nna::core
