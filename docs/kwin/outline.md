# Outline 

## Details about the outline window

The reflection texture is loaded from the standard SMOD directory, and it is rendered using [ShaderEffectSource](https://doc.qt.io/qt-6/qml-qtquick-shadereffectsource.html). This workaround is done because the outline that appears is not actually representative of the actual outline window belonging to the compositor. Instead, the visible outline is rendered using QML, hence the need for workarounds like this. The issues with this are:

1. The reflection texture in general isn't consistent with the AeroGlassBlur
2. Performance is suboptimal and results in choppy animations and freezes in some cases
3. The underlying C++ code does not provide a way to expose the visible outline's window geometry, or ways to set a custom blur region to the underlying window, making it impossible to approach this in any other way for now.
