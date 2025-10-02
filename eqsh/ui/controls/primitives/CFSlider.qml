import Quickshell
import qs.ui.controls.advanced
import QtQuick
import QtQuick.Controls

Slider {
    id: slider
    background: Rectangle {
        x: slider.leftPadding
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 8
        width: slider.availableWidth
        height: implicitHeight
        radius: 10
        color: "#20ffffff"

        Rectangle {
            width: slider.visualPosition * parent.width
            height: parent.height
            color: "#fff"
            radius: 10
        }
    }
    handle: BoxExperimental {
        x: slider.leftPadding + ((slider.visualPosition * slider.availableWidth) - (width / 2))
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width:  slider.pressed ? 35 : 0
        height: slider.pressed ? 20 : 8
        Behavior on width { PropertyAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 2 } }
        Behavior on height { PropertyAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 2 } }
        color: "#50ffffff"
        negLight: slider.pressed ? "#333" : "#fff"
        Behavior on negLight { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        radius: 10
        glowStrength: slider.pressed ? 1 : 0.8
    }
    from: 0
    to: 1
    stepSize: 1 / 100.0
}