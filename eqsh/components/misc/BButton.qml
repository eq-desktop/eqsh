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
  id: root
  signal click()
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
  }
  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: {
      bgRect.color = "#22ffffff";
    }
    onExited: {
      bgRect.color = "transparent";
    }
    onClicked: {
      root.click()
    }
  }
}