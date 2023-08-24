/*
MIT License

Copyright (c) 2020 Pierre-Yves Siret

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import QtQuick 2.15
import QtQml 2.15

Behavior {
    id: root

    property QtObject fadeTarget: targetProperty.object
    property string fadeProperty: "opacity"
    property var fadeProperties: [fadeProperty]
    property var exitValue: 0
    property var enterValue: exitValue
    property int fadeDuration: 300
    property string easingType: "Quad"
    property bool delayWhile: false
    property bool sequential: false
    onDelayWhileChanged: {
        if (!delayWhile)
            sequentialAnimation.startExitAnimation();
    }

    readonly property Component shaderEffectSourceWrapperComponent: Item {
        property alias shaderEffectSource: shaderEffectSource
        property alias sourceItem: shaderEffectSource.sourceItem
        parent: sourceItem.parent
        x: sourceItem.x
        y: sourceItem.y
        ShaderEffectSource {
            id: shaderEffectSource
            transformOrigin: sourceItem.transformOrigin
            hideSource: true
            live: false
            width: sourceItem.width
            height: sourceItem.height
        }
    }

    readonly property Component defaultExitAnimation: NumberAnimation {
        properties: root.fadeProperties.join(',')
        duration: root.fadeDuration
        to: root.exitValue
        easing.type: root.easingType === "Linear" ? Easing.Linear : Easing["In"+root.easingType]
    }
    property Component exitAnimation: defaultExitAnimation

    // bind SES properties tu function provided by user: {rotation: (t) => () => t.progress * 180, opacity: (p) => 1 - p)}

    readonly property Component defaultEnterAnimation: NumberAnimation {
        properties: root.fadeProperties.join(',')
        duration: root.fadeDuration
        from: root.enterValue
        to: root.fadeTarget[root.fadeProperties[0]]
        easing.type: root.easingType === "Linear" ? Easing.Linear : Easing["Out"+root.easingType]
    }
    property Component enterAnimation: defaultEnterAnimation

    SequentialAnimation {
        id: sequentialAnimation
        signal startEnterAnimation()
        signal startExitAnimation()
        ScriptAction {
            script: {
                const exitItem = shaderEffectSourceWrapperComponent.createObject(null, { sourceItem: root.fadeTarget });
                const exitShaderEffectSource = exitItem.shaderEffectSource;
                if (exitAnimation === root.defaultExitAnimation)
                    root.fadeProperties.forEach(p => exitShaderEffectSource[p] = root.fadeTarget[p]);
                exitShaderEffectSource.width = root.fadeTarget.width;
                exitShaderEffectSource.height = root.fadeTarget.height;
                const exitAnimationInstance = exitAnimation.createObject(root, { target: exitItem.shaderEffectSource });

                sequentialAnimation.startExitAnimation.connect(exitAnimationInstance.start);
                if (root.sequential)
                    exitAnimationInstance.finished.connect(sequentialAnimation.startEnterAnimation);
                else
                    exitAnimationInstance.started.connect(sequentialAnimation.startEnterAnimation);

                exitAnimationInstance.finished.connect(() => {
                                                           exitItem.destroy();
                                                           exitAnimationInstance.destroy();
                                                       });
            }
        }
        PauseAnimation {
            duration: 5 // figure out how to wait on a signal in an animation (for ShaderEffectSource update or Image loading when Behaviour on source)
        }
        PropertyAction {}
        ScriptAction {
            script: {
                const enterItem = shaderEffectSourceWrapperComponent.createObject(null, { sourceItem: root.fadeTarget });
                const enterShaderEffectSource = enterItem.shaderEffectSource;
                if (enterAnimation === root.defaultEnterAnimation)
                    root.fadeProperties.forEach(p => enterShaderEffectSource[p] = root.enterValue);
                enterShaderEffectSource.live = true;
                const enterAnimationInstance = enterAnimation.createObject(root, { target: enterItem.shaderEffectSource });

                sequentialAnimation.startEnterAnimation.connect(enterAnimationInstance.start);

                enterAnimationInstance.finished.connect(() => {
                                                            enterItem.destroy();
                                                            enterAnimationInstance.destroy();
                                                        });

                if (!root.delayWhile)
                    sequentialAnimation.startExitAnimation();
            }
        }
    }
}
