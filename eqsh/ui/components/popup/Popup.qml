import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io
import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.VectorImage
import qs.config
import qs
import qs.ui.controls.auxiliary
import qs.ui.controls.providers

Scope {
  id: root
  property var popups: []
  property var currentPopup: null
  property bool showing: false
  signal showPopup(var popup)

  function openPopup(iconPath, title, description, timeout, important) {
    let popup = {
      iconPath: iconPath,
      title: title,
      description: description,
      important: important,
      timeout: (timeout > 0 ? timeout : 3000)
    }
    popups.push(popup)
    if (!showing) showNextPopup()
  }

  function showNextPopup() {
    if (popups.length === 0) {
      showing = false
      return
    }
    showing = true
    currentPopup = popups.shift()
    // broadcast to all PanelWindow instances; each will start its own animation.
    root.showPopup(currentPopup)
  }

  // Called by the first PanelWindow that finishes its animation.
  function _onPopupFinished() {
    if (!showing) return
    showing = false
    showNextPopup()
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panelWindow
      required property var modelData
      screen: modelData
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "eqsh:lock"

      anchors.top: true
      margins.top: (Config.notch.islandMode ? Config.notch.margin : 0)
      implicitWidth: Config.notch.minWidth*2
      implicitHeight: 100 + (Config.notch.margin*2) + (Runtime.notchHeight) + 25 // 25 is for bouncing box
      exclusiveZone: -1
      color: "transparent"

      mask: Region {}

      // local popup copy for this window
      property var localPopup: null

      // The visual content that will be animated
      Item {
        id: popupContent
        anchors.fill: parent

        property int blur: 0
        property real opacityV: 0
        property real opacityV2: 0

        SequentialAnimation {
          id: popupAnim
          running: false
          onFinished: root._onPopupFinished()

          NumberAnimation {
            target: popupContent
            property: "opacityV2"
            from: 0
            to: 1
            duration: 125
          }

          // --- POP IN ---
          ParallelAnimation {
            NumberAnimation {
              target: popupBg
              property: "height"
              from: (Runtime.notchHeight)
              to: 100
              duration: 500
              easing.type: Easing.OutBack
            }
            NumberAnimation {
              target: popupBg
              property: "width"
              from: (Config.notch.minWidth) - 40
              to: (Config.notch.minWidth*2) - 40
              duration: 500
              easing.type: Easing.OutBack
            }

            NumberAnimation {
              target: popupBg
              property: "anchors.topMargin"
              from: Config.notch.islandMode ? Config.notch.margin : 0
              to: Config.notch.margin+(Runtime.notchHeight)
              duration: 300
              easing.type: Easing.OutBack
            }
            NumberAnimation {
              target: popupContent
              property: "opacityV"
              from: 0
              to: 1
              duration: 500
            }
            NumberAnimation {
              target: popupContent
              property: "blur"
              from: 1
              to: 0
              duration: 200
            }
          }

          // --- HOLD ---
          PauseAnimation { duration: localPopup ? localPopup.timeout : 2000 }

          // --- POP OUT ---
          ParallelAnimation {
            NumberAnimation {
              target: popupBg
              property: "anchors.topMargin"
              from: Config.notch.margin+(Runtime.notchHeight)
              to: Config.notch.islandMode ? Config.notch.margin : 0
              duration: 500
              easing.type: Easing.InBack
            }

            NumberAnimation {
              target: popupBg
              property: "width"
              from: (Config.notch.minWidth*2) - 40
              to: (Config.notch.minWidth) - 40
              duration: 500
              easing.type: Easing.InBack
            }

            NumberAnimation {
              target: popupBg
              property: "height"
              from: 100
              to: (Runtime.notchHeight)
              duration: 500
              easing.type: Easing.InBack
            }
            NumberAnimation {
              target: popupContent
              property: "opacityV"
              from: 1
              to: 0
              duration: 500
            }
            NumberAnimation {
              target: popupContent
              property: "blur"
              from: 0
              to: 1
              duration: 500
            }
          }
          NumberAnimation {
            target: popupContent
            property: "opacityV2"
            from: 1
            to: 0
            duration: 250
          }
        }


        Rectangle {
          id: popupBg
          anchors {
            top: parent.top
            topMargin: 0
            horizontalCenter: parent.horizontalCenter
          }
          SequentialAnimation {
            alwaysRunToEnd: true
            running: root.showing && localPopup ? localPopup.important : false
            loops: -1
            NumberAnimation { target: popupBg; property: "rotation"; to: -3; duration: 240; easing.type: Easing.InOutQuad }
            NumberAnimation { target: popupBg; property: "rotation"; to: 3; duration: 240; easing.type: Easing.InOutQuad }
            NumberAnimation { target: popupBg; property: "rotation"; to: -1; duration: 180; easing.type: Easing.InOutQuad }
            NumberAnimation { target: popupBg; property: "rotation"; to: 1; duration: 180; easing.type: Easing.InOutQuad }
            NumberAnimation { target: popupBg; property: "rotation"; to: 0; duration: 150; easing.type: Easing.InOutQuad }
          }
          width: Config.notch.minWidth-40
          height: Config.notch.height
          radius: 25
          opacity: popupContent.opacityV2
          clip: true
          color: Config.notch.backgroundColor

          ClippingRectangle {
            id: popupNotiContent
            color: "transparent"
            anchors.fill: parent
            layer.enabled: true
            layer.effect: MultiEffect {
              anchors.fill: popupNotiContent
              blurEnabled: true
              blur: popupContent.blur
              blurMax: 64
              Behavior on blur {
                NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
              }
            }
            SequentialAnimation {
              alwaysRunToEnd: true
              running: root.showing && localPopup ? localPopup.important : false
              loops: -1
              NumberAnimation { target: popupNotiContent; property: "rotation"; to: 3; duration: 240; easing.type: Easing.InOutQuad }
              NumberAnimation { target: popupNotiContent; property: "rotation"; to: -3; duration: 240; easing.type: Easing.InOutQuad }
              NumberAnimation { target: popupNotiContent; property: "rotation"; to: 1; duration: 180; easing.type: Easing.InOutQuad }
              NumberAnimation { target: popupNotiContent; property: "rotation"; to: -1; duration: 180; easing.type: Easing.InOutQuad }
              NumberAnimation { target: popupNotiContent; property: "rotation"; to: 0; duration: 150; easing.type: Easing.InOutQuad }
            }
            opacity: popupContent.opacityV
            Column {
              anchors.fill: parent
              anchors.margins: 16
              spacing: 8

              Text {
                text: localPopup ? localPopup.title : ""
                color: "#ffffff"
                height: 16
                font.family: Fonts.sFProDisplayRegular.family
                font.weight: 600
                font.pixelSize: 16
              }
              Text {
                text: localPopup ? localPopup.description : ""
                color: "#cccccc"
                font.family: Fonts.sFProDisplayRegular.family
                font.pixelSize: 13
                width: (Config.notch.minWidth*2) - 40
                wrapMode: Text.WrapAnywhere
              }
            }
          }

          layer.enabled: true
          layer.effect: MultiEffect {
            anchors.fill: popupBg
            shadowEnabled: true
            shadowColor: "#000000"
            shadowOpacity: 0.3
            shadowBlur: 12
          }
        }
      }

      // Listen to the root's showPopup signal and start animation locally.
      Connections {
        target: root
        function onShowPopup(popup) {
          // copy popup into this window and start animation
          localPopup = popup
          popupAnim.start()
        }
      }
    }
  }

  IpcHandler {
    target: "popup"
    function openPopup(iconPath: string, title: string, description: string, timeout: int, important: bool) {
      root.openPopup(iconPath, title, description, timeout, important)
    }
  }
}
