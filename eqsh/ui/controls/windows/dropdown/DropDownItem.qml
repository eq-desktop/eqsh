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
import qs.ui.controls.advanced
import QtQuick.Controls.Fusion
import qs.ui.controls.windows

QtObject {
  id: root
  property string name
  property string icon
  property bool   iconColorized: true
  property int    iconSize: 15
  property real   iconScale: 1
  property string kb // ⌘, ⌃, ⌥, ⇧
  property string type: "item"
  property bool disabled: false
  property var action: null
}