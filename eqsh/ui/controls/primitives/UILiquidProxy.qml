import Quickshell
import qs.ui.controls.advanced
import qs.ui.controls.providers
import QtQuick
import QtQuick.Controls

Item {
    id: root
    required property var liquid
    property real scalingFactor: liquid.scale
    property real scalingFactorX: (liquid.width-(scalingFactor*liquid.width))
    property real xTransform: (liquid.disX*5)+liquid.translateModifierX
    property real yTransform: (liquid.disY*5)+liquid.translateModifierY
    property real wTransformFactor: liquid.stretchingX ? 1+Math.abs(liquid.disX/10) : 1
    property real hTransformFactor: liquid.stretchingY ? 1+Math.abs(liquid.disY/10) : 1
    property real wTransform: liquid.width-(wTransformFactor*liquid.width)
    property real hTransform: liquid.height-(hTransformFactor*liquid.height)
    Behavior on xTransform { NumberAnimation { duration: 150; } }
    Behavior on yTransform { NumberAnimation { duration: 150; } }
    Behavior on wTransform { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }
    Behavior on hTransform { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }
    x: liquid.x + (scalingFactorX/2) + xTransform + (wTransform/2)
    y: liquid.y + yTransform + (hTransform/2)
    width: liquid.width - scalingFactorX - wTransform
    height: liquid.height - hTransform
}