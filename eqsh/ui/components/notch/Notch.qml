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
import qs.ui.controls.primitives

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
    property list<string> supportedVersions: ["0.1.0", "0.1.1", "0.1.2"]
    property string currentVersion: "0.1.2"
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

  signal activateInstance()

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
    for (let i = 0; i < root.runningNotchInstances.length; i++) {
      if (new_notch_instances[i] === id) {
        new_notch_instances.splice(i, 1)
        i--;
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

  function setSize(width=-1, height=-1, temp=false) {
    root.customResize = false
    if (!temp) root.customSizes.push([width, height])
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

  function setWto(width, dur=300, ov=3, temp=false, easing=Easing.OutBack) {}
  function setHto(height, dur=300, ov=3, temp=false, easing=Easing.OutBack) {}

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
      focusable: true

      property int minWidth: Config.notch.minWidth
      property int maxWidth: Config.notch.maxWidth
      property real shadowOpacity: 0

      mask: Region {
        item: notchBg
      }

      RectangularShadow {
        anchors.fill: notchBg
        radius: 30
        blur: 40
        spread: 10
        opacity: shadowOpacity
        transform: Translate {
          x: notchBg.xOffset
          Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 }
          }
        }
        Behavior on opacity {
          NumberAnimation { duration: 200 }
        }
      }

      CFRectExperimental {
        id: notchBg
        anchors {
          top: parent.top
          topMargin: inFullscreen ? -(root.height + topMargin + 5) : root.topMargin
          horizontalCenter: parent.horizontalCenter
          Behavior on topMargin {
            NumberAnimation { duration: Config.notch.hideDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
          }
          onTopMarginChanged: {
            panelWindow.mask.changed();
          }
        }
        property int xOffset: notchBg.notchCustomCodeObj?.meta.xOffset || 0
        transform: Translate {
          x: notchBg.xOffset
          Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 }
          }
        }
        scale: 1
        onScaleChanged: {
          panelWindow.mask.changed();
        }
        onXOffsetChanged: {
          panelWindow.mask.changed();
        }
        Behavior on scale {
          NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 }
        }
        implicitWidth: root.width
        implicitHeight: root.height
        topLeftRadius: Config.notch.islandMode ? Config.notch.radius : 0
        topRightRadius: Config.notch.islandMode ? Config.notch.radius : 0
        bottomLeftRadius: Config.notch.radius
        bottomRightRadius: Config.notch.radius
        property bool customResize: root.customResize

        onImplicitWidthChanged: {
          panelWindow.mask.changed();
        }
        onImplicitHeightChanged: {
          panelWindow.mask.changed();
        }

        PropertyAnimation {
          id: animW
          target: root
          property: "width"
          from: root.width
          to: root.width
          duration: 300
          easing.type: Easing.OutBack
          easing.overshoot: 0
        }

        PropertyAnimation {
          id: animH
          target: root
          property: "height"
          from: root.height
          to: root.height
          duration: 300
          easing.type: Easing.OutBack
          easing.overshoot: 0
        }

        function decideOv(width=null, height=null) {
          if (width) {
            if (width > notchBg.implicitWidth) {
              return 3
            } else { return 1 }
          } else if (height) {
            if (height > notchBg.implicitHeight) {
              return 3
            } else { return 1 }
          }
        }

        function setHto(height, dur=300, ov=3, temp=false, easing=Easing.OutBack) {
          animH.from = implicitHeight
          animH.to = height
          animH.duration = dur
          animH.easing.overshoot = ov
          animH.easing.type = easing
          if (temp) {
            animH.target = notchBg
            animH.property = "implicitHeight"
          } else {
            animH.target = root
            animH.property = "height"
          }
          animH.restart()
        }

        function setWto(width, dur=300, ov=3, temp=false, easing=Easing.OutBack) {
          animW.from = implicitWidth
          animW.to = width
          animW.duration = dur
          animW.easing.overshoot = ov
          animW.easing.type = easing
          if (temp) {
            animW.target = notchBg
            animW.property = "implicitWidth"
          } else {
            animW.target = root
            animW.property = "width"
          }
          animW.restart()
        }

        property int _pullHeight: 0
        
        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          scrollGestureEnabled: true
          onEntered: {
            notchBg.setWto(root.width+10, 500, 5, true)
            notchBg.setHto(root.height+5, 500, 5, true)
            shadowOpacity = 0.5
          }
          onExited: {
            if (notchBg.notchCustomCodeObj === null) {
              notchBg.setWto(minWidth, 300, 2)
              notchBg.setHto(Config.notch.height, 300, 2)
              shadowOpacity = 0
            }
          }
          onWheel: (wheel) => {
            let delta = Math.min(50, Math.round(wheel.angleDelta.y/50))
            notchBg._pullHeight = Math.min(20, Math.max(0, notchBg._pullHeight + delta))
            if (wheel.angleDelta.y === 0) {
              notchBg._pullHeight = 0
            }
            notchBg.setHto(30+5+notchBg._pullHeight, 300, 2, true)
          }
          enabled: notchBg.notchCustomCodeObj === null
        }

        onCustomResizeChanged: {
          if (root.customResize) {
            let newH = root.customHeight == -1 ? Config.notch.height : root.customHeight;
            let newW = root.customWidth == -1 ? minWidth : root.customWidth;
            let ovW = decideOv(root.customWidth)
            let ovH = decideOv(null, root.customHeight)
            setHto(newH, 300, ovH)
            setWto(newW, 300, ovW)
          } else {
            let ovW = decideOv(minWidth)
            let ovH = decideOv(null, Config.notch.height)
            setHto(Config.notch.height, 300, ovH)
            setWto(minWidth, 300, ovW)
          }
          panelWindow.mask.changed();
        }
        clip: true
        color: Config.notch.backgroundColor
        property var notchCustomCodeObj: null
        property var notchCustomCodeVis: root.customNotchVisible
        Connections {
          target: root
          function onActivateInstance() {
            if (notchBg.notchCustomCodeObj === null) return
            if (notchBg.notchCustomCodeObj.noMode) return
            if (notchBg.notchCustomCodeObj.notchState === "active") {
              notchBg.notchCustomCodeObj.setIndicative();
              return
            }
            if (notchBg.notchCustomCodeObj.notchState === "indicative") notchBg.notchCustomCodeObj.activate();
          }
        }
        onNotchCustomCodeVisChanged: {
          if (notchCustomCodeVis) {
            notchBg.notchCustomCodeObj = Qt.createQmlObject(root.customNotchCode, notchBg)
            notchBg.notchCustomCodeObj.screen = panelWindow
            notchBg.notchCustomCodeObj.meta.id = root.customNotchId
            const version = notchBg.notchCustomCodeObj.details.version
            if (notchBg.notchCustomCodeObj.details.appType == "media") {
              runningNotchInstances = [notchBg.notchCustomCodeObj.meta.id];
            } else {
              runningNotchInstances.push(notchBg.notchCustomCodeObj.meta.id);
            }
            if (!root.details.supportedVersions.includes(version)) {
              console.warn("The notch app version (" + version + ") is not supported. Supported versions are: " + root.details.supportedVersions.join(", ") + ". The current version is: " + root.details.currentVersion + ". The notch app might not work as expected.")
            }
            if (notchBg.notchCustomCodeObj.details.shadowOpacity !== undefined) {
              panelWindow.shadowOpacity = notchBg.notchCustomCodeObj.details.shadowOpacity
            }
          }
          panelWindow.mask.changed();
        }
      }
      Rectangle { // Camera
        visible: Config.notch.camera
        anchors {
          top: parent.top
          topMargin: 8.5
          horizontalCenter: parent.horizontalCenter
        }
        width: 13
        height: 13
        radius: 6.5
        color: "#0e0e0e"
        z: 100
        Rectangle {
          visible: Config.notch.camera
          anchors.centerIn: parent
          width: 5
          height: 5
          radius: 2.5
          color: "#1e1e1e"
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
          rightMargin: -1 - notchBg.xOffset
          Behavior on rightMargin {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 }
          }
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
          leftMargin: -1 + notchBg.xOffset
          Behavior on leftMargin {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 }
          }
        }
        color: Config.notch.backgroundColor
      }
    }
  }
  CustomShortcut {
    name: "toggleNotchActiveInstance"
    description: "Toggle notch active instance"
    onPressed: {
      root.activateInstance();
    }
  }
  CustomShortcut {
    name: "toggleNotchInfo"
    description: "Toggle notch info panel"
    onPressed: {
      return
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
    function activateInstance() {
      root.activateInstance();
    }
    function closeInstance() {
      root.closeNotchInstance(root.runningNotchInstances[root.runningNotchInstances.length - 1]);
    }
    function closeAllInstances() {
      root.closeNotchInstance();
    }
  }
}
