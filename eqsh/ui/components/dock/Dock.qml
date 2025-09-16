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

  property real magnifyRadius: 106
  property real maxScale: 1.5
  property real lift: 20

  component DockItem: Button {
    id: app
    width: 56
    height: 56
    implicitHeight: 56
    implicitWidth: 56

    background: Rectangle {
      anchors.fill: parent
      color: "#ffffff11"
      radius: 12
    }

    readonly property real centreXInDock: parent.x + x + width/2
    readonly property real distance: Math.abs(centreXInDock - dock.mouseX)
    property string appName: ""
    text: appName
    readonly property real ratio: (dock.mouseInside ? Math.max(0, 1 - (distance / root.magnifyRadius)) : 0)

    property real targetScale: 1 + (root.maxScale - 1) * ratio
    property real liftY: -ratio * root.lift

    Behavior on targetScale {
      NumberAnimation {
        duration: 50
      }
    }

    Behavior on liftY {
      NumberAnimation {
        duration: 50
      }
    }

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
      if (app.appName === "kitty") Hyprland.dispatch("exec kitty")
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

      implicitHeight: 120
      implicitWidth: dock.implicitWidth
      exclusiveZone: -1
      color: "transparent"
      visible: true

      Item {
        id: dock
        implicitWidth: 700
        anchors.fill: parent

        Rectangle {
          id: dockBackground
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.bottom: parent.bottom
          color: "#222222cc"
          implicitWidth: 420
          implicitHeight: 72
          radius: 20
          anchors.bottomMargin: 6
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

          DockItem { text: "kitty" }
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
        propagateComposedEvents: true
        onClicked: (mouse)=> {
          mouse.accepted = false
        }
      }
    }
  }
}
