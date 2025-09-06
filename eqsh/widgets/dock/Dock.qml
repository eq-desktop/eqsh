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

  component DockItem: Button {
    width: 50
    height: 50
    implicitHeight: 50
    implicitWidth: 50
    scale: 1
    signal hover()
    signal unhover()
    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onEntered: {
        hover()
      }
      onExited: {
        unhover()
      }
    }
    Behavior on width {
      PropertyAnimation {
        duration: 100
        easing.type: Easing.InSine
      }
    }
    Behavior on height {
      PropertyAnimation {
        duration: 100
        easing.type: Easing.InSine
      }
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      WlrLayershell.layer: WlrLayer.Overlay
      required property var modelData
      screen: modelData

      property string applicationName: "eqSh"

      anchors {
        bottom: true
      }

      margins {
        bottom: 5
      }

      implicitHeight: 75
      implicitWidth: dock.implicitWidth
      exclusiveZone: -1
      color: "transparent"
      visible: true
      Item {
        id: dock
        implicitWidth: dockRow.implicitWidth
        anchors.fill: parent
        Rectangle {
          anchors.centerIn: parent.centerIn
          color: "#111"
          implicitWidth: 200
          implicitHeight: 50
        }
        RowLayout {
          id: dockRow
          anchors.fill: parent
          spacing: 5
          DockItem {
            text: "kitty"
            onHover: {
              width = 75
              height = 75
            }
            onUnhover: {
              width = 50
              height = 50
            }
            onClicked: {
              Hyprland.dispatch("exec kitty")
            }
          }
          DockItem {
            text: "nautilus"
            onClicked: {
              Hyprland.dispatch("exec nautilus")
            }
          }
        }
      }
    }
  }
}