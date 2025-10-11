import Quickshell
import qs.ui.controls.advanced
import qs.ui.controls.providers
import QtQuick
import QtQuick.Controls

Button {
    id: button
    height: 30
    property bool primary: false
    property string color: "#40000000"
    background: BoxExperimental {
        anchors.fill: parent
        color: button.primary ? AccentColor.color : button.color
        glowStrength: 0.5
        highlightEnabled: !button.primary
    }
    palette.buttonText: "white"
    Behavior on scale { NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 1 }}
    Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }}
}