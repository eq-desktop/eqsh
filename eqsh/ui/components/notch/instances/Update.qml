import QtQuick
import Quickshell
import qs.config
import qs
import qs.core.system
import qs.ui.controls.providers
import qs.ui.controls.auxiliary
import qs.ui.components.panel
import QtQuick.VectorImage
import QtQuick.Controls
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

NotchApplication {
    id: root
    details.version: "0.1.1"
    details.appType: "info"
    meta.height: 60
    meta.width: 300
    meta.closeAfterMs: 1000
    noMode: true

    indicative: Item {
        VectorImage {
            id: icon
            width: 16
            height: 16
            preferredRendererType: VectorImage.CurveRenderer
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/notch/info.svg")
            rotation: 0
            layer.enabled: true
            layer.effect: MultiEffect {
                anchors.fill: icon
                colorization: 1
                colorizationColor: '#ff2f00'
            }
        }
        Text {
            id: text
            anchors {
                left: icon.right
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            color: '#ff7b5d'
            text: "Update Available"
            font.family: Fonts.sFProMonoRegular.family
            font.pixelSize: 13
        }
    }
}
