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

  signal hovered(ShellScreen monitor)
  signal exited(ShellScreen monitor)
  signal clicked(ShellScreen monitor)

  property string position
  property int height
  property int width
  property int layer: WlrLayer.Overlay
  property int topMargin: 0
  property int rightMargin: 0
  property int bottomMargin: 0
  property int leftMargin: 0

  property bool active: false

  Variants {
    model: Quickshell.screens

    PanelWindow {
      WlrLayershell.layer: layer
      required property var modelData
      screen: modelData
      color: "transparent"

      function hasPosition(position) {
        return root.position.indexOf(position) != -1;
      }

      exclusiveZone: -1

      anchors {
        top: hasPosition("t")
        right: hasPosition("r")
        bottom: hasPosition("b")
        left: hasPosition("l")
      }

      margins {
        top: topMargin
        right: rightMargin
        bottom: bottomMargin
        left: leftMargin
      }

      implicitHeight: root.height
      implicitWidth: root.width

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered(modelData);
        onExited: root.exited(modelData);
        onClicked: root.clicked(modelData);
      }
    }
  }
}