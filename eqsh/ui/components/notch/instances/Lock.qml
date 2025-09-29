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
    }
    anchors.fill: parent
    opacity: 0
    Component.onCompleted: {
        notch.setSize(notch.defaultWidth + 40, notch.defaultHeight + 20)
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
            leftMargin: 20
            verticalCenter: parent.verticalCenter
        }
        source: Qt.resolvedUrl(Quickshell.shellDir + "/Media/icons/notch/locked.svg")
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
