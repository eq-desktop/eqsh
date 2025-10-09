import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.UPower
import Quickshell.Io
import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.VectorImage
import qs.config
import qs
import qs.core.system
import qs.ui.controls.auxiliary
import qs.ui.controls.providers

Scope {
  id: root
  property bool shown: false
  property bool appInFullscreen: HyprlandExt.appInFullscreen
  property bool forceHide: Config.notch.autohide
  property bool inFullscreen: shown ? forceHide : appInFullscreen || forceHide
  property string activeWindow: ""
  property int    topMargin: Config.notch.islandMode ? Config.notch.margin : -1
  property int    width: Config.notch.minWidth
  property int    defaultWidth: Config.notch.minWidth
  property int    height: Config.notch.height
  property int    defaultHeight: Config.notch.height
  property var    notch: root

  property string customNotchCode: ""
  property var    customNotchId: null
  property bool   customNotchVisible: false

  property int       customWidth: 0
  property int       customHeight: 0
  property list<var> customSizes: []
  property bool      customResize: false

  property list<int> runningNotchInstances: []

  property bool   locked: Runtime.locked

  property bool firstTimeRunning: Config.account.firstTimeRunning
  property bool loadedConfig: Config.loaded
  property bool dndMode: NotificationDaemon.popupInhibited
  readonly property bool batCharging: UPower.onBattery ? (UPower.displayDevice.state == UPowerDeviceState.Charging) : true


  property var details: QtObject {
    property list<string> supportedVersions: ["0.1.0", "0.1.1"]
    property string currentVersion: "0.1.1"
  }

  property var notchRegistry: {
    "welcome": { path: "Welcome.qml" },
    "charging": { path: "Charging.qml" },
    "dnd": { path: "DND.qml" },
    "lock": { path: "Lock.qml" },
  }

  function launchById(id) {
    const app = notchRegistry[id];
    if (app) {
      fileViewer.path = Quickshell.shellDir + "/ui/components/notch/instances/" + app.path;
      return root.notchInstance(fileViewer.text());
    }
  }

  onFirstTimeRunningChanged: getWelcomeNotchApp()
  onLoadedConfigChanged: getWelcomeNotchApp()

  function getWelcomeNotchApp() {
    if (Config.account.firstTimeRunning && Config.loaded) {
      launchById("welcome")
    } else {
      if (root.customNotchVisible) {
        root.closeAllNotchInstances()
      }
    }
  }
  onDndModeChanged: launchById("dnd")

  onBatChargingChanged: if (batCharging) launchById("charging")

  FileView {
    id: fileViewer
    path: Quickshell.shellDir + "/ui/components/notch/instances/Lock.qml"
    blockAllReads: true
  }

  property var lockId: null
  onLockedChanged: {
    if (locked) {
      root.lockId = launchById("lock")
    } else {
      root.closeNotchInstance(root.lockId)
    }
  }

  function getIcon(path) {
    if (path.startsWith("builtin:")) {
      return Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/notch/" + path.substring(8) + ".svg")
    } else {
      return Qt.resolvedUrl(path)
    }
  }

  function notchInstance(code) {
    root.customNotchVisible = false
    const id = Math.floor(Math.random() * 1000000)
    root.customNotchId = id
    root.customNotchCode = code
    root.customNotchVisible = true
    return id;
  }

  function closeNotchInstance(id) {
    let new_notch_instances = root.runningNotchInstances
    for (let i = 0; i < new_notch_instances.length; i++) {
      if (new_notch_instances[i] === id) {
        new_notch_instances.splice(i, 1)
        break;
      }
    }
    root.runningNotchInstances = new_notch_instances
    root.customNotchVisible = false
    root.customNotchId = null
    root.customNotchCode = ""
    if (new_notch_instances.length === 0) {
      root.resetSize()
    } else {
      root.flushSize()
    }
  }

  function closeAllNotchInstances() {
    root.customNotchVisible = false
    root.customNotchId = null
    root.customNotchCode = ""
    root.runningNotchInstances = []
    root.resetSize()
  }

  function setSize(width=-1, height=-1) {
    root.customResize = false
    root.customSizes.push([width, height])
    root.customWidth = width
    root.customHeight = height
    root.customResize = true
  }
  function resetSize() {
    root.customWidth = 0
    root.customHeight = 0
    root.customSizes = []
    root.customResize = false
  }

  function flushSize() {
    root.customSizes.pop()
    const size = root.customSizes[root.customSizes.length - 1]
    if (!size) {
      root.resetSize()
      return;
    }
    root.customResize = false
    root.customWidth = size[0]
    root.customHeight = size[1]
    root.customResize = true
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "eqsh:lock"
      id: panelWindow
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
        bottom: true
      }
      exclusiveZone: -1
      visible: Config.notch.enable
      color: "transparent"

      property int minWidth: Config.notch.minWidth
      property int maxWidth: Config.notch.maxWidth

      mask: Region {
        item: notchBg
      }

      Item {
        anchors.fill: parent

        Rectangle {
          id: notchBg
          anchors {
            top: parent.top
            topMargin: inFullscreen ? -(root.height + topMargin + 5) : root.topMargin
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
          implicitWidth: root.width
          implicitHeight: root.height
          topLeftRadius: Config.notch.islandMode ? Config.notch.radius : 0
          topRightRadius: Config.notch.islandMode ? Config.notch.radius : 0
          bottomLeftRadius: Config.notch.radius
          bottomRightRadius: Config.notch.radius
          property bool customResize: root.customResize
          onImplicitHeightChanged: {
            Runtime.notchHeight = implicitHeight;
          }
          Behavior on implicitHeight {
            NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 0.2 }
          }
          Behavior on implicitWidth {
            NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1 }
          }
          onCustomResizeChanged: {
            if (root.customResize) {
              root.height = root.customHeight == -1 ? Config.notch.height : root.customHeight;
              root.width = root.customWidth == -1 ? minWidth : root.customWidth;
            } else {
              root.height = Config.notch.height;
              root.width = minWidth;
            }
          }
          clip: true
          color: Config.notch.backgroundColor
          layer.enabled: true
          property var shadowColor: "#000000"
          layer.effect: MultiEffect {
            anchors.fill: notchBg
            shadowEnabled: true
            shadowColor: notchBg.shadowColor
            shadowOpacity: 1
            shadowBlur: 0.2
          }
          property var notchCustomCodeObj: null
          property var notchCustomCodeVis: root.customNotchVisible
          onNotchCustomCodeVisChanged: {
            if (notchCustomCodeVis) {
              notchCustomCodeObj = Qt.createQmlObject(root.customNotchCode, notchBg)
              notchCustomCodeObj.screen = panelWindow
              notchCustomCodeObj.meta.id = root.customNotchId
              root.customNotchId = null
              const version = notchCustomCodeObj.details.version
              if (notchCustomCodeObj.details.appType == "media") {
                runningNotchInstances = [notchCustomCodeObj.meta.id];
              } else {
                runningNotchInstances.push(notchCustomCodeObj.meta.id);
              }
              if (!root.details.supportedVersions.includes(version)) {
                console.warn("The notch app version (" + version + ") is not supported. Supported versions are: " + root.details.supportedVersions.join(", ") + ". The current version is: " + root.details.currentVersion + ". The notch app might not work as expected.")
              }
              if (notchCustomCodeObj.details.shadowColor) {
                notchBg.shadowColor = notchCustomCodeObj.details.shadowColor
              } else {
                notchBg.shadowColor = "#000000"
              }
            } else {
              //notchCustomCodeObj.destroy()
              notchBg.shadowColor = "#000000"
            }
          }
        }

        Corner {
          visible: Config.notch.fluidEdge && !Config.notch.islandMode
          orientation: 1
          width: 20
          height: 20 * Config.notch.fluidEdgeStrength
          anchors {
            top: notchBg.top
            right: notchBg.left
            rightMargin: -1
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
            top: notchBg.top
            left: notchBg.right
            leftMargin: -1
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
      root.closeNotchInstance(root.runningNotchInstances[root.runningNotchInstances.length - 1]);
    }
    function closeAllInstances() {
      root.closeNotchInstance();
    }
  }
}
