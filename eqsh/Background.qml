import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick.Effects
import QtQuick
import qs.config
import qs.ui.components.widgets
import qs.ui.components.desktop
import qs
import qs.ui.controls.auxiliary
import qs.ui.controls.providers

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      WlrLayershell.layer: WlrLayer.Background
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
      id: panelWindow
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
        scale: Config.general.reduceMotion ? 1 : 0.9
        anchors.fill: parent
        radius: Config.general.reduceMotion ? 0 : 20
        color: Config.wallpaper.color
        Behavior on scale {
          NumberAnimation { duration: 700; easing.type: Easing.InOutQuad}
        }
        Behavior on radius {
          NumberAnimation { duration: 700; easing.type: Easing.InOutQuad}
        }
        Component.onCompleted: {
          scale = 1;
          radius = 0;
        }
        BackgroundImage {
          id: backgroundImage
          opacity: 0
          duration: 700
          fadeIn: true
          Loader {
            active: Config.wallpaper.enableShader
            sourceComponent: ShaderEffect {
              id: shader
              visible: Config.wallpaper.enableShader
              anchors.fill: parent
              property vector2d sourceResolution: Qt.vector2d(width, height)
              property vector2d resolution: Qt.vector2d(width, height)
              property real time: 0
              property variant source: backgroundImage
              FrameAnimation {
                running: true
                onTriggered: {
                  shader.time = this.elapsedTime;
                }
              }
              vertexShader: Qt.resolvedUrl(Config.wallpaper.shaderVert)
              fragmentShader: Qt.resolvedUrl(Config.wallpaper.shaderFrag)
            }
          }
        }
        Loader { active: true; anchors.fill: parent; sourceComponent: Desktop {}}
        Loader { active: Config.widgets.enable; anchors.fill: parent; sourceComponent: WidgetGrid {
          opacity: 0
          id: grid
          anchors.fill: parent
          editable: true
          scale: Runtime.locked ? 0.95 : 1
          Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad} }
          onWidgetMoved: (item) => {
            grid.save(item);
          }
          Behavior on opacity {
            NumberAnimation { duration: 700; easing.type: Easing.InOutQuad}
          }
          Component.onCompleted: {
            opacity = 1
          }
        }}
      }
    }
  }
}
