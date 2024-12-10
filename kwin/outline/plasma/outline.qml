/*
    SPDX-FileCopyrightText: 2014 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2017 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2024 Souris

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtCore
import QtQuick
import QtQuick.Window
import org.kde.kwin
import org.kde.ksvg 1.0 as KSvg
import org.kde.kirigami 2 as Kirigami
import Qt5Compat.GraphicalEffects
import QtQuick.Controls //2.15

/*
 * NOTE
 *
 * Disable "Fading Popups" in Desktop Effects to fix the outline appearing on top of the window
 * when fading out.
 *
 * NOTE
 *
 * outline.geometry is the geometry provided by the C++ code. It is independant of the QML.
 * outline.visualParentGeometry is the geometry of the dragged window when it first creates the outline
 * outline.unifiedGeometry is the union of outline.geometry and outline.visualParentGeometry.
 */

Window
{
    id: window

    /*
     * Duration of the frame animation.
     */
    readonly property int animationDuration: Kirigami.Units.longDuration

    /*
     * Interpolation mode for the frame animation.
     */
    readonly property int animationInterp: Easing.Linear

    /*
     * Whether the frame is animated.
     */
    property bool useAnimation: true

    /*
     * Padding around the frame.
     */
    readonly property int framepadding: 8

    /*
     * Controls whether the frame should animate if animation is enabled.
     */
    property bool shouldAnimate: false

    property bool useConsistentVisualParent: true

    property int fullWidth: unifiedSize.width
    property int fullHeight: unifiedSize.height

    /*
     * Show debugging info.
     */
    property bool enableDebugging: false

    flags: Qt.BypassWindowManagerHint | Qt.FramelessWindowHint
    color: "transparent"

    x: 0
    y: 0
    width: fullWidth
    height: fullHeight

    visible: outline.active

    title: "aerothemeplasma-windowframe-special"

    property rect unifiedSize: {
        var w = 0;
        var h = 0;
        for(var i = 0; i < Qt.application.screens.length; i++) {
            var s = Qt.application.screens[i];
            var tw = s.width + s.virtualX;
            var th = s.height + s.virtualY;
            if(tw > w) w = tw;
            if(th > h) h = th;
        }
        return Qt.rect(0,0,w,h);
    }

    onVisibleChanged:
    {
        if (visible) {
            if (outline.visualParentGeometry.width > 0 && outline.visualParentGeometry.height > 0) {
                window.shouldAnimate = false
                // move our frame to the visual parent geometry
                var visualRect = outline.visualParentGeometry;

                var rect = Qt.rect(Math.max(0, visualRect.x + visualRect.width / 2), visualRect.y, 40, 40);
                if(visualRect.x <= 0 && visualRect.y !== 0) {
                    rect.x = 0;
                }
                frame.setGeometry(rect)
                window.shouldAnimate = true
                // and then animate it nicely to its destination
                frame.setGeometry(outline.geometry)
            } else {
                // no visual parent? just move it to its destination right away
                window.shouldAnimate = false
                frame.setGeometry(outline.geometry)
                window.shouldAnimate = true
            }
        }
    }

    Connections
    {
        target: outline

        // when unified geometry changes, this means our window position changed and any
        // animation will potentially be offset and/or cut off, skip the animation in this case
        function onUnifiedGeometryChanged()
        {
            if (window.visible)
            {
                //window.shouldAnimate = false
                if (window.useAnimation) window.shouldAnimate = true
                frame.setGeometry(outline.geometry)

            }
        }
    }

    Image
    {
        id: reflection

        anchors.fill: parent
        property string path: "/smod/kwin/reflections.png"
        source:       StandardPaths.writableLocation(StandardPaths.GenericDataLocation) + "/smod/kwin/reflections.png" //"~/.local/share/smod/reflections.png"
        sourceSize:   Qt.size(fullWidth, fullHeight)
        smooth:       true
        visible:      false
        onStatusChanged: {
            if(status == 3) {
                reflection.source = "/usr/share" + path
            } // Error
        }
    }

    Rectangle
    {
        id: reflectionmask

        anchors.fill: reflection
        color: "transparent"
        visible: false

        Rectangle
        {
            color: "black"
            x:      frame.x
            y:      frame.y
            width:  frame.width
            height: frame.height
            radius: 7
        }

    }
    OpacityMask
    {
        anchors.fill: reflection
        source: reflection
        maskSource: reflectionmask
    }
    KSvg.FrameSvgItem
    {
        id: frameshadow

        property real actualMarginLeft:   frameshadow.margins.left   - 16
        property real actualMarginRight:  frameshadow.margins.right  - 9
        property real actualMarginTop:    frameshadow.margins.top    - 17
        property real actualMarginBottom: frameshadow.margins.bottom - 17

        imagePath:      Qt.resolvedUrl("./res/outline-frame.svgz")
        prefix:         "shadow"
        enabledBorders: KSvg.FrameSvgItem.AllBorders

        x:      frame.x      - frameshadow.actualMarginLeft
        y:      frame.y      - frameshadow.actualMarginTop
        width:  frame.width  + frameshadow.actualMarginLeft + frameshadow.actualMarginRight
        height: frame.height + frameshadow.actualMarginTop  + frameshadow.actualMarginBottom
    }

    KSvg.FrameSvgItem
    {
        id: frame

        function setGeometry(geometry)
        {
            frame.intx      = geometry.x      + window.framepadding;
            frame.inty      = geometry.y      + window.framepadding;
            frame.intwidth  = geometry.width  - window.framepadding * 2;
            frame.intheight = geometry.height - window.framepadding * 2;
            /*x      = geometry.x      + window.framepadding
            y      = geometry.y      + window.framepadding
            width  = geometry.width  - window.framepadding * 2
            height = geometry.height - window.framepadding * 2*/
        }

        function setGeometryXYWH(gx, gy, gw, gh)
        {
            frame.intx      = gx + window.framepadding
            frame.inty      = gy + window.framepadding
            frame.intwidth  = gw - window.framepadding * 2
            frame.intheight = gh - window.framepadding * 2
        }

        imagePath:      Qt.resolvedUrl("./res/outline-frame.svgz")
        enabledBorders: KSvg.FrameSvgItem.AllBorders

        x:      frame.intx
        y:      frame.inty
        width:  frame.intwidth
        height: frame.intheight

        property int intx:      0
        property int inty:      0
        property int intwidth:  0
        property int intheight: 0

        Behavior on intx
        {
            NumberAnimation { duration: window.animationDuration; easing.type: window.animationInterp; }
            enabled: window.shouldAnimate
        }
        Behavior on inty
        {
            NumberAnimation { duration: window.animationDuration; easing.type: window.animationInterp; }
            enabled: window.shouldAnimate
        }
        Behavior on intwidth
        {
            NumberAnimation { duration: window.animationDuration; easing.type: window.animationInterp; }
            enabled: window.shouldAnimate
        }
        Behavior on intheight
        {
            NumberAnimation { duration: window.animationDuration; easing.type: window.animationInterp; }
            enabled: window.shouldAnimate
        }
    }

    /*
     * Debugging
     */
    Rectangle
    {
        id: "debuginfo"

        color:   "#eeffffff"
        x:       outline.geometry.x + window.framepadding + frame.margins.left
        y:       outline.geometry.y + window.framepadding + frame.margins.top
        width:   400
        height:  400
        radius:  4
        enabled: enableDebugging
        visible: enableDebugging

        Label
        {
            x: 25
            y: 15

            font.family: "Monospace"
            font.pointSize: 10
            color: "black"

            text:
                "Screen.width:                           <b>" + Screen.width + "</b> <br>" +
                "Screen.height:                          <b>" + Screen.height + "</b> <br><br>" +
                "outline.geometry.x:                     <b>" + outline.geometry.x + "</b> <br>" +
                "outline.geometry.y:                     <b>" + outline.geometry.y + "</b> <br>" +
                "outline.geometry.width:                 <b>" + outline.geometry.width + "</b> <br>" +
                "outline.geometry.height:                <b>" + outline.geometry.height + "</b> <br><br>" +
                "outline.unifiedGeometry.x:              <b>" + outline.unifiedGeometry.x + "</b> <br>" +
                "outline.unifiedGeometry.y:              <b>" + outline.unifiedGeometry.y + "</b> <br>" +
                "outline.unifiedGeometry.width:          <b>" + outline.unifiedGeometry.width + "</b> <br>" +
                "outline.unifiedGeometry.height:         <b>" + outline.unifiedGeometry.height + "</b> <br><br>" +
                "outline.visualParentGeometry.x:         <b>" + outline.visualParentGeometry.x + "</b> <br>" +
                "outline.visualParentGeometry.y:         <b>" + outline.visualParentGeometry.y + "</b> <br>" +
                "outline.visualParentGeometry.width:     <b>" + outline.visualParentGeometry.width + "</b> <br>" +
                "outline.visualParentGeometry.height:    <b>" + outline.visualParentGeometry.height + "</b> <br><br>" +
                "frame.x:                                <b>" + frame.x + "</b> <br>" +
                "frame.y:                                <b>" + frame.y + "</b> <br>" +
                "frame.width:                            <b>" + frame.width + "</b> <br>" +
                "frame.height:                           <b>" + frame.height + "</b>"
        }
    }

    Rectangle
    {
        id: "visualparent"

        color: "red"
        radius: 20
        opacity: 0.5

        x:      outline.visualParentGeometry.x
        y:      outline.visualParentGeometry.y
        width:  outline.visualParentGeometry.width
        height: outline.visualParentGeometry.height

        enabled: enableDebugging
        visible: enableDebugging
    }

}
