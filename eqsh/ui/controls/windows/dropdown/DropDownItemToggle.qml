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

DropDownItem {
  id: root
  property bool enabled: false
  property string icon: enabled ? Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/check.svg") : ""
}