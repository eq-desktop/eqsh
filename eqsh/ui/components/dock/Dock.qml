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

Scope {
  id: root

  // === Dock Einstellungen (anpassbar) ===
  property real magnifyRadius: 150       // Wirkungsradius der Vergrößerung in px
  property real maxScale: 1.5           // Maximale Skalierung (z.B. 2.2 = 220%)
  property real lift: 2                // Wie weit das Icon beim Vergrößern nach oben gehoben wird

  component DockItem: Button {
    width: 56
    height: 56
    implicitHeight: 56
    implicitWidth: 56

    background: Rectangle {
      anchors.fill: parent
      color: "#ffffff11"
      radius: 12
    }

    // Distanz zum Maus-X im Dock
    readonly property real centreXInDock: parent.x + x + width/2
    readonly property real distance: Math.abs(centreXInDock - dock.mouseX)
    text: dock.mouseX
    readonly property real ratio: (dock.mouseInside ? Math.max(0, 1 - (distance / root.magnifyRadius)) : 0)

    // Zielwerte automatisch gebunden
    property real targetScale: 1 + (root.maxScale - 1) * ratio
    property real liftY: -(targetScale - 1) * root.lift

    transform: [
      Scale {
        id: scaleT
        origin.x: width/2
        origin.y: height
        xScale: targetScale
        yScale: targetScale
      },
      Translate {
        y: liftY
      }
    ]

    onClicked: {
      if (text === "kitty") Hyprland.dispatch("exec kitty")
      if (text === "nautilus") Hyprland.dispatch("exec nautilus")
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

      implicitHeight: 90
      implicitWidth: dock.implicitWidth
      exclusiveZone: -1
      color: "transparent"
      visible: true

      Item {
        id: dock
        implicitWidth: 700
        anchors.fill: parent

        Rectangle {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: parent.bottom
          color: "#222222cc"
          implicitWidth: 420
          implicitHeight: 72
          radius: 20
          anchors.bottomMargin: 6
          z: 0
        }

        // Public state für Maus
        property real mouseX: 0
        property bool mouseInside: false

        RowLayout {
          id: dockRow
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 14
          spacing: 8

          DockItem {}
          DockItem {}
          DockItem {}
          DockItem {}
          DockItem {}
        }
      }
      MouseArea {
        id: dockMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
          dock.mouseInside = true
          dock.mouseX = mouseX
        }
        onPositionChanged: dock.mouseX = mouseX
        onExited: {
          dock.mouseInside = false
          dock.mouseX = mouseX
        }
      }
    }
  }
}
