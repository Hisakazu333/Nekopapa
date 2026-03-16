#pragma once

#include "nna/export.h"
#include "nna/core/types.h"

namespace nna::core {

class NNA_EXPORT NNAEngine {
public:
    NNAEngine();
    ~NNAEngine();

    void init();
    void tick(float deltaSeconds);
    void shutdown();

    const EngineState& getState() const;

    // Interaction stubs
    void feedPet(const std::string& foodType);
    void giveWater();
    void touchPet(float x, float y, float duration);
    void sendMessage(const std::string& text);

private:
    EngineState m_state;
    double m_elapsed = 0.0;
};

} // namespace nna::core
