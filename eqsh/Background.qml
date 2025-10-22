import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick.Effects
import QtQuick
import qs.config
import qs.ui.components.widgets
import qs.ui.components.desktop
import qs
import qs.ui.controls.auxiliary
import qs.ui.controls.primitives
import qs.ui.controls.providers

Scope {
  IpcHandler {
    target: "widgets"
    function editMode() {
      Runtime.widgetEditMode = !Runtime.widgetEditMode
    }
  }
  CustomShortcut {
    name: "widgets"
    description: "Enter Widget Edit Mode"
    onPressed: {
      Runtime.widgetEditMode = !Runtime.widgetEditMode
    }
  }
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panelWindow
      WlrLayershell.layer: WlrLayer.Background
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      required property var modelData
      screen: modelData

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

	    exclusiveZone: -1

      color: Config.wallpaper.color

      ClippingRectangle {
        anchors.fill: parent
        radius: Config.screenEdges.enable ? Config.screenEdges.radius : 0
        color: Config.wallpaper.color
        BackgroundImage {
          id: backgroundImage
          opacity: 0
          duration: 300
          fadeIn: true
        }
        Loader { active: Config.wallpaper.desktopEnable; anchors.fill: parent; sourceComponent: Desktop {}}
        Loader { active: Config.widgets.enable; anchors.fill: parent; sourceComponent: WidgetGrid {
          id: grid
          anchors.fill: parent
          editMode: Runtime.widgetEditMode
          screen: panelWindow.screen
          scale: Runtime.locked ? 0.95 : 1
          Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad} }
          onWidgetMoved: (item) => {
            grid.save(item);
          }
        }}
      }
    }
  }
}
