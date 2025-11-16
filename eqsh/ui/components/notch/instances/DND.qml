import QtQuick
import Quickshell
import qs.config
import qs.core.system
import qs
import qs.ui.controls.providers
import qs.ui.controls.auxiliary
import qs.ui.controls.primitives
import QtQuick.VectorImage
import QtQuick.Effects

NotchApplication {
    details.version: "0.1.2"
    meta.closeAfterMs: 2000
    onlyActive: true
    active: Item {
        CFVI {
            id: dndIcon
            size: 35
            anchors {
                left: parent.left
                leftMargin: 2
                verticalCenter: parent.verticalCenter
            }
            icon: "dnd.svg"
            color: NotificationDaemon.popupInhibited ? "#8872f8" : "#555"
        }
        Text {
            id: dndText
            anchors {
                right: parent.right
                rightMargin: 15
                verticalCenter: parent.verticalCenter
            }
            text: NotificationDaemon.popupInhibited ? Translation.tr("On") : Translation.tr("Off")
            opacity: 1
            color: NotificationDaemon.popupInhibited ? "#8872f8" : "#555"
            font.weight: 800
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 15
        }
    }
}
