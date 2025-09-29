import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io
import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.VectorImage
import qs.Config
import qs
import qs.ui.Controls.Auxiliary
import qs.ui.Controls.providers

Scope {
  id: root
  property bool shown: false
  property bool appInFullscreen: HyprlandExt.appInFullscreen
  property bool forceHide: Config.notch.autohide
  property bool inFullscreen: shown ? forceHide : appInFullscreen || forceHide
  property string activeWindow: ""
  property int    width: Config.notch.minWidth
  property int    defaultWidth: Config.notch.minWidth
  property int    height: Config.notch.height
  property int    defaultHeight: Config.notch.height
  property var    notch: root

  property string customNotchCode: ""
  property bool   customNotchVisible: false

  property int    customWidth: 0
  property int    customHeight: 0
  property bool   customResize: false

  property bool   locked: Runtime.locked

  property bool firstTimeRunning: Config.account.firstTimeRunning
  property bool loadedConfig: Config.loaded


  property var details: QtObject {
    property list<string> supportedVersions: ["0.1.0"]
    property string currentVersion: "0.1.0"
  }


  onFirstTimeRunningChanged: getWelcomeNotchApp()
  onLoadedConfigChanged: getWelcomeNotchApp()

  function getWelcomeNotchApp() {
    if (Config.account.firstTimeRunning && Config.loaded) {
      fileViewer.path = Quickshell.shellDir + "/ui/components/notch/instances/Welcome.qml"
      root.notchInstance(fileViewer.text())
    } else {
      if (root.customNotchVisible) {
        root.closeNotchInstance()
      }
    }
  }

  FileView {
    id: fileViewer
    path: Quickshell.shellDir + "/ui/components/notch/instances/Lock.qml"
    blockAllReads: true
  }
  onLockedChanged: {

    if (locked) {
      fileViewer.path = Quickshell.shellDir + "/ui/components/notch/instances/Lock.qml"
      root.notchInstance(fileViewer.text())
    } else {
      root.closeNotchInstance()
    }
  }

  function getIcon(path) {
    if (path.startsWith("builtin:")) {
      return Qt.resolvedUrl(Quickshell.shellDir + "/Media/icons/notch/" + path.substring(8) + ".svg")
    } else {
      return Qt.resolvedUrl(path)
    }
  }

  function notchInstance(code) {
    root.customNotchVisible = false
    root.customNotchCode = code
    root.customNotchVisible = true
  }

  function closeNotchInstance() {
    root.customNotchCode = ""
    root.customNotchVisible = false
    root.resetSize()
  }

  function setSize(width=-1, height=-1) {
    root.customResize = false
    root.customWidth = width
    root.customHeight = height
    root.customResize = true
  }
  function resetSize() {
    root.customWidth = 0
    root.customHeight = 0
    root.customResize = false
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "eqsh:lock"
      id: panelWindow
      property bool islandMode: Config.notch.islandMode
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
        bottom: true
      }
      implicitWidth: Config.notch.minWidth
      implicitHeight: Config.notch.height+40
      exclusiveZone: -1
      visible: Config.notch.enable
      color: "transparent"

      margins {
        top: inFullscreen ? -(Config.notch.height + Config.notch.margin) : 0
      }

      property int minWidth: Config.notch.minWidth
      property int maxWidth: Config.notch.maxWidth

      mask: Region {
        x: notchBg.x
        y: notchBg.y
        width: notchBg.width
        height: notchBg.height
      }

      Item {
        anchors.fill: parent

        Rectangle {
          id: notchBg
          anchors {
            top: parent.top
            topMargin: Config.notch.islandMode ? Config.notch.margin : -1
            horizontalCenter: parent.horizontalCenter
            Behavior on topMargin {
              NumberAnimation { duration: Config.notch.hideDuration; easing.type: Easing.OutQuad }
            }
          }
          scale: Config.general.reduceMotion ? 1 : 0
          Component.onCompleted: {
            scale = 1;
          }
          Behavior on scale {
            NumberAnimation { duration: 1000; easing.type: Easing.OutBack; easing.overshoot: 1 }
          }
          implicitWidth: parent.width - 40
          implicitHeight: parent.height - 40
          topLeftRadius: panelWindow.islandMode ? Config.notch.radius : 0
          topRightRadius: panelWindow.islandMode ? Config.notch.radius : 0
          bottomLeftRadius: Config.notch.radius
          bottomRightRadius: Config.notch.radius
          property bool customResize: root.customResize
          onImplicitHeightChanged: {
            root.height = implicitHeight;
            Runtime.notchHeight = implicitHeight;
          }
          onImplicitWidthChanged: {
            root.width = implicitWidth;
          }
          Behavior on implicitHeight {
            NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 0.2 }
          }
          Behavior on implicitWidth {
            NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1 }
          }
          onCustomResizeChanged: {
            if (root.customResize) {
              implicitHeight = root.customHeight == -1 ? Config.notch.height : root.customHeight;
              implicitWidth = root.customWidth == -1 ? minWidth : root.customWidth;
            } else {
              implicitHeight = Config.notch.height;
              implicitWidth = minWidth;
            }
          }
          clip: true
          color: Config.notch.backgroundColor
          layer.enabled: true
          layer.effect: MultiEffect {
            anchors.fill: notchBg
            shadowEnabled: true
            shadowColor: root.customResize ? "#ffffff" : "#000000"
            shadowOpacity: 0.2
            shadowBlur: 1
          }
          property var notchCustomCodeObj: null
          property var notchCustomCodeVis: root.customNotchVisible
          onNotchCustomCodeVisChanged: {
            if (notchCustomCodeVis) {
              notchCustomCodeObj = Qt.createQmlObject(root.customNotchCode, notchBg)
              const version = notchCustomCodeObj.details.version
              if (!root.details.supportedVersions.includes(version)) {
                console.warn("The notch app version (" + version + ") is not supported. Supported versions are: " + root.details.supportedVersions.join(", ") + ". The current version is: " + root.details.currentVersion + ". The notch app might not work as expected.")
              }
            } else {
              if (!notchCustomCodeObj) return;
              notchCustomCodeObj.destroy()
            }
          }
        }

        Corner {
          visible: Config.notch.fluidEdge && !Config.notch.islandMode
          orientation: 1
          width: 20
          height: 20 * Config.notch.fluidEdgeStrength
          anchors {
            top: parent.top
            left: parent.left
            leftMargin: 1
          }
          color: Config.notch.backgroundColor
        }
        Corner {
          visible: Config.notch.fluidEdge && !Config.notch.islandMode
          orientation: 1
          invertH: true
          width: 20
          height: 20 * Config.notch.fluidEdgeStrength
          anchors {
            top: parent.top
            right: parent.right
            rightMargin: 1
          }
          color: Config.notch.backgroundColor
        }
      }
    }
  }
  IpcHandler {
    target: "notch"
    function setSize(width: int, height: int) {
      root.setSize(width, height);
    }
    function resetResize() {
      root.resetResize();
    }
    function instance(code: string) {
      root.notchInstance(code);
    }
    function closeInstance() {
      root.closeNotchInstance();
    }
  }
}
