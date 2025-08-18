import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.config
import qs.components.misc

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      WlrLayershell.layer: WlrLayer.Overlay
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