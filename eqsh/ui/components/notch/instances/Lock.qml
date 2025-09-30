import QtQuick
import Quickshell
import qs.config
import qs.core.system
import qs.ui.controls.providers
import qs.ui.controls.auxiliary
import QtQuick.VectorImage
import QtQuick.Effects

NotchApplication {
    details.version: "0.1.0"
    meta.width: notch.defaultWidth + 40
    meta.height: notch.defaultHeight + 20
    meta.animDuration: 1000
    VectorImage {
        id: lockIcon
        width: 20
        height: 20
        preferredRendererType: VectorImage.CurveRenderer
        anchors {
            left: parent.left
            leftMargin: 20
            verticalCenter: parent.verticalCenter
        }
        source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/notch/locked.svg")
        rotation: 0
        layer.enabled: true
        layer.effect: MultiEffect {
            anchors.fill: lockIcon
            colorization: 1
            colorizationColor: AccentColor.color
        }
    }

    Rectangle {
        id: notifCount
        anchors {
            left: lockIcon.right
            leftMargin: 10
            verticalCenter: parent.verticalCenter
            Behavior on leftMargin {
                NumberAnimation { duration: Config.notch.leftIconAnimDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
            }
        }
        width: 15
        height: 15
        color: "red"
        radius: 50
        visible: NotificationDaemon.list.length > 0
        Text {
            font.family: Fonts.sFProRounded.family
            font.pixelSize: 13
        	anchors.fill: parent
        	verticalAlignment: Text.AlignVCenter
        	horizontalAlignment: Text.AlignHCenter
        	text: NotificationDaemon.list.length
        	color: "#fff"
        }
    }
}
