import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.Config
import qs.widgets.misc

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "eqsh:lock"
      id: panelWindow
      property bool islandMode: true
      required property var modelData
      property int radius: Config.screenEdges.radius
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
        bottom: true
      }
      exclusiveZone: -1

      visible: Config.screenEdges.enable

      mask: Region {}

      color: "transparent"

      ScreenCornersVisible {}
    }
  }
}