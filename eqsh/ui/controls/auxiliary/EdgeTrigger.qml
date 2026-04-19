import Quickshell
import QtQuick
import QtQuick.VectorImage
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland
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
  property int duration: 200

  property bool active: false
  property bool debug: false
  property bool newMethod: false

  Variants {
    model: Quickshell.screens

    PanelWindow {
      WlrLayershell.layer: layer
      required property var modelData
      screen: modelData
      color: root.debug ? "#20ff0000" : "transparent"

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
        interval: root.active ? 0 : duration
        onTriggered: {
          root.hovered(modelData)
        }
      }

      MouseArea {
        id: marea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
          let x = marea.mouseX
          let y = marea.mouseY
          Logger.d("EdgeTrigger", "Mouse:", x, y)//, mouse.accepted, mouse.button, mouse.buttons, mouse.flags, mouse.modifiers, mouse.wasHeld, mouse.x, mouse.y)
          if (y != 1 && !root.active && root.newMethod) return
          timer.start()
        }
        onExited: {
          root.exited(modelData);
          timer.stop();
        }
        onClicked: root.clicked(modelData);
      }
    }
  }
}