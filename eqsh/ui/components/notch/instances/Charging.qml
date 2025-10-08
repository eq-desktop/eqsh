import QtQuick
import Quickshell
import qs.config
import qs
import qs.core.system
import qs.ui.controls.providers
import qs.ui.controls.auxiliary
import qs.ui.components.panel
import QtQuick.VectorImage
import QtQuick.Effects

NotchApplication {
    details.version: "0.1.1"
    meta.height: notch.defaultHeight+10
    meta.width: 300
    meta.closeAfterMs: 2000
    onlyActive: true
    active: Item {
        Battery {
            id: battery
            batteryMode: "bubble"
            chargeColor: "#5bf9a5"
            borderColor: "#286e48"
            allowZap: false
            anchors {
                right: parent.right
                rightMargin: 30
                verticalCenter: parent.verticalCenter
                centerIn: undefined
            }
        }
        Text {
            id: percentageText
            anchors {
                right: battery.left
                rightMargin: 20
                verticalCenter: parent.verticalCenter
            }
            color: "#5bf9a5"
            text: Math.round(battery.batPercentage)*100+"%"
            opacity: 1
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 12
        }
        Text {
            id: chargingText
            anchors {
                left: parent.left
                leftMargin: 15
                verticalCenter: parent.verticalCenter
            }
            color: "white"
            text: Translation.tr("Charging")
            opacity: 1
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 15
        }
    }
}
