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
  property string customAppName: ""
  property bool   visible: true
  property bool   shown: false
  property bool   appInFullscreen: false
  property bool   forceHide: Config.bar.autohide
  property bool   inFullscreen: shown ? forceHide : appInFullscreen || forceHide

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panelWindow
      WlrLayershell.layer: WlrLayer.Overlay
      required property var modelData
      screen: modelData
      WlrLayershell.namespace: "eqsh-blur"

      property string applicationName: Config.bar.defaultAppName

      anchors {
        top: true
        left: true
        right: true
      }

      margins {
        top: Config.bar.hideOnLock ? (root.visible ? (root.inFullscreen ? -Config.bar.height : 0) : -Config.bar.height) : (root.inFullscreen ? -Config.bar.height : 0)
      }

      Behavior on margins.top {
        NumberAnimation { duration: Config.bar.hideDuration; easing.type: Easing.OutQuad }
      }

      implicitHeight: Config.bar.height

      color: root.appInFullscreen ? Config.bar.fullscreenColor : Config.bar.color

      visible: Config.bar.enable

      Barblock {}

      RowLayout {
        spacing: -6
        anchors {
          left: parent.left
          verticalCenter: parent.verticalCenter
          leftMargin: 0
        }

        BButton {VectorImage {
          id: lBAppMenu
          source: "../../assets/svgs/icon.svg"
          width: 18
          height: 18
          preferredRendererType: VectorImage.CurveRenderer
          anchors.centerIn: parent
        }}

        BButton {
          text: customAppName != "" ? customAppName : (applicationName == "" ? Config.bar.defaultAppName : applicationName)
          font.weight: 600
        }

        BButton {
          text: "File"
        }

        BButton {
          text: "Edit"
        }

        BButton {
          text: "View"
        }

        BButton {
          text: "Go"
        }

        BButton {
          text: "Window"
        }

        BButton {
          text: "Help"
        }
      }

      RowLayout {
        spacing: -2
        anchors {
          right: parent.right
          verticalCenter: parent.verticalCenter
          rightMargin: 10
        }

        SystemTray {}

        BButton{Battery {}}

        BButton {Wifi {}}

        BButton {VectorImage {
          id: rBBluetooth
          source: "../../assets/svgs/bluetooth-clear.svg"
          width: 24
          height: 24
          preferredRendererType: VectorImage.CurveRenderer
          anchors.centerIn: parent
        }}

        BButton {VectorImage {
          id: rBSearch
          source: "../../assets/svgs/search.svg"
          width: 20
          height: 20
          Layout.preferredWidth: 20
          Layout.preferredHeight: 20
          preferredRendererType: VectorImage.CurveRenderer
          anchors.centerIn: parent
        }}

        BButton {
          VectorImage {
            id: rBControlCenter
            source: "../../assets/svgs/control-center.svg"
            width: 24
            height: 24
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            preferredRendererType: VectorImage.CurveRenderer
            anchors.centerIn: parent
          }
          onClick: controlCenter.open()
          ControlCenter {
            id: controlCenter
          }
        }

        BButton{
          text: Time.time
        }
      }
      Connections {
        target: Hyprland
        function onRawEvent(event) {
          let eventName = event.name;
          switch (eventName) {
            case "activewindow":
            case "closewindow": {
              applicationName = AppName.getAppName(event.data.split(",")[0]);
              break;
            }
            case "fullscreen": {
              root.appInFullscreen = event.data == "1";
              break;
            }
          }
        }
      }
    }
  }
}