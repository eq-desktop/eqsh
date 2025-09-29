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
    meta.height: notch.defaultHeight+10
    meta.width: notch.defaultWidth-50
    meta.closeAfterMs: 1000
    VectorImage {
        id: dndIcon
        width: 35
        height: 35
        preferredRendererType: VectorImage.CurveRenderer
        anchors {
            left: parent.left
            leftMargin: 2
            verticalCenter: parent.verticalCenter
        }
        source: Qt.resolvedUrl(Quickshell.shellDir + "/Media/icons/dnd.svg")
        layer.enabled: true
        layer.effect: MultiEffect {
            anchors.fill: dndIcon
            colorization: 1
            colorizationColor: "#8872f8"
        }
    }
    Text {
        id: dndText
        anchors {
            right: parent.right
            rightMargin: 15
            verticalCenter: parent.verticalCenter
        }
        text: NotificationDaemon.popupInhibited ? "On" : "Off"
        opacity: 0.7
        color: "#8872f8"
        font.weight: 800
        font.family: Fonts.sFProDisplayRegular.family
        font.pixelSize: 15
    }
}
