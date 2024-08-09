/*
 *    KWin - the KDE window manager
 *    This file is part of the KDE project.
 *
 *    SPDX-FileCopyrightText: 2015 Thomas Lübking <thomas.luebking@gmail.com>
 *
 *    SPDX-License-Identifier: GPL-2.0-or-later
 */
/*global effect, effects, animate, animationTime, Effect, QEasingCurve */

"use strict";

var badBadWindowsEffect = {
    duration: animationTime(450),
    showingDesktop: false,
    loadConfig: function () {
        badBadWindowsEffect.duration = animationTime(450);
    },
    setShowingDesktop: function (showing) {
        badBadWindowsEffect.showingDesktop = showing;

    },
    offToCorners: function (showing, frozenTime) {
        if (typeof frozenTime === "undefined") {
            frozenTime = -1;
        }
        var stackingOrder = effects.stackingOrder;
        var screenGeo = effects.virtualScreenGeometry;
        var xOffset = screenGeo.width / 16;
        var yOffset = screenGeo.height / 16;

            for (var i = 0; i < stackingOrder.length; ++i) {
                var w = stackingOrder[i];

                if (!w.managed && w.windowClass == "kwin_x11 kwin" && w.caption == "" && !w.hasDecoration) continue;
                if (!w.hiddenByShowDesktop && !w.normalWindow) {
                    continue;
                }

                // ignore invisible windows and such that do not have to be restored
                if (!w.visible) {
                    if (w.offToCornerId) {
                        // if it was visible when the effect was activated delete its animation data
                        cancel(w.offToCornerId);
                        delete w.offToCornerId;
                        delete w.apertureCorner;
                    }
                    continue;
                }

                // Don't touch docks
                if (w.dock) {
                    continue;
                }

                //console.log("Before: " + JSON.stringify(w));

                if(showing) {
                    if (!w.offToCornerId || !freezeInTime(w.offToCornerId, frozenTime)) {

                        w.offToCornerId = set({
                            window: w,
                            duration: badBadWindowsEffect.duration,
                            curve: QEasingCurve.InOutQuad,
                            //delay: 10,
                            animations: [{
                                type: Effect.Opacity,
                                to: 0.0,
                                frozenTime: frozenTime

                            }]
                        });
                        //console.log("script");
                    }
                } else {
                    if (!w.visible) {
                        cancel(w.offToCornerId);
                        delete w.offToCornerId;
                        delete w.apertureCorner;
                        // This if the window was invisible and has become visible in the meantime
                    } else if (!w.offToCornerId || !redirect(w.offToCornerId, Effect.Backward) || !freezeInTime(w.offToCornerId, frozenTime)) {
                        /*animate({
                            window: w,
                            duration: badBadWindowsEffect.duration,
                            curve: QEasingCurve.Linear,
                            animations: [{
                                type: Effect.Opacity,
                                from: 0.0
                            }]
                        });*/
                    }
                }
            }
    },
    animationEnded: function (w, a, meta) {
        // After the animation that closes the effect, reset all the parameters
        if (!badBadWindowsEffect.showingDesktop && w.offToCornerId != null) {
            cancel(w.offToCornerId);
            delete w.offToCornerId;
            delete w.apertureCorner;
        }
    },
    realtimeScreenEdgeCallback: function (border, deltaProgress, effectScreen) {
        if (!deltaProgress || !effectScreen) {
            badBadWindowsEffect.offToCorners(badBadWindowsEffect.showingDesktop, -1);
            return;
        }
        let time = 0;

        switch (border) {
            case KWin.ElectricTop:
            case KWin.ElectricBottom:
                time = Math.min(1, (Math.abs(deltaProgress.height) / (effectScreen.geometry.height / 2))) * badBadWindowsEffect.duration;
                break;
            case KWin.ElectricLeft:
            case KWin.ElectricRight:
                time = Math.min(1, (Math.abs(deltaProgress.width) / (effectScreen.geometry.width / 2))) * badBadWindowsEffect.duration;
                break;
            default:
                return;
        }
        if (badBadWindowsEffect.showingDesktop) {
            time = badBadWindowsEffect.duration - time;
        }

        badBadWindowsEffect.offToCorners(true, time)
    },
    init: function () {
        badBadWindowsEffect.loadConfig();
        effects.showingDesktopChanged.connect(badBadWindowsEffect.setShowingDesktop);
        effects.showingDesktopChanged.connect(badBadWindowsEffect.offToCorners);
        effect.animationEnded.connect(badBadWindowsEffect.animationEnded);

        //let edges = effect.touchEdgesForAction("show-desktop");

        /*for (let i in edges) {
            let edge = parseInt(edges[i]);
            registerRealtimeScreenEdge(edge, badBadWindowsEffect.realtimeScreenEdgeCallback);
        }*/
    }
};

badBadWindowsEffect.init();
