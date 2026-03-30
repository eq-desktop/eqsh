import QtQuick.Controls.Fusion
import Quickshell.Wayland
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
  property var stateMachine: ({
  })
  property var state: {
    "id": null,
    "state": "null"
  }

  function assignState(state) {
    if (state.id === null) return;
    if (!root.stateMachine[state.id]) root.stateMachine[state.id] = {}
    root.stateMachine[state.id][state.state] = {
      width: state.width || 100,
      height: state.height || 28,
      offset: state.offset || { x: 0, y: 0 },
      curve: state.curve || [1, 1, 1],
      duration: state.duration || 300,
      easing: state.easing || Easing.OutBack
    };
  }

  function clearStates(id) {
    delete stateMachine[id];

    const ids = Object.keys(root.stateMachine)
  }

  property bool   locked: Runtime.locked
  property var    focusedRunningInstance: runningNotchInstances.length > 0 ? runningNotchInstances[runningNotchInstances.length -1] : null

  property bool firstTimeRunning: Config.account.firstTimeRunning
  property bool loadedConfig: Config.loaded
  property bool dndMode: NotificationDaemon.popupInhibited
  readonly property bool batCharging: UPower.onBattery ? (UPower.displayDevice.state == UPowerDeviceState.Charging) : true

  property var details: QtObject {
    property list<string> supportedVersions: ["0.1.2", "Elephant-1", "Elephant-2"]
    property string currentVersion: "Elephant-2"
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

  property var pluginsLoaded: Plugins.loaded

  onPluginsLoadedChanged: {
    if (pluginsLoaded) {
      // Plugins have been loaded, you can now launch apps from plugins
      //launchFromPlugin("notch-apps", "test-app");
    }
  }

  function launchFromPlugin(pluginId, name) {
    // go through Plugins.loadedPlugins
    Logger.d("Plugins", "Looking for plugin:", pluginId, "and app:", name);
    for (const kavo of Plugins.loadedPlugins) {
      const plugin = kavo.kavo.nav("plugin")
      const pluginId = Object.keys(plugin.properties)[0];
      Logger.d("Plugins", "Plugin: " + pluginId + " Loading:", plugin.f("meta").f("name").value);
      if (pluginId === pluginId) {
        let notchApps = plugin.fA("notchapplication")
        for (let i = 0; i < notchApps.length; i++) {
          let app = notchApps[i];
          let appMeta = app.f("meta");
          let appId = appMeta.f("id").value;
          if (appId === name) {
            Logger.d("Plugins", "Plugin: " + pluginId + " Loading app: " + appMeta.f("name").value + " ID: " + appId);
            return root.notchInstance(app.f("code").children[0]._obj, appMeta.f("name").value);
          }
        }
      }
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
    root.runningNotchInstances.forEach(instance => {
      if (instance.meta.name === name && !instance.immortal) {
        root.clearStates(instance.meta.id);
      }
    });
    root.runningNotchInstances = new_notch_instances;
  }
  function closeNotchInstanceById(id) {
    let new_notch_instances = root.runningNotchInstances.filter(instance => instance.meta.id !== id || instance.immortal == true);
    root.runningNotchInstances.forEach(instance => {
      if (instance.meta.id === id && !instance.immortal) {
        root.clearStates(id);
      }
    });
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
      WlrLayershell.namespace: "eqsh:notch"
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
      UILiquid {
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
        property int xOffset: 0
        transform: Translate {
          x: notchBg.xOffset
          Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 }
          }
        }

        RectangularShadow {
          anchors.fill: parent
          radius: 30
          blur: 40
          spread: 10
          opacity: 0.5
          Behavior on opacity {
            NumberAnimation { duration: 200 }
          }
        }
        CFRect {
          id: notchBgBorder
          anchors {
            fill: parent
            margins: -1.5
          }
          scale: 1
          topLeftRadius: Config.notch.islandMode ? Config.notch.radius : 0
          topRightRadius: Config.notch.islandMode ? Config.notch.radius : 0
          bottomLeftRadius: Config.notch.radius
          bottomRightRadius: Config.notch.radius
          color: notchBg.borderColor
        }

        property string borderColor: "#20ffffff"

        function updateSizing() {
            if (root.state.id in root.stateMachine) {
              const state = root.stateMachine[root.state.id][root.state.state];
              if (state) {
                //notchBg.width = state.width;
                //notchBg.height = state.height;
                notchBg.sizeToV2(
                  state.width,
                  state.height,
                  Qt.point(state.offset.x, state.offset.y),
                  Qt.vector3d(state.curve[0], state.curve[1], state.curve[2]),
                  state.duration,
                  state.easing
                );
              }
            }
        }

        Connections {
          target: root
          function onStateChanged() {
            notchBg.updateSizing();
          }
          function onFocusedInstance() {
            notchBg.updateSizing();
          }
        }

        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 } }
        Behavior on implicitWidth { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 } }
        Behavior on implicitHeight { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 } }
        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 } }
        Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 } }
        onXOffsetChanged: {
          panelWindow.mask.changed();
        }
        scale: 1
        onScaleChanged: {
          panelWindow.mask.changed();
        }
        CFRect {
          id: notchBgInternal
          anchors.fill: parent
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
        z: 99
        Rectangle {
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
  Component.onCompleted: {
    launchByRId("audio")
    Ipc.mixin("eqdesktop.notch", "activeInstance", () => {
      Logger.d("IPC::Notch", "Activating notch instance");
      root.activeInstance()
    });
    Ipc.mixin("eqdesktop.notch", "informInstance", () => {
      Logger.d("IPC::Notch", "Informing notch instance");
      root.informInstance()
    });
    Ipc.mixin("eqdesktop.notch", "instance", (code) => {
      Logger.d("IPC::Notch", "Notch instance requested");
      root.notchInstance(code);
    });
    Ipc.mixin("eqdesktop.notch", "closeInstance", () => {
      Logger.d("IPC::Notch", "Closing notch instance");
      root.closeNotchInstanceFocused();
    });
    Ipc.mixin("eqdesktop.notch", "closeAllInstances", () => {
      Logger.d("IPC::Notch", "Closing all notch instances");
      root.closeAllNotchInstances();
    });
  }
}
