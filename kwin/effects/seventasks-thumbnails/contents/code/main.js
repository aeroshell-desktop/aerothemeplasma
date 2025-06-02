/*
 *    This file is part of the KDE project.
 *
 *    SPDX-FileCopyrightText: 2012 Martin Gräßlin <mgraesslin@kde.org>
 *    SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *    SPDX-License-Identifier: GPL-2.0-or-later
 */

"use strict";

var morphingEffect = {
    duration: animationTime(300),
    loadConfig: function () {
        morphingEffect.duration = animationTime(300);
    },

    handleFrameGeometryAboutToChange: function (window) {
        var couldRetarget = false;
        if (window.fadeAnimation) {
            couldRetarget = retarget(window.fadeAnimation[0], 1.0, morphingEffect.duration);
        }

        if (!couldRetarget) {
            window.fadeAnimation = animate({
                window: window,
                duration: morphingEffect.duration,
                curve: QEasingCurve.Linear,
                animations: [{
                    type: Effect.Translation,
                    to: 1.0,
                    from: 1.0
                }]
            });
        }
    },
    handleFrameGeometryChanged: function (window, oldGeometry) {
        var newGeometry = window.geometry;

        window.setData(Effect.WindowForceBackgroundContrastRole, false);
        window.setData(Effect.WindowForceBlurRole, true);

        var couldRetarget = false;

        if (window.moveAnimation) {
            if (window.moveAnimation[0]) {
                couldRetarget = retarget(window.moveAnimation[0], {
                    value1: newGeometry.width,
                    value2: newGeometry.height
                }, morphingEffect.duration);
            }
            if (couldRetarget && window.moveAnimation[1]) {
                couldRetarget = retarget(window.moveAnimation[1], {
                    value1: newGeometry.x + newGeometry.width /2,
                    value2: newGeometry.y + newGeometry.height / 2
                }, morphingEffect.duration);
            }
        } /*else {
            oldGeometry = newGeometry;
        }*/


        if (!couldRetarget) {
            window.moveAnimation = animate({
                window: window,
                duration: morphingEffect.duration,
                curve: QEasingCurve.OutCubic,
                animations: [{
                    type: Effect.Size,
                    to: {
                        value1: newGeometry.width,
                        value2: newGeometry.height
                    },
                    from: {
                        value1: oldGeometry.width,
                        value2: oldGeometry.height
                    }
                }, {
                    type: Effect.Position,
                    to: {
                        value1: newGeometry.x + newGeometry.width / 2,
                        value2: newGeometry.y + newGeometry.height / 2
                    },
                    from: {
                        value1: oldGeometry.x + oldGeometry.width / 2,
                        value2: oldGeometry.y + oldGeometry.height / 2
                    }
                }]
            });
        }
    },

    manage: function (window) {
        if(window.caption === "seventasks-tooltip" || (window.splash && window.caption === "")) {
            window.windowFrameGeometryAboutToChange.connect(morphingEffect.handleFrameGeometryAboutToChange);
            window.windowFrameGeometryChanged.connect(morphingEffect.handleFrameGeometryChanged);
        }
    },

    init: function () {
        effect.configChanged.connect(morphingEffect.loadConfig);
        effects.windowAdded.connect(morphingEffect.manage);

        for (const window of effects.stackingOrder) {
            morphingEffect.manage(window);
        }
    }
};
morphingEffect.init();
