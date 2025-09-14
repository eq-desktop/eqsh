import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick.Effects
import QtQuick
import qs.Config
import qs.ui.components.widgets
import qs
import qs.ui.Controls.Auxiliary
import qs.ui.Controls.providers

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      WlrLayershell.layer: WlrLayer.Background
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

      mask: Region {}

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
              vertexShader: Config.wallpaper.shaderVert
              fragmentShader: Config.wallpaper.shaderFrag
            }
          }
        }
        WidgetGrid {
          opacity: 0
          anchors.fill: parent
          editable: false
          Behavior on opacity {
            NumberAnimation { duration: 700; easing.type: Easing.InOutQuad}
          }
          Component.onCompleted: {
            opacity = 1
          }
        }
      }
    }
  }
}
