import QtQuick
import qs.Config
import qs.Core.System
import qs.ui.Controls.providers
import QtQuick.VectorImage
import QtQuick.Effects

Rectangle {
    anchors.fill: parent
    color: "transparent"
    scale: 0
    opacity: 0
    Component.onCompleted: {
        scale = 1
        opacity = 1
    }
    Behavior on scale {
        NumberAnimation { duration: Config.notch.leftIconAnimDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
    }
    Behavior on opacity {
        NumberAnimation { duration: Config.notch.leftIconAnimDuration/2; easing.type: Easing.OutBack; easing.overshoot: 1 }
    }
    VectorImage {
        id: lockIcon
        width: 20
        height: 20
        preferredRendererType: VectorImage.CurveRenderer
        anchors {
            left: parent.left
            leftMargin: Math.min((notchBg.height/2)-7.5, Config.notch.radius-7.5)
            verticalCenter: parent.verticalCenter
            Behavior on leftMargin {
                NumberAnimation { duration: Config.notch.leftIconAnimDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
            }
        }
        source: "/home/enviction/eqSh/eqsh/Media/icons/notch/locked.svg"
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
