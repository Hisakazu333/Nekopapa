/*
 * Project: OpenNeko Engine (NNA Core)
 * Core Architecture by Nekonano-Aether
 * Copyright (c) 2026 Nekonano-Aether. All rights reserved.
 * SPDX-License-Identifier: MIT
 */

#include "nna_window_chrome.h"

#include <QWindow>

#import <AppKit/AppKit.h>

namespace {

NSWindow *nativeWindowFor(QWindow *window)
{
    if (!window)
        return nil;

    NSView *nativeView = reinterpret_cast<NSView *>(window->winId());
    if (!nativeView)
        return nil;

    return nativeView.window;
}

} // namespace

namespace NNAWindowChrome {

void applyMainWindowChrome(QWindow *window)
{
    window->setFlag(Qt::ExpandedClientAreaHint, true);
    window->setFlag(Qt::NoTitleBarBackgroundHint, true);

    NSWindow *nativeWindow = nativeWindowFor(window);
    if (!nativeWindow)
        return;

    nativeWindow.styleMask = nativeWindow.styleMask | NSWindowStyleMaskFullSizeContentView;
    nativeWindow.title = @"";
    nativeWindow.titleVisibility = NSWindowTitleHidden;
    nativeWindow.titlebarAppearsTransparent = YES;
    nativeWindow.movableByWindowBackground = YES;
    nativeWindow.backgroundColor = [NSColor colorWithCalibratedRed:0.961 green:0.961 blue:0.969 alpha:1.0];

#if defined(MAC_OS_VERSION_11_0)
    if (@available(macOS 11.0, *)) {
        nativeWindow.titlebarSeparatorStyle = NSTitlebarSeparatorStyleNone;
    }
#endif
}

qreal trafficLightsLeadingMargin(QWindow *window)
{
    NSWindow *nativeWindow = nativeWindowFor(window);
    if (!nativeWindow)
        return 80;

    NSView *contentView = nativeWindow.contentView;
    if (!contentView)
        return 80;

    const NSWindowButton buttonTypes[] = {
        NSWindowCloseButton,
        NSWindowMiniaturizeButton,
        NSWindowZoomButton
    };

    CGFloat maxX = 0;
    for (NSWindowButton buttonType : buttonTypes) {
        NSButton *button = [nativeWindow standardWindowButton:buttonType];
        if (!button || !button.superview)
            continue;

        const NSRect frame = [button.superview convertRect:button.frame toView:contentView];
        maxX = MAX(maxX, NSMaxX(frame));
    }

    if (maxX <= 0)
        return 80;

    return maxX + 12.0;
}

} // namespace NNAWindowChrome
