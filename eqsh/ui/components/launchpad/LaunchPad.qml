import Quickshell
import QtQuick
import QtQuick.VectorImage
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Io
import qs.config
import qs
import qs.core.foundation
import qs.ui.controls.auxiliary
import qs.ui.controls.apps
import qs.ui.controls.providers
import qs.ui.controls.primitives
import qs.ui.controls.windows
// glass
import qs.ui.advanced.shader
import qs.ui.advanced.shader.glass
// compositor
import Quickshell.Hyprland
import qs.services

import QtQuick.Controls.Fusion
import QtQuick.VectorImage

Scope {
  id: root
  Component.onCompleted: {
    Ipc.mixin("eqdesktop.launchpad", "toggle", () => {
      Runtime.launchpadOpen = !Runtime.launchpadOpen
    })
  }
  FollowingPanelWindow {
    id: panelWindow
    WlrLayershell.layer: WlrLayer.Overlay
    //required property var modelData
    //screen: modelData
    WlrLayershell.namespace: "eqsh"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    anchors {
      top: true
      left: true
      right: true
      bottom: true
    }

    focusable: true

    property var fullMask: Region {
      x: 0
      y: 0
      width: panelWindow.width
      height: panelWindow.height
    }

    property var emptyMask: Region {}

    mask: Runtime.launchpadOpen ? fullMask : emptyMask

    exclusiveZone: -1
    color: "transparent"
    Loader {
      id: launchpadLoader
      active: Runtime.launchpadOpen
      focus: Runtime.launchpadOpen ? true : false
      anchors.fill: parent
      Keys.onEscapePressed: {
        Runtime.launchpadOpen = false
      }
      sourceComponent: Item {
        id: launchpadContainer
        opacity: 0
        Behavior on opacity {
          NumberAnimation { duration: Config.launchpad.fadeDuration; easing.type: Easing.InOutQuad}
        }
        Component.onCompleted: {
          launchpadContainer.opacity = 1
        }
        Loader {
          id: backgroundImage
          anchors.fill: parent
          active: Config.wallpaper.enable
          sourceComponent: BackgroundImage {
            blurEnabled: true
            blurMax: 32
            blur: Runtime.launchpadOpen ? 1 : 0
          }
        }
        Backdrop {
          id: sourceBackdrop
          sourceItem: backgroundImage
          sourceX: (parent.width/2)-125
          sourceY: (Config.notch.height + 10)
          sourceW: 250
          sourceH: 30
          hideSource: false
          visible: false
        }
        CFClippingRect {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: parent.top
          anchors.topMargin: Config.notch.height + 10
          width: 250
          height: 30
          radius: 15
          color: "transparent"
          GlassMaterial {
            id: searchBoxContainer
            anchors.fill: parent
            size: Qt.point(248, 28)
            pos: Qt.point(1, 1)
            radius: 15
            glassRefractionDim: 15
            glassRefractionMag: 25
            glassRefractionAberration: 50
            opacity: parent.opacity
            source: sourceBackdrop
            blurSource: sourceBackdrop
            bloomSource: sourceBackdrop
            layer.enabled: true
            CFTextField {
              id: searchBox
              anchors.fill: parent
              font.pixelSize: 14
              leftPadding: 10
              background: Rectangle {
                color: "transparent";
                anchors.fill: parent
                Text {
                  id: searchBoxPlaceholderText
                  anchors.centerIn: parent
                  visible: searchBox.text == ""
                  verticalAlignment: Text.AlignVCenter
                  text: Translation.tr("Search")
                  color: "#55ffffff"
                  font.weight: 500
                }
                VectorImage {
                  id: rBSearch
                  source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/search.svg")
                  width: 12
                  height: 12
                  visible: searchBox.text == ""
                  Layout.preferredWidth: 12
                  Layout.preferredHeight: 12
                  preferredRendererType: VectorImage.CurveRenderer
                  anchors.right: searchBoxPlaceholderText.left
                  anchors.rightMargin: 5
                  anchors.verticalCenter: searchBoxPlaceholderText.verticalCenter
                }
              }
              color: "#fff";

              implicitWidth: 250
              implicitHeight: 30
              padding: 0

              focus: true
              Component.onCompleted: {
                searchBox.forceActiveFocus();
              }
            }
            z: 2
          }
        }
        Item {
          anchors.fill: parent
          scale: Runtime.launchpadOpen ? 1 : Config.launchpad.zoom
          Behavior on scale {
            NumberAnimation { duration: Config.launchpad.fadeDuration; easing.type: Easing.InOutQuad}
          }
          SwipeView {
            id: swipeView
            anchors.fill: parent
            interactive: true
            orientation: Qt.Horizontal

            property var apps: DesktopEntries.applications.values.filter(a => a.name.toLowerCase().includes(searchBox.text.toLowerCase()))

            // Split applications into pages of 35
            Repeater {
              model: Math.ceil(swipeView.apps.length / 35)
              delegate: Item {
                Grid {
                  id: appGrid
                  anchors.centerIn: parent
                  width: launchpadContainer.width - 300
                  height: launchpadContainer.height - 200
                  columns: 7
                  rows: 5

                  property int itemSize: 100
                  columnSpacing: (width - (columns * itemSize)) / Math.max(columns - 1, 1)
                  rowSpacing: (height - (rows * itemSize)) / Math.max(rows - 1, 1)

                  Repeater {
                    model: swipeView.apps.slice(index * 35, (index + 1) * 35)
                    delegate: LargeAppIcon {
                      size: appGrid.itemSize
                      appInfo: modelData
                      onClicked: {
                        appInfo.execute();
                        Runtime.launchpadOpen = false
                      }
                    }
                  }
                }
              }
            }
          }
          PageIndicator {
            id: indicator
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 40
            count: swipeView.count
            currentIndex: swipeView.currentIndex
            spacing: 10
            delegate: Rectangle {
              implicitWidth: 6
              implicitHeight: 6

              radius: width / 2
              color: "#fff"

              opacity: index === swipeView.currentIndex ? 1.0 : 0.45

              Behavior on opacity {
                OpacityAnimator {
                  duration: 100
                }
              }
            }
          }
        }
      }
    }
  }
}