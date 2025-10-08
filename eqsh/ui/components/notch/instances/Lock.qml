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
    meta.width: notch.defaultWidth + 40
    meta.height: notch.defaultHeight + 20
    meta.animDuration: 1000
    noMode: true
    indicative: Item {
        VectorImage {
            id: lockIcon
            width: 16
            height: 16
            preferredRendererType: VectorImage.CurveRenderer
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/lock.svg")
            rotation: 0
            layer.enabled: true
            layer.effect: MultiEffect {
                anchors.fill: lockIcon
                colorization: 1
                colorizationColor: "#cfcfcf"
            }
        }
    }
}
