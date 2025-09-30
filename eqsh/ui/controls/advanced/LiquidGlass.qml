// Created with Qt Quick Effect Maker (version 0.44), Tue Aug 19 13:51:39 2025

import QtQuick

Item {
    id: rootItem

    // This is the main source for the effect
    property Item source: null
    property real blurMultiplier: 1
    // This property defines how much blur (radius) is applied to the shadow.
    //
    // The value ranges from 0.0 (no blur) to 1.0 (full blur). By default, the property is set to 0.0 (no change). The amount of full blur is affected by BlurHelper blurMultiplier property.
    property real innerShadowBlurAmount: 0.1
    // HorizontalOffset and verticalOffset properties define the offset for the rendered shadow compared to the InnerShadow item position.
    property real innerShadowHorizontalOffset: 1
    // HorizontalOffset and verticalOffset properties define the offset for the rendered shadow compared to the InnerShadow item position.
    property real innerShadowVerticalOffset: 1
    // This property defines the RGBA color value which is used for the shadow.
    property color innerShadowColor: Qt.rgba(1, 1, 1, 1)
    // This property defines how large part of the shadow color is strengthened near the source edges.
    //
    // The value ranges from 0.0 to 1.0. By default, the property is set to 0.0.
    property real innerShadowSpread: 1

    BlurHelper {
        id: blurHelper
        anchors.fill: parent
        property int blurMax: 64
        property real blurMultiplier: rootItem.blurMultiplier
    }
    ShaderEffect {
        readonly property alias iSource: rootItem.source
        readonly property vector3d iResolution: Qt.vector3d(width, height, 1.0)
        readonly property alias iSourceBlur1: blurHelper.blurSrc1
        readonly property alias iSourceBlur2: blurHelper.blurSrc2
        readonly property alias iSourceBlur3: blurHelper.blurSrc3
        readonly property alias iSourceBlur4: blurHelper.blurSrc4
        readonly property alias iSourceBlur5: blurHelper.blurSrc5
        readonly property alias blurMultiplier: rootItem.blurMultiplier
        readonly property alias innerShadowBlurAmount: rootItem.innerShadowBlurAmount
        readonly property alias innerShadowHorizontalOffset: rootItem.innerShadowHorizontalOffset
        readonly property alias innerShadowVerticalOffset: rootItem.innerShadowVerticalOffset
        readonly property alias innerShadowColor: rootItem.innerShadowColor
        readonly property alias innerShadowSpread: rootItem.innerShadowSpread

        vertexShader: 'liquidGlass.vert.qsb'
        fragmentShader: 'liquidGlass.frag.qsb'
        anchors.fill: parent
    }
}
