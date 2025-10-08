import QtQuick
import Quickshell
import qs.config
import qs.core.system
import qs
import qs.ui.controls.providers
import qs.ui.controls.auxiliary
import QtQuick.VectorImage
import QtQuick.Effects

NotchApplication {
    details.version: "0.1.1"
    meta.height: notch.defaultHeight+5
    meta.width: notch.defaultWidth-50
    meta.closeAfterMs: 1000
    onlyActive: true
    active: Item {
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
            source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/dnd.svg")
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
            text: NotificationDaemon.popupInhibited ? Translation.tr("On") : Translation.tr("Off")
            opacity: 0.7
            color: "#8872f8"
            font.weight: 800
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 15
        }
    }
}
