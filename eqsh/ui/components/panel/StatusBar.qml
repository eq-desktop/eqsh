import Quickshell
import QtQuick
import QtQuick.VectorImage
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs
import qs.core.foundation
import qs.ui.controls.auxiliary
import qs.ui.controls.providers
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

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panelWindow
      WlrLayershell.layer: WlrLayer.Overlay
      required property var modelData
      screen: modelData
      WlrLayershell.namespace: Config.bar.useBlur ? "eqsh:blur" : "eqsh"

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
                UIBButton {
                  text: customAppName != "" ? customAppName : (applicationName == "" ? Config.bar.defaultAppName : applicationName)
                  font.weight: 700
                }

                UIBButton {
                  text: Translation.tr("File")
                  id: globalMenuFileButton
                  DropDownMenu {
                    id: globalMenuFile
                    x: 0
                    y: Config.bar.height
                  }
                  onClick: {
                    globalMenuFile.open()
                  }
                }

                UIBButton {
                  text: Translation.tr("Edit")
                }

                UIBButton {
                  text: Translation.tr("View")
                }

                UIBButton {
                  text: Translation.tr("Go")
                }

                UIBButton {
                  text: Translation.tr("Window")
                  
                }

                UIBButton {
                  text: Translation.tr("Help")
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

          SystemTray {}

          UIBButton{Battery {iconSize: barIS} }

          UIBButton {Wifi {iconSize: barIS}}

          UIBButton {VectorImage {
            id: rBBluetooth
            source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/bluetooth-clear.svg")
            width: barIS * 1.2
            height: barIS * 1.2
            preferredRendererType: VectorImage.CurveRenderer
            anchors.centerIn: parent
          } }

          UIBButton {VectorImage {
            id: rBSearch
            source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/search.svg")
            width: barIS * 0.7
            height: barIS * 0.7
            Layout.preferredWidth: barIS * 0.7
            Layout.preferredHeight: barIS * 0.7
            preferredRendererType: VectorImage.CurveRenderer
            anchors.centerIn: parent
          } }

          UIBButton {
            VectorImage {
              id: rBControlCenter
              source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/control-center.svg")
              width: barIS
              height: barIS
              Layout.preferredWidth: barIS
              Layout.preferredHeight: barIS
              preferredRendererType: VectorImage.CurveRenderer
              anchors.centerIn: parent
            }
            onClick: controlCenter.open()
            ControlCenter {
              id: controlCenter
              screen: panelWindow.screen
            }
            
          }

          UIBButton{
            text: Time.time
          }
        }
      }
    }
  }
}