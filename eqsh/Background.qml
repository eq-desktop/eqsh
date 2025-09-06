import Quickshell
import Quickshell.Wayland
import QtQuick.Effects
import QtQuick
import qs.config
import qs
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
      Rectangle {
        anchors.fill: parent
        color: "transparent"
        Text {
          visible: Config.desktopWidgets.clockEnable
          font.pixelSize: 64
          font.bold: true
          anchors {
            right: Config.desktopWidgets.clockPosition.indexOf("r") != -1 ? parent.right : undefined
            top: Config.desktopWidgets.clockPosition.indexOf("t") != -1 ? parent.top : undefined
            bottom: Config.desktopWidgets.clockPosition.indexOf("b") != -1 ? parent.bottom : undefined
            left: Config.desktopWidgets.clockPosition.indexOf("l") != -1 ? parent.left : undefined
            verticalCenter: Config.desktopWidgets.clockPosition.indexOf("v") != -1 ? parent.verticalCenter : undefined
            horizontalCenter: Config.desktopWidgets.clockPosition.indexOf("h") != -1 ? parent.horizontalCenter : undefined
            margins: Config.desktopWidgets.clockMargins
          }
          text: Time.getTime(Config.desktopWidgets.clockFormat)
          color: Config.desktopWidgets.clockColor
        }
      }
    }
  }
}
