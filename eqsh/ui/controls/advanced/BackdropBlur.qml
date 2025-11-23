import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Effects

Item {
    id: root
    property alias clipRadius: clipping.radius
    property alias blur: blureffect.blur
    property alias saturation: blureffect.saturation
    property alias contrast: blureffect.contrast
    property alias brightness: blureffect.brightness
    property alias blurMax: blureffect.blurMax
    property alias blurMultiplier: blureffect.blurMultiplier
    default property var source: undefined
    ClippingRectangle {
        id: clipping
        anchors.fill: parent
        color: "transparent"
        radius: 0
        Blur {
            id: blureffect
            anchors.fill: parent
            source: root.source ? root.source : ses
            layer.enabled: true
        }
    }
}