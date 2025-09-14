import Quickshell
import QtQuick
import QtQuick.VectorImage
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Config
import qs
import qs.Core.Foundation
import qs.ui.Controls.Auxiliary
import QtQuick.Controls.Fusion

Button {
  id: root
  signal click()
  palette.buttonText: "#fff"
  Layout.minimumWidth: 50
  Layout.preferredHeight: 25
  Layout.maximumHeight: Config.bar.height * 1.05
  padding: 10
  background: Box {
    id: bgRect
    color: "transparent"
    radius: 20
    highlight: "transparent"
  }
  layer.enabled: true
  layer.effect: MultiEffect {
    shadowEnabled: true
    shadowBlur: 1
    shadowColor: "#000000"
  }
  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: {
      bgRect.color = "#33ffffff";
    }
    onExited: {
      bgRect.color = "transparent";
    }
    onClicked: {
      root.click()
    }
  }
}