import QtQuick
import Quickshell
import qs.Config
import qs.Core.System
import qs.ui.Controls.providers
import QtQuick.VectorImage
import QtQuick.Effects

Item {
    property var details: QtObject {
        property string version: "0.1.0"
        property string shadowColor: "#ed6168"
    }
    anchors.fill: parent
    opacity: 0
    Component.onCompleted: {
        notch.setSize(notch.defaultWidth + 0, notch.defaultHeight + 10)
        opacity = 1
    }
    Behavior on opacity {
        NumberAnimation { duration: Config.notch.leftIconAnimDuration/2; easing.type: Easing.OutBack; easing.overshoot: 1 }
    }
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
