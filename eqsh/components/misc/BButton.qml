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

Button {
  palette.buttonText: "#fff"
  Layout.minimumWidth: 50
  Layout.preferredHeight: 25
  padding: 10
  background: Box {
    id: bgRect
    color: "transparent"
    radius: 20
    highlight: "transparent"
    weakHighlight: "transparent"
    borderColor: "transparent"
  }
  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: {
      bgRect.color = "#22555555";
      bgRect.borderColor = Config.bar.glintButtons ? "#ffaaaaaa" : "transparent";
      bgRect.highlight = Config.bar.glintButtons ? 'rgba(255, 255, 255, 0.5)' : "transparent";
      bgRect.weakHighlight = Config.bar.glintButtons ? 'rgba(255, 255, 255, 0.3)' : "transparent";
    }
    onExited: {
      bgRect.color = "transparent";
      bgRect.borderColor = "transparent";
      bgRect.highlight = "transparent";
      bgRect.weakHighlight = "transparent";
    }
  }
}