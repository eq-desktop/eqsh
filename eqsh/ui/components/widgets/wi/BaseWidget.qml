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
import qs.services
import qs.config
import qs.ui.controls.providers
import qs.ui.controls.advanced
import qs.ui.controls.primitives
import qs.ui.common

Control {
    id: root
    anchors.fill: parent
    padding: 10
    property var wallpaper
    property var grid
    property var screen
    property var monitor: {
        if (CompositorService.isHyprland) 
            return Hyprland.monitorFor(screen)
        else if (CompositorService.isNiri)
            return NiriService.monitorFor(screen)
        return false
    }
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
    property bool isOpened: true
    property Component bg: BoxGlass {
        id: bg
        anchors.fill: parent
        anchors.margins: 1
        scale: 1
        radius: 25
        rotation: 0
        light: "#50ffffff"
        color: Config.general.darkMode ? "#222" : "#eee"
    }

    contentItem: ClippingRectangle {
        anchors.fill: parent
        radius: Config.widgets.radius
        color: "transparent"
        Loader {
            id: loader
            anchors.fill: parent
            active: root.isOpened
            sourceComponent: root.bg
        }
    }
}
