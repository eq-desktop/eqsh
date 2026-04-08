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
  Component.onCompleted: {
    Ipc.mixin("eqdesktop.widgets", "toggleEditMode", () => {
      Runtime.widgetEditMode = !Runtime.widgetEditMode
    })
    Ipc.mixin("eqdesktop.wallpaper", "change", (path) => {
      Config.wallpaper.path = path
    })
  }
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panelWindow
      WlrLayershell.layer: WlrLayer.Background
      WlrLayershell.namespace: "eqsh"
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      required property var modelData
      screen: modelData

      focusable: true

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
        radius: 0
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
          wallpaper: backgroundImage
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
