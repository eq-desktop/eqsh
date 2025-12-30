import QtQuick
import Quickshell
import qs.config
import qs.core.system
import qs.ui.controls.providers
import qs.ui.controls.auxiliary.notch
import QtQuick.VectorImage
import QtQuick.Effects

NotchApplication {
    details.version: "Elephant-1"
    details.appType: "indicator"
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
            width: 8
            height: 8
            color: '#ff5c64'
            radius: 50
        }
    }
}
