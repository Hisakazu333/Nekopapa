/*
 * Project: OpenNeko Engine (NNA Core)
 * Core Architecture by Nekonano-Aether
 * Copyright (c) 2026 Nekonano-Aether. All rights reserved.
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include <QtGlobal>

class QWindow;

namespace NNAWindowChrome {
void applyMainWindowChrome(QWindow *window);
qreal trafficLightsLeadingMargin(QWindow *window);
}
