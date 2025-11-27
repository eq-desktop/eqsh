import Quickshell
import QtQuick
import QtQuick.VectorImage
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.config
import qs
import qs.core.foundation
import qs.ui.controls.auxiliary
import qs.ui.controls.providers
import qs.ui.controls.primitives
import qs.ui.controls.windows
import qs.ui.controls.windows.dropdown
import QtQuick.Controls.Fusion

Scope {
  id: root
  property string customAppName: ""
  property bool   visible: true
  property bool   shown: false
  property bool   appInFullscreen: HyprlandExt.appInFullscreen
  property bool   forceHide: Config.bar.autohide
  property bool   inFullscreen: shown ? forceHide : appInFullscreen || forceHide
  property var    focusedscreen: null
  property var    focusedwindow: null
  Connections {
      target: Hyprland
      function onFocusedMonitorChanged() {
          root.focusedscreen = Quickshell.screens.filter(screen => screen.name == Hyprland.focusedMonitor.name)[0];
      }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panelWindow
      WlrLayershell.layer: WlrLayer.Overlay
      required property var modelData
      screen: modelData
      WlrLayershell.namespace: Config.bar.useBlur ? "eqsh:blur" : "eqsh"

      property var focscreen: root.focusedscreen
      onFocscreenChanged: {
        if (panelWindow.screen == root.focusedscreen) {
          root.focusedwindow = panelWindow;
        }
      }

      property string applicationName: HyprlandExt.applicationName != "" ? HyprlandExt.applicationName : Config.bar.defaultAppName

      component UIBButton: BButton {
        font.weight: 600
        onHover: {
          this.jumpUp();
        }
      }

      anchors {
        top: true
        left: true
        right: true
      }

      color: "transparent"

      exclusiveZone: -1

      implicitHeight: Config.bar.height

      visible: Config.bar.enable

      Barblock {
        screen: modelData
      }

      mask: Region {
        item: Runtime.widgetEditMode ? null : barContent
      }

      readonly property real barFS: Math.max(10, Math.min(20, Math.ceil(Config.bar.height / 1.5)))
      readonly property real barIS: Math.max(10, Math.min(50, Math.ceil(Config.bar.height / 1.2)))
      Item {
        id: barContent
        width: parent.width
        property real topMargin: Config.bar.hideOnLock ? (root.visible ? (root.inFullscreen ? -Config.bar.height : 0) : -Config.bar.height) : (root.inFullscreen ? -Config.bar.height : 0)
        Behavior on topMargin { NumberAnimation { duration: Config.bar.hideDuration; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
        anchors {
          top: parent.top
          left: parent.left
          right: parent.right
          topMargin: barContent.topMargin
        }
        height: Config.bar.height
        scale: Config.general.reduceMotion ? 1 : 0.8
        opacity: Config.general.reduceMotion ? 1 : 0
        Component.onCompleted: {
          scale = 1
          opacity = 1
        }
        Rectangle {
          color: root.appInFullscreen ? Config.bar.fullscreenColor : Config.bar.color
          Behavior on color { ColorAnimation { duration: Config.bar.hideDuration; easing.type: Easing.InOutQuad } }
          anchors.fill: parent
        }
        property bool widgetEditMode: Runtime.widgetEditMode
        onWidgetEditModeChanged: {
          opacity = widgetEditMode ? 0 : 1
          scale = widgetEditMode ? 0.5 : 1
        }
        Behavior on scale {
          NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 0.5 }
        }
        onScaleChanged: {
          panelWindow.mask.changed();
        }
        Behavior on opacity {
          NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
        }
        RowLayout {
          spacing: -6
          anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 0
          }

          UIBButton {VectorImage {
            id: lBAppMenu
            source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/icon.svg")
            width: barFS
            height: barFS
            preferredRendererType: VectorImage.CurveRenderer
            anchors.centerIn: parent
          }}

          Rectangle {
            id: globalMenu
            height: Config.bar.height
            implicitHeight: Config.bar.height
            Layout.fillHeight: true
            Layout.margins: 0
            width: globalMenuLayout.implicitWidth
            color: "transparent"
            property real dragOffset: -Config.bar.height
            property bool shown: false
            Timer {
              id: globalMenuTimer
              interval: 1000
              onTriggered: {
                if (!dragArea.containsMouse) {
                  globalMenu.shown = false
                }
              }
            }
            MouseArea {
              id: dragArea
              anchors.fill: parent
              hoverEnabled: true
              property real startY: 0
              preventStealing: true
              propagateComposedEvents: true

              onEntered: {
                globalMenuTimer.stop()
                if (Config.bar.autohideGlobalMenu && Config.bar.autohideGlobalMenuMode == 1) {
                  globalMenu.shown = true
                  globalMenuTimer.start()
                }
              }
              onExited: {
                globalMenuTimer.start()
              }
              onClicked: (mouse)=> {
                mouse.accepted = false
              }

              onPressed: (mouse) => {startY = mouse.y}
              onReleased: (mouse) => {
                if (Config.bar.autohideGlobalMenu && Config.bar.autohideGlobalMenuMode == 0) {
                  let endY = mouse.y
                  let halfPoint = parent.height / 2
                  if (endY - startY > halfPoint) {
                    globalMenu.shown = true
                    globalMenuTimer.start()
                  }
                }
              }
              RowLayout {
                id: globalMenuLayout
                spacing: -6
                anchors {
                  fill: parent
                  verticalCenter: parent.verticalCenter
                  topMargin: !Config.bar.autohideGlobalMenu ? 0 : globalMenu.shown ? 0 : -Config.bar.height * 2
                  Behavior on topMargin {
                    NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 0.5 }
                  }
                }
                DropDownMenu {
                  id: globalMenuDrop
                  x: globalMenuRepeater.selectedItemX+globalMenu.x
                  Connections {
                    target: globalMenuRepeater
                    function onSelectedItemXChanged() {
                      globalMenuDrop.x = globalMenuRepeater.selectedItemX+globalMenu.x
                    }
                  }
                  y: 0
                  windows: [ panelWindow ]
                  margins: [ 0, Config.bar.height, 0, 0 ]
                  onCleared: {
                    globalMenuRepeater.isOpened = false
                  }
                }

                Repeater {
                  id: globalMenuRepeater
                  property bool isOpened: false
                  property int selectedItemX: 0
                  property int selectedItem: -1
                  model: [
                    { text: customAppName != "" ? customAppName : (applicationName == "" ? Config.bar.defaultAppName : applicationName), app: true },
                    { text: "File" },
                    { text: "Edit" },
                    { text: "View" },
                    { text: "Window" },
                    { text: "Help" }
                  ]
                  onIsOpenedChanged: {
                    globalMenuDrop.opened = globalMenuRepeater.isOpened
                  }
                  delegate: UIBButton {
                    required property var modelData
                    required property var index
                    text: modelData.app ? modelData.text : Translation.tr(modelData.text)
                    id: globalMenuButton
                    selected: index == globalMenuRepeater.selectedItem && globalMenuRepeater.isOpened
                    font.weight: modelData.app ? 700 : 500
                    Layout.alignment: Qt.AlignVCenter

                    onHover: {
                      globalMenuRepeater.selectedItemX = globalMenuButton.x
                      globalMenuRepeater.selectedItem = index
                    }

                    onClick: {
                      globalMenuRepeater.isOpened = !globalMenuRepeater.isOpened
                    }
                  }
                }
              }
            }
          }
        }

        RowLayout {
          spacing: Config.bar.height > 35 ? 0 : -8
          anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 10
          }

          Repeater {
            model: ScriptModel {
              values: Config.bar.rightBarItems
            }
            delegate: Item {
              Layout.minimumWidth: 50
              implicitWidth: itemLoader.implicitWidth

              Loader {
                id: itemLoader
                anchors.centerIn: parent
                sourceComponent: {
                  switch(modelData) {
                    case "systemTray":
                      return systemTrayComponent
                    case "battery":
                      return batteryComponent
                    case "wifi":
                      return wifiComponent
                    case "bluetooth":
                      return bluetoothComponent
                    case "search":
                      return searchComponent
                    case "controlCenter":
                      return controlCenterComponent
                    case "clock":
                      return clockComponent
                    case "ai":
                      return aiComponent
                    default:
                      return null
                  }
                }
              }
            }
          }

          // Components for each item
          Component { id: systemTrayComponent; SystemTray {} }
          Component { id: batteryComponent; UIBButton { Battery { iconSize: 25 } } }
          Component { id: wifiComponent; UIBButton { Wifi { iconSize: 25 } } }
          Component {
            id: bluetoothComponent
            UIBButton {
              VectorImage {
                id: rBBluetooth
                source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/bluetooth-clear.svg")
                width: 25 * 1.2
                height: 25 * 1.2
                preferredRendererType: VectorImage.CurveRenderer
                anchors.centerIn: parent
              }
            }
          }
          Component {
            id: searchComponent
            UIBButton {
              VectorImage {
                id: rBSearch
                source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/search.svg")
                width: 25 * 0.7
                height: 25 * 0.7
                Layout.preferredWidth: 25 * 0.7
                Layout.preferredHeight: 25 * 0.7
                preferredRendererType: VectorImage.CurveRenderer
                anchors.centerIn: parent
              }
              selected: Runtime.spotlightOpen
              onClick: Runtime.spotlightOpen = !Runtime.spotlightOpen
            }
          }
          Component {
            id: aiComponent
            UIBButton {
              ClippingRectangle {
                anchors.centerIn: parent
                width: 25 * 0.8
                height: 25 * 0.8
                radius: 100
                color: "transparent"
                CFI {
                  id: rBAI
                  icon: "ai-full.png"
                  size: 25 * 0.8
                  anchors.centerIn: parent
                  colorized: false
                }
              }
              selected: Runtime.aiOpen
              onClick: Runtime.aiOpen = !Runtime.aiOpen
            }
          }
          Component {
            id: controlCenterComponent
            UIBButton {
              id: controlCenterButton
              selected: controlCenter.opened
              VectorImage {
                id: rBControlCenter
                source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/control-center.svg")
                width: 25
                height: 25
                Layout.preferredWidth: 25
                Layout.preferredHeight: 25
                preferredRendererType: VectorImage.CurveRenderer
                anchors.left: parent.left
                anchors.leftMargin: Runtime.activeCCSW.length == 0 ? 12.5 : 6.25
                Behavior on anchors.leftMargin {
                  NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 0.5 }
                }
              }
              Item {
                id: listWrapper
                width: 10
                height: Runtime.activeCCSW.length * (5 + 2)
                Behavior on height {
                  NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
                }
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: rBControlCenter.right
                ColumnLayout {
                  id: column
                  anchors.fill: parent
                  spacing: 2

                  Repeater {
                    model: ScriptModel { values: Runtime.activeCCSW }
                    delegate: Rectangle {
                      required property var modelData
                      width: 5
                      height: 5
                      radius: 3
                      color: {
                        switch (modelData) {
                          case "camera": return "#47C55E"
                          case "microphone": return "#FC9526"
                          case "audio": return "#AF53DE"
                          default: return "#ffffff"
                        }
                      }

                      scale: 0

                      Component.onCompleted: {
                        scale = 1
                      }

                      Behavior on scale {
                        NumberAnimation { duration: 800; easing.type: Easing.OutBack; easing.overshoot: 0.5 }
                      }

                      Behavior on y {
                        NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 0.5 }
                      }
                    }
                  }
                }
              }
              onClick: controlCenter.open()
              ControlCenter {
                id: controlCenter
                screen: panelWindow.screen
              }
            }
          }
          Component {
            id: clockComponent
            UIBButton {
              text: Time.time
            }
          }
        }
      }
    }
  }
}