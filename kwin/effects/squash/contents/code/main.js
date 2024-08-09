/*
    This file is part of the KDE project.

    SPDX-FileCopyrightText: 2018 Vlad Zahorodnii <vlad.zahorodnii@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

"use strict";

var squashEffect = { // 300 ms
    duration: animationTime(250),
    loadConfig: function () {
        squashEffect.duration = animationTime(250);
    },
    slotWindowMinimized: function (window) {
        if (effects.hasActiveFullScreenEffect) {
            return;
        }

        // If the window doesn't have an icon in the task manager,
        // don't animate it.
        var iconRect = window.iconGeometry;
        if (iconRect.width == 0 || iconRect.height == 0) {
            return;
        }

        if (window.unminimizeAnimation) {
            if (redirect(window.unminimizeAnimation, Effect.Backward)) {
                return;
            }
            cancel(window.unminimizeAnimation);
            delete window.unminimizeAnimation;
        }

        if (window.minimizeAnimation) {
            if (redirect(window.minimizeAnimation, Effect.Forward)) {
                return;
            }
            cancel(window.minimizeAnimation);
        }

        var windowRect = window.geometry;

        window.minimizeAnimation = animate({
            window: window,
            curve: QEasingCurve.Linear,
            duration: squashEffect.duration*1.1,
            animations: [
                {
                    type: Effect.Size,
                    from: {
                        value1: windowRect.width,
                        value2: windowRect.height
                    },
                    to: {
                        value1: iconRect.width,
                        value2: iconRect.height
                    }
                },
                {
                    type: Effect.Translation,
                    from: {
                        value1: 0.0,
                        value2: 0.0
                    },
                    to: {
                        value1: iconRect.x - windowRect.x -
                            (windowRect.width - iconRect.width) / 2,
                        value2: iconRect.y - windowRect.y -
                            (windowRect.height - iconRect.height) / 2,
                    }
                },
                {
                    type: Effect.Opacity,
                    from: 0.9,
                    to: 0.0
                },
                /*{
                    type: Effect.Rotation,
                    meta: {
                        axis: 1
                    },
                    from: 0,
                    to: 0.262
                },
                {
                    type: Effect.Rotation,
                    meta: {
                        axis: 2
                    },
                    from: 0,
                    to: 0.262
                }*/

            ]
        });
    },
    slotWindowUnminimized: function (window) {
        if (effects.hasActiveFullScreenEffect) {
            return;
        }

        // If the window doesn't have an icon in the task manager,
        // don't animate it.
        var iconRect = window.iconGeometry;
        if (iconRect.width == 0 || iconRect.height == 0) {
            return;
        }

        if (window.minimizeAnimation) {
            if (redirect(window.minimizeAnimation, Effect.Backward)) {
                return;
            }
            cancel(window.minimizeAnimation);
            delete window.minimizeAnimation;
        }

        if (window.unminimizeAnimation) {
            if (redirect(window.unminimizeAnimation, Effect.Forward)) {
                return;
            }
            cancel(window.unminimizeAnimation);
        }

        window.setData(Effect.WindowForceBlurRole, true);

        var windowRect = window.geometry;

        window.unminimizeAnimation = animate({
            window: window,
            curve: QEasingCurve.Linear,
            duration: squashEffect.duration,
            animations: [

                /*{
                    type: Effect.Rotation,
                    axis: 0,
                    sourceAnchor: 0,
                    targetAnchor: 1,
                    from: 1,
                    to: 0.5
                },*/
                {
                    type: Effect.Size,
                    from: {
                        value1: iconRect.width,
                        value2: iconRect.height
                    },
                    to: {
                        value1: windowRect.width,
                        value2: windowRect.height
                    }
                },
                {
                    type: Effect.Translation,
                    from: {
                        value1: iconRect.x - windowRect.x -
                            (windowRect.width - iconRect.width) / 2,
                        value2: iconRect.y - windowRect.y -
                            (windowRect.height - iconRect.height) / 2,
                    },
                    to: {
                        value1: 0.0,
                        value2: 0.0
                    }
                },
                {
                    type: Effect.Opacity,
                    from: 0.0,
                    to: 1.0
                }

            ]
        });
    },
    slotWindowAdded: function (window) {
        window.minimizedChanged.connect(() => {
            if (window.minimized) {
                squashEffect.slotWindowMinimized(window);
            } else {
                squashEffect.slotWindowUnminimized(window);
            }
        });
    },
    init: function () {
        effect.configChanged.connect(squashEffect.loadConfig);

        effects.windowAdded.connect(squashEffect.slotWindowAdded);
        for (const window of effects.stackingOrder) {
            squashEffect.slotWindowAdded(window);
        }
    }
};

squashEffect.init();
