import QtQuick
import Quickshell
import qs.config
import qs.core.system
import qs.ui.controls.providers
import qs.ui.controls.auxiliary
import QtQuick.VectorImage
import QtQuick.Effects

NotchApplication {
    details.version: "0.1.2"
    details.appType: "media"
    noMode: true
    meta.height: notch.defaultHeight+10
    indicative: Item {
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
            color: '#e13039'
            radius: 50
        }
    }
}
