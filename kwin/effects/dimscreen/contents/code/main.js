/*
    This file is part of the KDE project.

    SPDX-FileCopyrightText: 2018 Vlad Zahorodnii <vlad.zahorodnii@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

"use strict";

var authenticationAgents = [
    "kdesu kdesu",
    "kdesudo kdesudo",
    "pinentry pinentry",
    "polkit-kde-authentication-agent-1 polkit-kde-authentication-agent-1",
    "polkit-kde-manager polkit-kde-manager",

    // On Wayland, the resource name is filename of executable. It's empty for
    // authentication agents because KWayland can't get their executable paths.
    " org.kde.kdesu",
    " org.kde.polkit-kde-authentication-agent-1"
];

function activeAuthenticationAgent() {
    var activeWindow = effects.activeWindow;
    if (!activeWindow) {
        return null;
    }

    if (authenticationAgents.indexOf(activeWindow.windowClass) == -1) {
        return null;
    }

    return activeWindow;
}

var dimScreenEffect = {
    loadConfig: function () {
        dimScreenEffect.duration = animationTime(0);
        dimScreenEffect.brightness = 0.67;
        dimScreenEffect.saturation = 0.67;
    },
    startAnimation: function (window) {
        if (!window.visible) {
            return;
        }
        if (window.popupWindow) {
            return;
        }
        if (!window.managed) {
            return;
        }
        if (window.dimAnimation) {
            if (redirect(window.dimAnimation, Effect.Forward)) {
                return;
            }
            cancel(window.dimAnimation);
        }
        window.dimAnimation = set({
            window: window,
            curve: QEasingCurve.InOutSine,
            duration: dimScreenEffect.duration,
            keepAlive: false,
            animations: [
                {
                    type: Effect.Saturation,
                    to: dimScreenEffect.saturation
                },
                {
                    type: Effect.Brightness,
                    to: dimScreenEffect.brightness
                }
            ]
        });
    },
    startAnimationSmooth: function (window) {
        dimScreenEffect.startAnimation(window);
    },
    startAnimationInstant: function (window) {
        dimScreenEffect.startAnimation(window);

        if (window.dimAnimation) {
            complete(window.dimAnimation);
        }
    },
    cancelAnimationSmooth: function (window) {
        if (!window.dimAnimation) {
            return;
        }
        if (redirect(window.dimAnimation, Effect.Backward)) {
            return;
        }
        cancel(window.dimAnimation);
        delete window.dimAnimation;
    },
    cancelAnimationInstant: function (window) {
        if (window.dimAnimation) {
            cancel(window.dimAnimation);
            delete window.dimAnimation;
        }
    },
    dimScreen: function (agent, animationFunc, cancelFunc) {
        // Keep track of currently active authentication agent so we don't have
        // to re-scan the stacking order in brightenScreen each time when some
        // window is activated.
        dimScreenEffect.authenticationAgent = agent;

        var windows = effects.stackingOrder;
        for (var i = 0; i < windows.length; ++i) {
            var window = windows[i];
            if (window == agent) {
                // The agent might have been dimmed before (because there are
                // several authentication agents on the screen), so we need to
                // cancel previous animations for it if there are any.
                cancelFunc(agent);
                continue;
            }
            animationFunc(window);
        }
    },
    dimScreenSmooth: function (agent) {
        dimScreenEffect.dimScreen(
            agent,
            dimScreenEffect.startAnimationSmooth,
            dimScreenEffect.cancelAnimationSmooth
        );
    },
    dimScreenInstant: function (agent) {
        dimScreenEffect.dimScreen(
            agent,
            dimScreenEffect.startAnimationInstant,
            dimScreenEffect.cancelAnimationInstant
        );
    },
    brightenScreen: function (cancelFunc) {
        if (!dimScreenEffect.authenticationAgent) {
            return;
        }
        dimScreenEffect.authenticationAgent = null;

        var windows = effects.stackingOrder;
        for (var i = 0; i < windows.length; ++i) {
            cancelFunc(windows[i]);
        }
    },
    brightenScreenSmooth: function () {
        dimScreenEffect.brightenScreen(dimScreenEffect.cancelAnimationSmooth);
    },
    brightenScreenInstant: function () {
        dimScreenEffect.brightenScreen(dimScreenEffect.cancelAnimationInstant);
    },
    slotWindowActivated: function (window) {
        if (!window) {
            return;
        }
        if (authenticationAgents.indexOf(window.windowClass) != -1) {
            dimScreenEffect.dimScreenSmooth(window);
        } else {
            dimScreenEffect.brightenScreenSmooth();
        }
    },
    slotWindowAdded: function (window) {
        window.minimizedChanged.connect(() => {
            if (window.minimized) {
                dimScreenEffect.cancelAnimationInstant(window);
            } else {
                dimScreenEffect.restartAnimation(window);
            }
        });

        // Don't dim authentication agents that just opened.
        var agent = activeAuthenticationAgent();
        if (agent == window) {
            return;
        }

        // If a window appeared while the screen is dimmed, dim the window too.
        if (agent) {
            dimScreenEffect.startAnimationInstant(window);
        }
    },
    slotActiveFullScreenEffectChanged: function () {
        // If some full screen effect has been activated, for example the desktop
        // cube effect, then brighten screen back. We need to do that because the
        // full screen effect can dim windows on its own.
        if (effects.hasActiveFullScreenEffect) {
            dimScreenEffect.brightenScreenSmooth();
            return;
        }

        // If user left the full screen effect, try to dim screen back.
        var agent = activeAuthenticationAgent();
        if (agent) {
            dimScreenEffect.dimScreenSmooth(agent);
        }
    },
    slotDesktopChanged: function () {
        // If there is an active full screen effect, then try smoothly dim/brighten
        // the screen. Keep in mind that in order for this to work properly, this
        // effect has to come after the full screen effect in the effect chain,
        // otherwise this slot will be invoked before the full screen effect can mark
        // itself as a full screen effect.
        if (effects.hasActiveFullScreenEffect) {
            return;
        }

        // Try to brighten windows on the previous virtual desktop.
        dimScreenEffect.brightenScreenInstant();

        // Try to dim windows on the current virtual desktop.
        var agent = activeAuthenticationAgent();
        if (agent) {
            dimScreenEffect.dimScreenInstant(agent);
        }
    },
    restartAnimation: function (window) {
        if (activeAuthenticationAgent()) {
            dimScreenEffect.startAnimationInstant(window);
        }
    },
    init: function () {
        dimScreenEffect.loadConfig();

        effect.configChanged.connect(dimScreenEffect.loadConfig);
        effects.windowActivated.connect(dimScreenEffect.slotWindowActivated);
        effects.windowAdded.connect(dimScreenEffect.slotWindowAdded);
        effects.activeFullScreenEffectChanged.connect(
            dimScreenEffect.slotActiveFullScreenEffectChanged);
        effects.desktopChanged.connect(dimScreenEffect.slotDesktopChanged);

        for (const window of effects.stackingOrder) {
            dimScreenEffect.slotWindowAdded(window);
        }
    }
};

dimScreenEffect.init();
