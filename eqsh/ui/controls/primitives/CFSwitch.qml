import Quickshell
import qs.ui.controls.advanced
import qs.ui.controls.providers
import QtQuick
import QtQuick.Controls

Switch {
    id: control
    text: ""

    property int switchHeight: 22
    property int switchWidth: 54

    indicator: Rectangle {
        id: bg
        implicitWidth: control.switchWidth
        implicitHeight: control.switchHeight
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: Infinity
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
                from: 2
                to: bg.width - (handle.width-3)
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
                from: bg.width - (handle.width-3)
                to: 2
                duration: 200
                easing.type: Easing.InOutQuad
                onStopped: {
                    handle.scale = 1
                    handle.animating = false
                }
            }
            anchors.verticalCenter: parent.verticalCenter
            width:  animating ? (control.switchWidth / 2) + 14 : (control.switchWidth / 2) + 8
            height: animating ? control.switchHeight + 6 : control.switchHeight - 4
            radius: Infinity
            scale: 1
            transform: Translate {
                x: handle.animating ? -9 : 0
                Behavior on x { PropertyAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 3 } }
            }
            Behavior on width { PropertyAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 3 } }
            Behavior on height { PropertyAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 3 } }
            Behavior on scale { PropertyAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 3 } }
            color: animating ? "#20ffffff" : "#ffffff"
            light: animating ? "#fff" : "transparent"
            negLight: animating ? "#333" : "#fff"
            Behavior on negLight { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
            rimStrength: animating ? 1 : 0.8
        }
    }

    contentItem: CFText {
        text: control.text
        opacity: enabled ? 1.0 : 0.3
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }
}