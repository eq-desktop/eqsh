import QtQuick
import Quickshell
import qs.config
import qs.core.system
import qs.ui.controls.providers
import qs.ui.controls.auxiliary
import QtQuick.VectorImage
import QtQuick.Effects

NotchApplication {
    details.version: "0.1.1"
    details.appType: "media"
    details.shadowColor: "#ed6168"
    meta.height: notch.defaultHeight+10
    active: Item {
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
            color: "#ed6168"
            radius: 50
        }
    }
}
