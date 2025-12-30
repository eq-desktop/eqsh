import QtQuick
import Quickshell
import qs.config
import qs
import qs.core.system
import qs.ui.controls.providers
import qs.ui.controls.auxiliary.notch
import qs.ui.components.panel
import QtQuick.VectorImage
import QtQuick.Controls
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

NotchApplication {
    id: root
    details.version: "Elephant-1"
    meta.width: 200
    meta.xOffset: -85
    meta.closeAfterMs: -1
    onlyActive: true

    active: Item {
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
        }
        Text {
            id: text
            anchors {
                left: icon.right
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            color: '#ffffff'
            text: "Update Available"
            font.family: Fonts.sFProMonoRegular.family
            font.pixelSize: 13
        }
    }
}
