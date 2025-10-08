import QtQuick
import QtQuick.Layouts
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
    details.version: "0.1.0"
    details.appType: "media"
    meta.height: notch.defaultHeight+10
    meta.width: 300
    RowLayout {
        anchors.centerIn: parent
        Text {
            id: fileText
            color: "#fff"
            text: Translation.tr("File")
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 15
        }
        Text {
            id: editText
            color: "white"
            text: Translation.tr("Edit")
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 15
        }
        Text {
            id: viewText
            color: "white"
            text: Translation.tr("View")
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 15
        }
        Text {
            id: goText
            color: "white"
            text: Translation.tr("Go")
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 15
        }
        Text {
            id: windowText
            color: "white"
            text: Translation.tr("Window")
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 15
        }
        Text {
            id: helpText
            color: "white"
            text: Translation.tr("Help")
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 15
        }
    }
}
