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
  signal requestScreenshot()
  property string imageSource: ""
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

  Process {
    id: takeScreenshot
    command: ["hyprshot", "-m", "output", "-m", "eDP-1", "--silent", "-o", ".config", "-f", ".tmp_eqsh_screenshot.png"]
    running: false
    onExited: {
      // Reload the image after the file is created
      root.imageSource = ""
      root.imageSource = Qt.resolvedUrl("/home/enviction/.config/.tmp_eqsh_screenshot.png")
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
      WlrLayershell.namespace: "eqsh"
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
        PropertyAnimation {
          id: showAnim
          target: screenshotLoader.item
          property: "opacity"
          to: 1
          running: false
          duration: 500
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
          duration: 500
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
          property int startX: 0
          property int startY: 0

          Rectangle {
            id: selectionBox
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
            width: 250
            height: 40
            z: 3
            RowLayout {
              id: rowLayout
              anchors.fill: parent
              spacing: 0
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
                  color: "#aaaaaa"
                  VectorImage {
                    source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/x-bold.svg")
                    width: 12
                    height: 12
                    transform: Translate { x: -1 }
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
              property int optionsSaveTo: 0
              property int optionsTimer: 0
              property list<bool> optionsOptions: [false, false, false]
              // OPTIONS
              DropDownMenu {
                id: optionsMenu
                verticalOffset: 40
                closeOnClick: false
                model: [
                  DropDownText { name: Translation.tr("Save to") },
                  DropDownItemToggle { enabled: rowLayout.optionsSaveTo == 0; action: () => {rowLayout.optionsSaveTo = 0}; name: Translation.tr("Desktop") },
                  DropDownItemToggle { enabled: rowLayout.optionsSaveTo == 1; action: () => {rowLayout.optionsSaveTo = 1}; name: Translation.tr("Documents") },
                  DropDownItemToggle { enabled: rowLayout.optionsSaveTo == 2; action: () => {rowLayout.optionsSaveTo = 2}; name: Translation.tr("Clipboard") },
                  DropDownItemToggle { enabled: rowLayout.optionsSaveTo == 3; action: () => {rowLayout.optionsSaveTo = 3}; name: Translation.tr("Preview") },
                  DropDownSpacer {},
                  DropDownText { name: Translation.tr("Timer") },
                  DropDownItemToggle { enabled: rowLayout.optionsTimer == 0; action: () => {rowLayout.optionsTimer = 0}; name: Translation.tr("None") },
                  DropDownItemToggle { enabled: rowLayout.optionsTimer == 1; action: () => {rowLayout.optionsTimer = 1}; name: Translation.tr("5 Seconds") },
                  DropDownItemToggle { enabled: rowLayout.optionsTimer == 2; action: () => {rowLayout.optionsTimer = 2}; name: Translation.tr("10 Seconds") },
                  DropDownSpacer {},
                  DropDownText { name: Translation.tr("Options") },
                  DropDownItemToggle { enabled: rowLayout.optionsOptions[0]; action: () => {rowLayout.optionsOptions[0] = !rowLayout.optionsOptions[0]}; name: Translation.tr("Show Floating Thumbnail") },
                  DropDownItemToggle { enabled: rowLayout.optionsOptions[1]; action: () => {rowLayout.optionsOptions[1] = !rowLayout.optionsOptions[1]}; name: Translation.tr("Remember Last Selection") },
                  DropDownItemToggle { enabled: rowLayout.optionsOptions[2]; action: () => {rowLayout.optionsOptions[2] = !rowLayout.optionsOptions[2]}; name: Translation.tr("Show Mouse Pointer") }
                ]
              }
              Item {
                id: optionsBtn
                width: 60
                Layout.fillHeight: true
                MouseArea {
                  anchors.fill: parent
                  onClicked: {
                    const pos = optionsBtn.mapToItem(screenshotContainer, 0, optionsBtn.height)
                    optionsMenu.x = pos.x
                    optionsMenu.y = pos.y
                    optionsMenu.open()
                  }
                  Rectangle {
                    width: 60
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color: "transparent"
                    Text {
                      anchors.centerIn: parent
                      text: "Options"
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