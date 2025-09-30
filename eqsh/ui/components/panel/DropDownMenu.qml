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
import qs.ui.controls.windows

Scope {
  id: root
  property int x: 0
  property int y: 0
  property var text: null
  function open() {
    pop.opened = true
  }
  Pop {
    id: pop
    content: Item {
      Rectangle {
        x: root.x
        y: root.y
        width: 100
        height: 100
        color: "#f00"
      }
    }
  }
}