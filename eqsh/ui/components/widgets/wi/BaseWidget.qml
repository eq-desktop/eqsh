import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.VectorImage
import QtQuick.Effects
import qs
import qs.config
import qs.ui.controls.providers
import qs.ui.controls.advanced
import qs.ui.controls.primitives

Control {
    id: root
    anchors.fill: parent
    padding: 10
    property var screen
    property var monitor: Hyprland.monitorFor(screen)
    property real sF: Math.min(0.7777, (1+(1-monitor.scale || 1)))
    property int textSize: 16*sF
    property int textSizeM: 20*sF
    property int textSizeL: 26*sF
    property int textSizeXL: 32*sF
    property int textSizeXXL: 40*sF
    property int textSizeSL: 64*sF
    property int textSizeSSL: 86*sF
    property Component content: null
    property var widget: null
    property Component bg: BoxGlass {
        id: bg
        anchors.fill: parent
        scale: 1
        radius: 25
        rotation: 0
        gradient: LinearGradient {
            y2: bg.height
            GradientStop { position: 0.0; color: Config.general.darkMode ? "#222" : "#ffffff" }
            GradientStop { position: 1.0; color: Config.general.darkMode ? "#111" : '#ffffff' }
        }
    }

    contentItem: ClippingRectangle {
        radius: Config.widgets.radius
        color: "transparent"
        Loader {
            id: loader
            anchors.fill: parent
            sourceComponent: root.bg
        }

        Loader {
            id: contentLoader
            anchors.fill: parent
            active: true
            sourceComponent: root.content
        }
    }
}
