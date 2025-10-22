import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io
import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import QtQuick.VectorImage
import qs.config
import qs
import qs.ui.controls.auxiliary
import qs.ui.controls.providers

import "root:/agents/args.js" as AArgs

Scope {
  id: root
  property var popups: []
  property var currentPopup: null
  property bool showing: false
  signal showPopup(var popup)

  function openPopup(iconPath, app, title, description, timeout, aargs) {
    const parsedargs = AArgs.parse(aargs)
    let popup = {
      iconPath: iconPath,
      app: app,
      title: title,
      description: description,
      timeout: (timeout > 0 ? timeout : 3000),
      attention: parsedargs?.attention ?? false,
      banner: parsedargs?.banner ?? false
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

      anchors {
        top: true
        left: true
        right: true
        bottom: true
      }
      exclusiveZone: -1
      color: "transparent"

      mask: Region {
        item: root.showing ? popupBg : null
      }

      // local popup copy for this window
      property var localPopup: null

      // The visual content that will be animated
      Item {
        id: popupContent
        anchors.fill: parent

        property int blur: 0
        property real opacityV: 0
        property real opacityV2: 0

        property int wWidth: 0
        property int wHeight: 0

        SequentialAnimation {
          id: popupAnim
          running: false
          onFinished: popupAnimIn.start()

          NumberAnimation {
            target: popupContent
            property: "opacityV2"
            from: 0
            to: 1
            duration: 125
          }
        }

        ParallelAnimation {
          id: popupAnimIn
          onFinished: popupAnimTimer.start()
          NumberAnimation {
            target: popupBg
            property: "y"
            from: Config.notch.islandMode ? Config.notch.margin : 0
            to: Config.notch.margin+(Runtime.notchHeight) + 5
            duration: 200
            easing.type: Easing.OutBack
          }
          NumberAnimation {
            target: popupContent
            property: "wWidth"
            to: col.implicitWidth + 32
            duration: 0
            easing.type: Easing.OutBack
          }
          NumberAnimation {
            target: popupContent
            property: "wHeight"
            to: col.implicitHeight + 32
            duration: 0
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

        Timer {
          id: popupAnimTimer
          interval: localPopup ? localPopup.timeout : 2000
          onTriggered: {
            if (localPopup?.banner ?? false) return
            popupAnimOut.start()
          }
        }

        ParallelAnimation {
          id: popupAnimOut
          onFinished: root._onPopupFinished()
          NumberAnimation {
            target: popupBg
            property: "y"
            to: Config.notch.islandMode ? Config.notch.margin : 0
            duration: 125
            easing.type: Easing.InOutQuad
          }

          NumberAnimation {
            target: popupContent
            property: "wWidth"
            to: (Config.notch.minWidth) - 40
            duration: 0
            easing.type: Easing.InBack
          }

          NumberAnimation {
            target: popupContent
            property: "wHeight"
            to: (Runtime.notchHeight)
            duration: 0
            easing.type: Easing.InBack
          }

          NumberAnimation {
            target: popupContent
            property: "opacityV"
            from: 1
            to: 0
            duration: 125
          }
          NumberAnimation {
            target: popupContent
            property: "blur"
            from: 0
            to: 1
            duration: 125
          }
        }
        NumberAnimation {
          target: popupContent
          property: "opacityV2"
          from: 1
          to: 0
          duration: 125
        }

        RectangularShadow {
          id: shadow
          anchors.fill: popupBg
          spread: 0
          blur: 40
          color: localPopup?.attention ? "#80ff0000" : "#000000"
          opacity: root.showing ? 1 : 0
        }

        Rectangle {
          id: popupBg
          property real wOffset: 0
          anchors {
            horizontalCenter: parent.horizontalCenter
          }
          y: Config.notch.margin + (Runtime.notchHeight) + 5
          property int notchHeight: Runtime.notchHeight
          onNotchHeightChanged: {
            if (!showing) return
            y = Config.notch.margin + (Runtime.notchHeight) + 5
          }
          
          width: popupContent.wWidth - (64 * wOffset)
          height: popupContent.wHeight - (32 * wOffset)
          Behavior on width {
            NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 2 }
          }
          Behavior on height {
            NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 2 }
          }
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
            rotation: -parent.rotation
            opacity: popupContent.opacityV
            Column {
              id: col
              anchors.top: parent.top
              anchors.left: parent.left
              anchors.margins: 16
              onImplicitWidthChanged: {
                if (localPopup == null) return
                popupContent.wWidth = col.implicitWidth + 32
              }
              onImplicitHeightChanged: {
                if (localPopup == null) return
                popupContent.wHeight = col.implicitHeight + 32
              }
              spacing: 8

              Image {
                id: icon
                source: localPopup ? localPopup.iconPath : ""
                width: 16
                height: 16
                Text {
                  text: localPopup ? `<font color="#555">${localPopup.app}</font> · ${localPopup.title}` : ""
                  color: "#ffffff"
                  height: 14
                  anchors {
                    left: icon.right
                    leftMargin: 4
                  }
                  font.family: Fonts.sFProDisplayRegular.family
                  font.weight: 600
                  font.pixelSize: 14
                }
              }
              Text {
                text: localPopup ? localPopup.description : ""
                color: "#cccccc"
                font.family: Fonts.sFProDisplayRegular.family
                font.pixelSize: 12
                width: (Config.notch.minWidth*2) - 40
                wrapMode: Text.WrapAnywhere
              }
            }
          }
        }

        MouseArea {
          property real startY
          property real dragStartY
          property bool dragging: false
          anchors.fill: parent
          drag.axis: Drag.YAxis
          drag.minimumY: 0
          drag.maximumY: 300
          drag.smoothed: true

          onPressed: (mouse) => {
            startY = popupBg.y
            dragStartY = mouse.y
            dragging = true
          }

          onPositionChanged: (mouse) => {
            if (!dragging) return
            // Distance dragged
            var dy = mouse.y - dragStartY
            // Apply "tension" curve: the farther you drag, the less it moves
            var tension = 0.4
            var resistance = 1 - Math.exp(-Math.abs(dy) * tension / 100)
            // Direction-aware resistance
            var offset = Math.sign(dy) * resistance * 100
            // Limit drag
            popupBg.y = Config.notch.margin + (Runtime.notchHeight) + 5 + offset
            popupBg.wOffset = popupBg.y / 129
          }

          onReleased: {
            dragging = false
            popupAnimTimer.stop()
            popupAnimOut.start()
            popupBg.wOffset = 0
          }
        }
      }

      // Listen to the root's showPopup signal and start animation locally.
      Connections {
        target: root
        function onShowPopup(popup) {
          localPopup = popup
          popupAnim.start()
        }
      }
    }
  }

  IpcHandler {
    target: "popup"
    function openPopup(iconPath: string, app: string, title: string, description: string, timeout: int, aargs: string) {
      root.openPopup(iconPath, app, title, description, timeout, aargs)
    }
  }
}
