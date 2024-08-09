/*
    KWin - the KDE window manager
    This file is part of the KDE project.

    SPDX-FileCopyrightText: 2007 Lubos Lunak <l.lunak@kde.org>
    SPDX-FileCopyrightText: 2013 Martin Gräßlin <mgraesslin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

"use strict";

var loginEffect = {
    duration: animationTime(300),
    isFadeToBlack: false,
    loadConfig: function () {
        loginEffect.isFadeToBlack = effect.readConfig("FadeToBlack", false);
    },
    isLoginSplash: function (window) {
        return window.windowClass === "ksplashqml ksplashqml";
    },
    isLockScreen: function (window) {
        return window.windowClass === "kscreenlocker_greet kscreenlocker_greet";
    },
    fadeOut: function (window) {
        animate({
            window: window,
            duration: loginEffect.duration,
            type: Effect.Opacity,
            from: 1.0,
            to: 0.0
        });
    },
    fadeToBlack: function (window) {
        animate({
            window: window,
            duration: loginEffect.duration / 2,
            animations: [{
                type: Effect.Brightness,
                from: 1.0,
                to: 0.0
            }, {
                type: Effect.Opacity,
                from: 1.0,
                to: 0.0,
                delay: loginEffect.duration / 2
            }, {
                // TODO: is there a better way to keep brightness constant?
                type: Effect.Brightness,
                from: 0.0,
                to: 0.0,
                delay: loginEffect.duration / 2
            }]
        });
    },
    closed: function (window) {
        if (!(loginEffect.isLoginSplash(window) || loginEffect.isLockScreen(window))) {
            return;
        }
        if (loginEffect.isFadeToBlack === true && !loginEffect.isLockScreen(window)) {
            loginEffect.fadeToBlack(window);
        } else {
            loginEffect.fadeOut(window);
        }
    },
    init: function () {
        effect.configChanged.connect(loginEffect.loadConfig);
        effects.windowClosed.connect(loginEffect.closed);
        loginEffect.loadConfig();
    }
};
loginEffect.init();
