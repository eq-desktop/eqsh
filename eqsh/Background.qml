import Quickshell
import Quickshell.Wayland
import QtQuick.Effects
import QtQuick
import qs.config
import qs.components.misc

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
	  Image {
        id: backgroundImage
        source: Config.wallpaper.path
        fillMode: Image.PreserveAspectCrop
        opacity: 0
        anchors.fill: parent

        Behavior on opacity {
          NumberAnimation { duration: 700; easing.type: Easing.InOutQuad}
        }

        Component.onCompleted: {
          opacity = 1;
        }
        ShaderEffect {
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
  }
}
