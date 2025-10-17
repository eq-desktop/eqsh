import Quickshell
import qs.ui.controls.advanced
import qs.ui.controls.providers
import QtQuick
import QtQuick.Controls

Switch {
    id: control
    text: qsTr("Switch")

    indicator: Rectangle {
        id: bg
        implicitWidth: 48
        implicitHeight: 22
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 13
        color: control.checked ? AccentColor.color : "#20000000"
        Behavior on color { ColorAnimation { duration: 500; easing.type: Easing.InOutQuad } }

        BoxGlass {
            id: handle
            x: 0
            property bool checked: control.checked
            property bool down: control.down
            property bool animating: false
            onDownChanged: {
                if (down) {
                    scale = 1
                    animating = true
                }
            }
            onCheckedChanged: {
                if (checked) {
                    turnOnAnim.start()
                    turnOffAnim.stop()
                    handle.animating = true
                } else {
                    turnOffAnim.start()
                    turnOnAnim.stop()
                    handle.animating = true
                }
            }
            PropertyAnimation {
                id: turnOnAnim
                target: handle
                property: "x"
                from: 0
                to: bg.width - 32
                duration: 200
                easing.type: Easing.InOutQuad
                onStopped: {
                    handle.scale = 1
                    handle.animating = false
                }
            }
            PropertyAnimation {
                id: turnOffAnim
                target: handle
                property: "x"
                from: bg.width - 32
                to: 0
                duration: 200
                easing.type: Easing.InOutQuad
                onStopped: {
                    handle.scale = 1
                    handle.animating = false
                }
            }
            anchors.verticalCenter: parent.verticalCenter
            width:  animating ? 44 : 30
            height: animating ? 28 : 18
            radius: 99
            scale: 1
            transform: Translate {
                x: handle.animating ? -7 : 0
                Behavior on x { PropertyAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 3 } }
            }
            Behavior on width { PropertyAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 3 } }
            Behavior on height { PropertyAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 3 } }
            Behavior on scale { PropertyAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 3 } }
            color: animating ? "#20ffffff" : "#ffffff"
            light: animating ? "#fff" : "transparent"
            negLight: animating ? "#333" : "#fff"
            Behavior on negLight { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
            glowStrength: animating ? 1 : 0.8
        }
    }

    contentItem: CFText {
        text: control.text
        opacity: enabled ? 1.0 : 0.3
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }
}