import Quickshell
import QtQuick
import QtQuick.VectorImage
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs
import qs.core.foundation
import qs.ui.controls.auxiliary
import QtQuick.Controls.Fusion

PanelWindow {
  id: panelWindow
  WlrLayershell.layer: WlrLayer.Overlay
  screen: screen
  WlrLayershell.namespace: "eqsh:blur"

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