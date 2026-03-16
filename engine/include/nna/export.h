#pragma once

#ifdef _WIN32
    #ifdef NNA_BUILDING_LIB
        #define NNA_EXPORT __declspec(dllexport)
    #else
        #define NNA_EXPORT __declspec(dllimport)
    #endif
#else
    #define NNA_EXPORT __attribute__((visibility("default")))
#endif
