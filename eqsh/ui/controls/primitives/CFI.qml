import Quickshell
import QtQuick
import QtQuick.Effects
import qs
import qs.config
import qs.ui.controls.providers

Image {
    id: vi
    property color color: "#fff"
    Behavior on color { ColorAnimation { duration: 300 }}
    property int size: 16
    property bool colorized: true
    property string icon: ""
    property bool useQIcon: false
    source: useQIcon ? Quickshell.iconPath(icon) : Qt.resolvedUrl(Quickshell.shellDir + "/media/pngs/" + icon)
    width: size
    height: size
    smooth: true
    mipmap: true
    layer.enabled: colorized
    layer.samples: 4
    layer.effect: MultiEffect {
        colorization: vi.colorized ? 1 : 0
        colorizationColor: vi.color
    }
}