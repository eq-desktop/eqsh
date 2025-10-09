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
import QtQuick.Controls.Fusion
import QtQuick.VectorImage

Scope {
  id: root
  property bool showLP: Runtime.launchpadOpen
  IpcHandler {
    target: "launchpad"
    function toggle() {
      Runtime.launchpadOpen = !Runtime.launchpadOpen
    }
  }
  CustomShortcut {
    name: "launchpad"
    description: "Toggle Launchpad"
    onPressed: {
      Runtime.launchpadOpen = !Runtime.launchpadOpen
    }
  }
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panelWindow
      WlrLayershell.layer: WlrLayer.Overlay
      required property var modelData
      screen: modelData
      WlrLayershell.namespace: "eqsh"
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
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
      color: "#00000000"
      Behavior on color { ColorAnimation { duration: Config.launchpad.fadeDuration; easing.type: Easing.InOutQuad} }
      Loader {
        id: launchpadLoader
        asynchronous: true
        active: true
        focus: false
        property real scaleVal: Config.launchpad.zoom
        property real blurVal
        property bool shown: false
        anchors.fill: parent
        Keys.onEscapePressed: {
          Runtime.launchpadOpen = false
        }
        PropertyAnimation {
          id: showAnim
          target: launchpadLoader.item
          property: "opacity"
          to: 1
          running: false
          duration: Config.launchpad.fadeDuration
          easing.type: Easing.InOutQuad
          onStarted: {
            launchpadLoader.focus = true;
            const width = root.width
            const height = root.height
            panelWindow.mask = FullMask
            panelWindow.color = "#ff000000";
            launchpadLoader.scaleVal = 1
            launchpadLoader.blurVal = 1
          }
        }
        PropertyAnimation {
          id: hideAnim
          target: launchpadLoader.item
          property: "opacity"
          to: 0
          running: false
          duration: Config.launchpad.fadeDuration
          easing.type: Easing.InOutQuad
          onStarted: {
            panelWindow.color = "#00000000";
            launchpadLoader.scaleVal = Config.launchpad.zoom
            launchpadLoader.blurVal = 0
          }
          onFinished: {
            launchpadLoader.focus = false;
            panelWindow.mask = Qt.createQmlObject("import Quickshell; Region {}", hideAnim);
          }
        }
        sourceComponent: Item {
          id: launchpadContainer
          opacity: 0
          Behavior on opacity {
            NumberAnimation { duration: Config.launchpad.fadeDuration; easing.type: Easing.InOutQuad}
          }
          BackgroundImage {
            blurEnabled: true
            blurMax: 64
            blur: launchpadLoader.blurVal
          }
          Item {
            anchors.fill: parent
            scale: launchpadLoader.scaleVal
            Behavior on scale {
              NumberAnimation { duration: Config.launchpad.fadeDuration; easing.type: Easing.InOutQuad}
            }
            Box {
              id: searchBoxContainer
              width: 250
              height: 30
              anchors.horizontalCenter: parent.horizontalCenter
              anchors.top: parent.top
              anchors.topMargin: 20
              TextField {
                id: searchBox
                anchors.centerIn: parent
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
                padding: 10

                focus: true
              }
            }
            SwipeView {
              id: swipeView
              anchors.fill: parent
              interactive: true
              orientation: Qt.Horizontal

              // Split applications into pages of 35
              Repeater {
                model: Math.ceil(DesktopEntries.applications.values.length / 35)
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
                      model: DesktopEntries.applications.values.slice(index * 35, (index + 1) * 35)
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
      property bool showLP: root.showLP
      onShowLPChanged: {
        if (panelWindow.showLP) {
          launchpadLoader.shown = true
          showAnim.start()
        } else {
          launchpadLoader.shown = false
          hideAnim.start()
        }
      }
    }
  }
}