import QtQuick
import Quickshell
import qs.Config
import qs.Core.System
import qs.ui.Controls.providers
import qs.ui.Controls.Auxiliary
import QtQuick.VectorImage
import QtQuick.Effects

NotchApplication {
    details.version: "0.1.0"
    details.shadowColor: "#ed6168"
    meta.height: notch.defaultHeight+10
    Rectangle {
        id: recordingIndicator
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
            Behavior on leftMargin {
                NumberAnimation { duration: Config.notch.leftIconAnimDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
            }
        }
        width: 12
        height: 12
        color: "#ed6168"
        radius: 50
    }
}
