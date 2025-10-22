import Quickshell
import QtQuick
import qs
import qs.config
import qs.ui.controls.providers
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Shapes
import QtQuick.VectorImage

VectorImage {
    id: vi
    property color color: "#fff"
    Behavior on color { ColorAnimation { duration: 300 }}
    property int size: 16
    property bool colorized: true
    property string icon: ""
    property bool useQIcon: false
    source: useQIcon ? Quickshell.iconPath(icon) : Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/" + icon)
    width: size
    height: size
    Layout.preferredWidth: size
    Layout.preferredHeight: size
    preferredRendererType: VectorImage.CurveRenderer
    layer.enabled: true
    layer.effect: MultiEffect {
        colorization: vi.colorized ? 1 : 0
        colorizationColor: vi.color
    }
}