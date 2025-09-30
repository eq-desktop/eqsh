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

      Timer {
        id: timer
        running: false
        interval: root.active ? 0 : 200
        onTriggered: {
          root.hovered(modelData)
        }
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: timer.start();
        onExited: {
          root.exited(modelData);
          timer.stop();
        }
        onClicked: root.clicked(modelData);
      }
    }
  }
}