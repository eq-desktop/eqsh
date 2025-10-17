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
        implicitHeight: 4
        width: slider.availableWidth
        height: implicitHeight
        radius: 10
        color: "#30000000"

        Rectangle {
            width: slider.visualPosition * parent.width
            height: parent.height
            color: "#fff"
            radius: 10
        }
    }
    handle: BoxGlass {
        x: slider.leftPadding + Math.min(slider.availableWidth - width, Math.max(0, (slider.visualPosition * (slider.availableWidth - (width)))))
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width:  slider.pressed ? 30 : 25
        height: slider.pressed ? 20 : 15
        Behavior on width { PropertyAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 2 } }
        Behavior on height { PropertyAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 2 } }
        color: slider.pressed ? "#20ffffff" : "#ffffff"
        light: slider.pressed ? "#fff" : "transparent"
        negLight: slider.pressed ? "#333" : "#fff"
        Behavior on negLight { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        radius: 10
        glowStrength: slider.pressed ? 1 : 0.8
    }
    from: 0
    to: 1
    stepSize: 1 / 100.0
}