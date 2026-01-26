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
import qs.ui.controls.auxiliary.notch
import qs.ui.controls.providers
import qs.ui.controls.advanced
import qs.ui.controls.primitives

Scope {
  id: root
  property bool shown: false
  property bool appInFullscreen: HyprlandExt.appInFullscreen
  property bool forceHide: Config.notch.autohide
  property bool inFullscreen: shown ? forceHide : appInFullscreen || forceHide
  property int    defaultWidth: Config.notch.minWidth
  property int    defaultHeight: Config.notch.height
  property int    topMargin: Config.notch.islandMode ? Config.notch.margin : -1
  property int    width: Config.notch.minWidth
  property int    height: Config.notch.height
  property var    notch: root

  property list<var> runningNotchInstances: []

  property bool   locked: Runtime.locked
  property var    focusedRunningInstance: runningNotchInstances.length > 0 ? runningNotchInstances[runningNotchInstances.length -1] : null

  property bool firstTimeRunning: Config.account.firstTimeRunning
  property bool loadedConfig: Config.loaded
  property bool dndMode: NotificationDaemon.popupInhibited
  readonly property bool batCharging: UPower.onBattery ? (UPower.displayDevice.state == UPowerDeviceState.Charging) : true

  property var details: QtObject {
    property list<string> supportedVersions: ["0.1.2", "Elephant-1"]
    property string currentVersion: "Elephant-1"
  }

  property var notchRegistry: {
    "welcome": { path: "Welcome.qml" },
    "charging": { path: "Charging.qml" },
    "dnd": { path: "DND.qml" },
    "lock": { path: "Lock.qml" },
    "audio": { path: "Audio.qml" }
  }

  signal newNotchInstance(string code, string name, int id)

  function launchByRId(id) {
    const app = notchRegistry[id];
    if (app) {
      fileViewer.path = Quickshell.shellDir + "/ui/components/notch/instances/" + app.path;
      return root.notchInstance(fileViewer.text(), id);
    }
  }

  function idIsRunning(id) {
    if (root.runningNotchInstances.length === 0) return false;
    return root.runningNotchInstances.some(instance => instance.meta.id === id);
  }

  function getNotchInstanceById(id) {
    return root.runningNotchInstances.find(instance => instance.meta.id === id);
  }


  property bool audioPlaying: MusicPlayerProvider.isPlaying
  property var lockId: null

  signal activateInstance()
  signal informInstance()
  signal focusedInstance(var instance)

  FileView {
    id: fileViewer
    path: Quickshell.shellDir + "/ui/components/notch/instances/Lock.qml"
    blockAllReads: true
  }

  onDndModeChanged: launchByRId("dnd")
  onBatChargingChanged: if (batCharging) launchByRId("charging")
  onLockedChanged: {
    if (locked) {
      launchByRId("lock")
    } else {
      root.closeNotchInstance("lock")
    }
  }

  Component.onCompleted: {
    launchByRId("audio")
  }

  function getIcon(path) {
    if (path.startsWith("builtin:")) {
      return Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/notch/" + path.substring(8) + ".svg")
    } else {
      return Qt.resolvedUrl(path)
    }
  }

  function notchInstance(code, name) {
    const id = Math.floor(Math.random() * 1000000)
    root.newNotchInstance(code, name, id)
    return id;
  }

  function closeNotchInstance(name) {
    let new_notch_instances = root.runningNotchInstances.filter(instance => instance.meta.name !== name || instance.immortal == true);
    root.runningNotchInstances = new_notch_instances;
  }
  function closeNotchInstanceById(id) {
    let new_notch_instances = root.runningNotchInstances.filter(instance => instance.meta.id !== id || instance.immortal == true);
    root.runningNotchInstances = new_notch_instances;
  }
  function closeNotchInstanceFocused() {
    if (root.focusedRunningInstance === null) return;
    root.closeNotchInstanceById(root.focusedRunningInstance.meta.id);
  }

  function closeAllNotchInstances() {
    root.runningNotchInstances.forEach(instance => {
      root.closeNotchInstanceById(instance.meta.id);
    });
  }

  onRunningNotchInstancesChanged: {
    if (runningNotchInstances.length === 0) return;
    // get current instance
    const currentInstance = runningNotchInstances[runningNotchInstances.length - 1];
    root.focusedInstance(currentInstance);
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
        Behavior on opacity {
          NumberAnimation { duration: 200 }
        }
        transform: Translate {
          x: notchBg.xOffset
          Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 }
          }
        }
      }
      CFRect {
        id: notchBgBorder
        anchors {
          top: parent.top
          topMargin: inFullscreen ? -(root.height + topMargin + 5) : root.topMargin
          Behavior on topMargin {
            NumberAnimation { duration: Config.notch.hideDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
          }
          left: notchBg.left
          right: notchBg.right
          bottom: notchBg.bottom
          margins: -1.5
        }
        scale: 1
        transform: Translate {
          x: notchBg.xOffset
          Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 }
          }
        }
        topLeftRadius: Config.notch.islandMode ? Config.notch.radius : 0
        topRightRadius: Config.notch.islandMode ? Config.notch.radius : 0
        bottomLeftRadius: Config.notch.radius
        bottomRightRadius: Config.notch.radius
        color: "#20ffffff"
      }
      CFRect {
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
        scale: 1
        onScaleChanged: {
          panelWindow.mask.changed();
        }
        property int xOffset: 0
        transform: Translate {
          x: notchBg.xOffset
          Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 }
          }
        }
        onXOffsetChanged: {
          panelWindow.mask.changed();
        }


        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 } }
        Behavior on implicitWidth { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 } }
        Behavior on implicitHeight { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 } }
        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 } }
        Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 } }
        width: root.width
        height: root.height
        topLeftRadius: Config.notch.islandMode ? Config.notch.radius : 0
        topRightRadius: Config.notch.islandMode ? Config.notch.radius : 0
        bottomLeftRadius: Config.notch.radius
        bottomRightRadius: Config.notch.radius

        onImplicitWidthChanged: {
          panelWindow.mask.changed();
        }
        onHeightChanged: {
          panelWindow.mask.changed();
          Runtime.notchHeight = height;
        }

        //MouseArea {
        //  anchors.fill: parent
        //  hoverEnabled: true
        //  scrollGestureEnabled: true
        //  onEntered: {
        //    notchBg.implicitWidth = root.width + 10
        //    notchBg.implicitHeight = root.height + 5
        //    shadowOpacity = 0.5
        //  }
        //  onExited: {
        //    if (root.runningNotchInstances.length === 0) {
        //      notchBg.implicitWidth = minWidth
        //      notchBg.implicitHeight = Config.notch.height
        //      shadowOpacity = 0
        //    }
        //  }
        //  enabled: root.runningNotchInstances.length === 0
        //}
        color: Config.notch.backgroundColor
        Connections {
          target: root
          function onNewNotchInstance(code, name, id) {
            Logger.d("Notch", "New notch instance created", id, "of name," + name)
            let obj = Qt.createQmlObject(code, notchBg)
            obj.screen = panelWindow
            obj.meta.inCreation = true
            obj.meta.id = id
            obj.meta.name = name
            runningNotchInstances.push(obj);
            obj.meta.inCreation = false
            const instanceVersion = obj.details.version
            if (!root.details.supportedVersions.includes(instanceVersion)) {
              Logger.w("Notch", "The notch app version (" + instanceVersion + ") is not supported. Supported versions are: " + root.details.supportedVersions.join(", ") + ". The current version is: " + root.details.currentVersion + ". The notch app might not work as expected.")
            }
          }
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
          leftMargin: -1+notchBg.xOffset
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
      root.informInstance();
    }
  }
  IpcHandler {
    target: "notch"
    function instance(code: string) {
      Logger.d("IPC::Notch", "Notch instance requested");
      root.notchInstance(code);
    }
    function activateInstance() {
      Logger.d("IPC::Notch", "Activating notch instance", root.meta.id);
      root.activateInstance();
    }
    function informInstance() {
      Logger.d("IPC::Notch", "Informing notch instance", root.meta.id);
      root.informInstance();
    }
    function closeInstance() {
      Logger.d("IPC::Notch", "Closing notch instance", root.meta.id);
      root.closeNotchInstanceFocused();
    }
    function closeAllInstances() {
      Logger.d("IPC::Notch", "Closing all notch instances");
      root.closeAllNotchInstances();
    }
  }
}
