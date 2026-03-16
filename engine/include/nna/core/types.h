#pragma once

#include <string>

namespace nna::core {

struct PADState {
    float pleasure  = 0.0f;   // [-1, 1]
    float arousal   = 0.0f;   // [-1, 1]
    float dominance = 0.0f;   // [-1, 1]
};

struct PhysiologicalState {
    float satiety   = 80.0f;  // [0, 100]
    float hydration = 90.0f;  // [0, 100]
    float energy    = 70.0f;  // [0, 100]
};

struct CharacterInfo {
    std::string name       = "Lumia";
    std::string accentColor = "#FF7AA2";
    int intelligence = 85;
    int empathy      = 95;
    int chaos        = 15;
};

struct EngineState {
    PADState pad;
    PhysiologicalState physio;
    CharacterInfo character;
    std::string currentMood = "happy";
    int interactionCount    = 0;
    float affinityDelta     = 0.0f;
    int memoryCount         = 0;
};

} // namespace nna::core
