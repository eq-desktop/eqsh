import Quickshell
import QtQuick
import QtQuick.VectorImage
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs
import qs.utils
import qs.components.misc
import QtQuick.Controls.Fusion

Scope {
  id: root
  property string customAppName: ""
  property bool   visible: true
  property bool   shown: false
  property bool   appInFullscreen: false
  property bool   forceHide: Config.bar.autohide
  property bool   inFullscreen: shown ? forceHide : appInFullscreen || forceHide

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panelWindow
      WlrLayershell.layer: WlrLayer.Overlay
      required property var modelData
      screen: modelData
      WlrLayershell.namespace: "eqsh-blur"

      property string applicationName: Config.bar.defaultAppName

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: Config.bar.height

      color: "transparent"
      mask: Region {}

      visible: Config.bar.enable
    }
  }
}