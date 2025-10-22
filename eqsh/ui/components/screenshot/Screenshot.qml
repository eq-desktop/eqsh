import Quickshell
import QtQuick
import QtQuick.VectorImage
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import qs.config
import qs
import qs.core.foundation
import qs.ui.controls.auxiliary
import qs.ui.controls.apps
import qs.ui.controls.providers
import qs.ui.controls.windows.dropdown
import QtQuick.Controls.Fusion
import QtQuick.VectorImage

Scope {
  id: root
  property bool showScrn: Runtime.showScrn
  property bool takingScreenshot: false
  signal requestScreenshot()
  property var region: Qt.rect(0, 0, 0, 0)
  property var outputMon: Hyprland.focusedMonitor
  property int optionsSaveTo: 0
  property int optionsTimer: 0
  property list<bool> optionsOptions: [false, false, false]
  IpcHandler {
    target: "screenshot"
    function toggle() {
      requestScreenshot()
    }
  }
  CustomShortcut {
    name: "screenshot"
    description: "Take Screenshot"
    onPressed: {
      requestScreenshot()
    }
  }
  CustomShortcut {
    name: "screenshotEntireScreen"
    description: "Take Screenshot"
    onPressed: {
      requestScreenshot()
    }
  }

  function takeScreenshot() {
    root.takingScreenshot = true
    Runtime.showScrn = false
    console.info(takeScreenshotProcess.command)
  }

  Process {
    id: takeScreenshotProcess
    command: [
      "grim",
      "-g",
      Math.round(root.region.x + outputMon.x) + "," + Math.round(root.region.y + outputMon.y) + " " + Math.round(root.region.width) + "x" + Math.round(root.region.height),
      "" + (root.optionsSaveTo == 0 ? "Desktop/" : root.optionsSaveTo == 1 ? "Documents/": "") + Time.getTime("yyyy-MM-dd-HH-mm-ss") + ".png"
    ]
    running: false
    onExited: {
      console.info("Screenshot taken")
      root.takingScreenshot = false
    }
    stderr: StdioCollector {
      onStreamFinished: if (text != "") console.error("taking screenshot:", text)
    }
  }
  onRequestScreenshot: {
    Runtime.showScrn = !Runtime.showScrn
  }
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panelWindow
      WlrLayershell.layer: WlrLayer.Overlay
      required property var modelData
      screen: modelData
      WlrLayershell.namespace: "eqsh:lock"
      anchors {
        top: true
        left: true
        right: true
        bottom: true
      }

      focusable: true

      component FullMask: Region {
        x: 0
        y: 0
        width: root.width
        height: root.height
      }

      mask: Region {}

      exclusiveZone: -1
      color: "transparent"
      Loader {
        id: screenshotLoader
        asynchronous: true
        active: true
        focus: false
        property bool shown: false
        anchors.fill: parent
        Keys.onEscapePressed: {
          Runtime.showScrn = false
        }
        Keys.onReturnPressed: {
          root.takeScreenshot()
        }
        PropertyAnimation {
          id: showAnim
          target: screenshotLoader.item
          property: "opacity"
          to: 1
          running: false
          duration: 200
          easing.type: Easing.InOutQuad
          onStarted: {
            screenshotLoader.focus = true;
            const width = root.width
            const height = root.height
            panelWindow.mask = FullMask
          }
        }
        PropertyAnimation {
          id: hideAnim
          target: screenshotLoader.item
          property: "opacity"
          to: 0
          running: false
          duration: 200
          easing.type: Easing.InOutQuad
          onFinished: {
            screenshotLoader.focus = false;
            panelWindow.mask = Qt.createQmlObject("import Quickshell; Region {}", hideAnim);
          }
        }
        sourceComponent: Item {
          id: screenshotContainer
          opacity: 0
          Behavior on opacity {
            NumberAnimation { duration: 500; easing.type: Easing.InOutQuad}
          }
          onOpacityChanged: {
            if (opacity == 0 && root.takingScreenshot) {
              takeScreenshotProcess.running = true
            }
          }
          property int startX: 0
          property int startY: 0

          Rectangle {
            id: selectionBox
            property var rect: Qt.rect(x, y, width, height)
            property bool showScrn: root.showScrn
            onRectChanged: {
              root.region = selectionBox.rect
            }
            onShowScrnChanged: {
              if (!root.optionsOptions[1] && root.showScrn) {
                selectionBox.x = 0
                selectionBox.y = 0
                selectionBox.width = 0
                selectionBox.height = 0
              }
            }
            visible: true
            color: "transparent"
            opacity: 1
            border.color: "#80333333"
            border.width: 1
            radius: 0
          }

          Text {
            id: title
            property bool offScreen: selectionBox.y + selectionBox.height > (screenshotContainer.height-40)
            text: "X: " + Math.round(selectionBox.x) + " Y: " + Math.round(selectionBox.y) + " W: " + Math.round(selectionBox.width) + " H: " + Math.round(selectionBox.height)
            anchors {
              top: selectionBox.bottom
              left: selectionBox.left
              topMargin: title.offScreen ? -(title.paintedHeight+10) : 10
              leftMargin: title.offScreen ? 10 : 0
              Behavior on topMargin { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad} }
              Behavior on leftMargin { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad} }
            }
            z: 2
            color: "#fff"
            visible: selectionBox.width != 0 || selectionBox.height != 0
          }

          Rectangle {
            id: toolBar
            radius: 15
            anchors {
              bottom: parent.bottom
              bottomMargin: 40
              horizontalCenter: parent.horizontalCenter
            }
            width: rowLayout.width
            height: 40
            z: 3
            RowLayout {
              id: rowLayout
              spacing: 0
              height: 40
              anchors.margins: 5
              // EXIT
              Item {
                width: 30
                height: 30
                MouseArea {
                  anchors.fill: parent
                  onClicked: {
                    Runtime.showScrn = false
                  }
                }
                Rectangle {
                  width: 15
                  height: 15
                  radius: 7.5
                  anchors.centerIn: parent
                  color: "#50aaaaaa"
                  VectorImage {
                    source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/x-bold.svg")
                    width: 12
                    height: 12
                    anchors.centerIn: parent
                  }
                }
              }
              // SCREEN
              Item {
                width: 30
                height: 30
                Rectangle {
                  width: 25
                  height: 25
                  radius: 5
                  anchors.centerIn: parent
                  color: "#aaaaaa"
                }
              }
              // WINDOW
              Item {
                width: 30
                height: 30
                Rectangle {
                  width: 25
                  height: 25
                  radius: 5
                  anchors.centerIn: parent
                  color: "#aaaaaa"
                }
              }
              // SELECTION
              Item {
                width: 30
                height: 30
                Rectangle {
                  width: 25
                  height: 25
                  radius: 5
                  anchors.centerIn: parent
                  color: "#aaaaaa"
                }
              }
              // SPACER
              Item { 
                width: 5
                height: 30
                Rectangle {
                  width: 1
                  height: 25
                  anchors.centerIn: parent
                  color: Config.general.darkMode ? "#333333" : "#ffffff"
                }
              }
              // RECORD
              Item {
                width: 30
                height: 30
                Rectangle {
                  width: 25
                  height: 25
                  radius: 5
                  anchors.centerIn: parent
                  color: "#aaaaaa"
                }
              }
              // SPACER
              Item {
                width: 1
                height: 30
                Rectangle {
                  width: 1
                  height: 25
                  anchors.centerIn: parent
                  color: Config.general.darkMode ? "#333333" : "#ffffff"
                }
              }
              // OPTIONS
              DropDownMenu {
                id: optionsMenu
                verticalOffset: 40
                closeOnClick: false
                model: [
                  DropDownText { name: Translation.tr("Save to") },
                  DropDownItemToggle { enabled: root.optionsSaveTo == 0; action: () => {root.optionsSaveTo = 0}; name: Translation.tr("Desktop") },
                  DropDownItemToggle { enabled: root.optionsSaveTo == 1; action: () => {root.optionsSaveTo = 1}; name: Translation.tr("Documents") },
                  DropDownItemToggle { enabled: root.optionsSaveTo == 2; action: () => {root.optionsSaveTo = 2}; name: Translation.tr("Clipboard") },
                  DropDownItemToggle { enabled: root.optionsSaveTo == 3; action: () => {root.optionsSaveTo = 3}; name: Translation.tr("Preview") },
                  DropDownSpacer {},
                  DropDownText { name: Translation.tr("Timer") },
                  DropDownItemToggle { enabled: root.optionsTimer == 0; action: () => {root.optionsTimer = 0}; name: Translation.tr("None") },
                  DropDownItemToggle { enabled: root.optionsTimer == 1; action: () => {root.optionsTimer = 1}; name: Translation.tr("5 Seconds") },
                  DropDownItemToggle { enabled: root.optionsTimer == 2; action: () => {root.optionsTimer = 2}; name: Translation.tr("10 Seconds") },
                  DropDownSpacer {},
                  DropDownText { name: Translation.tr("Options") },
                  DropDownItemToggle { enabled: root.optionsOptions[0]; action: () => {root.optionsOptions[0] = !root.optionsOptions[0]}; name: Translation.tr("Show Floating Thumbnail") },
                  DropDownItemToggle { enabled: root.optionsOptions[1]; action: () => {root.optionsOptions[1] = !root.optionsOptions[1]}; name: Translation.tr("Remember Last Selection") },
                  DropDownItemToggle { enabled: root.optionsOptions[2]; action: () => {root.optionsOptions[2] = !root.optionsOptions[2]}; name: Translation.tr("Show Mouse Pointer") }
                ]
              }
              Item {
                id: optionsBtn
                width: 75
                Layout.fillHeight: true
                MouseArea {
                  id: optionsBtnMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  onClicked: {
                    const pos = optionsBtn.mapToItem(screenshotContainer, 0, optionsBtn.height)
                    optionsMenu.x = pos.x
                    optionsMenu.y = pos.y
                    optionsMenu.open()
                  }
                  Rectangle {
                    width: 75
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color: optionsMenu.opened || optionsBtnMouse.containsMouse ? "#50555555" : "transparent"
                    Text {
                      anchors.left: parent.left
                      anchors.leftMargin: 5
                      anchors.verticalCenter: parent.verticalCenter
                      text: "Options"
                      color: Config.general.darkMode ? "#dfdfdf" : "#333333"
                    }
                    VectorImage {
                      source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/chevron-right.svg")
                      width: 15
                      height: 15
                      anchors.right: parent.right
                      anchors.rightMargin: 5
                      anchors.verticalCenter: parent.verticalCenter
                      rotation: 90
                      layer.enabled: true
                      layer.effect: MultiEffect {
                        colorization: 1
                        colorizationColor: Config.general.darkMode ? "#dfdfdf" : "#333333"
                      }
                    }
                  }
                }
              }
              Item {
                id: captureBtn
                width: 60
                Layout.fillHeight: true
                MouseArea {
                  anchors.fill: parent
                  onClicked: {
                    root.takeScreenshot()
                  }
                  Rectangle {
                    width: 60
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color: "transparent"
                    Text {
                      anchors.centerIn: parent
                      text: "Capture"
                      color: Config.general.darkMode ? "#dfdfdf" : "#333333"
                    }
                  }
                }
              }
            }
            color: Config.general.darkMode ? "#1e1e1e" : "#dfdfdf"
          }

          Rectangle {
            anchors.fill: title
            anchors.margins: -5
            radius: 15
            color: "#c0000000"
            opacity: title.offScreen ? 1: 0
            Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad} }
          }

          Rectangle { // Top overlay
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: selectionBox.y
            color: "#c0000000"
            visible: selectionBox.opacity > 0
          }

          Rectangle { // Left overlay
            anchors.left: parent.left
            width: selectionBox.x
            anchors.top: selectionBox.top
            anchors.bottom: selectionBox.bottom
            color: "#c0000000"
            visible: selectionBox.opacity > 0
          }

          Rectangle { // Right overlay
            anchors.right: parent.right
            width: parent.width - (selectionBox.x + selectionBox.width)
            anchors.top: selectionBox.top
            anchors.bottom: selectionBox.bottom
            color: "#c0000000"
            visible: selectionBox.opacity > 0
          }

          Rectangle { // Bottom overlay
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height - (selectionBox.y + selectionBox.height)
            color: "#c0000000"
            visible: selectionBox.opacity > 0
          }

          MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.CrossCursor

            onPressed: (mouse) => {
              screenshotContainer.startX = mouse.x
              screenshotContainer.startY = mouse.y

              selectionBox.x = screenshotContainer.startX
              selectionBox.y = screenshotContainer.startY
              selectionBox.width = 0
              selectionBox.height = 0
            }

            onPositionChanged: (mouse) => {
              selectionBox.x = Math.min(mouse.x, screenshotContainer.startX)
              selectionBox.y = Math.min(mouse.y, screenshotContainer.startY)
              selectionBox.width = Math.abs(mouse.x - screenshotContainer.startX)
              selectionBox.height = Math.abs(mouse.y - screenshotContainer.startY)
            }
          }
        }
      }
      property bool showScrn: root.showScrn
      onShowScrnChanged: {
        if (panelWindow.showScrn) {
          screenshotLoader.shown = true
          showAnim.start()
        } else {
          screenshotLoader.shown = false
          hideAnim.start()
        }
      }
    }
  }
}