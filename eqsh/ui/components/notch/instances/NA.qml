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
    id: root
    details.version: "0.1.1"
    meta.height: notch.defaultHeight+10
    meta.width: notch.defaultWidth-50
    indicative: Item {
        Text {
            text: "Indicative Mode"
            anchors {
                left: parent.left
                leftMargin: 2
                verticalCenter: parent.verticalCenter
            }
            color: "#fff"
            font.pointSize: 12
        }
    }
    active: Item {
        Text {
            text: "Active Mode"
            anchors {
                left: parent.left
                leftMargin: 2
                verticalCenter: parent.verticalCenter
            }
            color: "#fff"
            font.pointSize: 12
        }
    }
}
