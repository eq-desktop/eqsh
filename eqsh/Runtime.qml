pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.config
import Quickshell.Io

Singleton {
    property list<string> activeCCSW: [] // camera, microphone, audio
    // fuse /dev/video0

    property string customAppName: ""
    property bool   locked: false
    property int    notchHeight: 0
    property bool   settingsOpen: false
    property bool   aboutOpen: false
    property bool   spotlightOpen: false
    property bool   aiOpen: false
    property bool   launchpadOpen: false
    property bool   showScrn: false
    property bool   widgetEditMode: false

    property var bluetoothAdapter: Bluetooth.defaultAdapter
    // ---- Function subscription system ----
    property var subscribers: ({}) // map of name -> function

    /**
     * Register a function under a name.
     * Example: Global.subscribe("openSettings", () => settingsOpen = true)
     */
    function subscribe(name, func) {
        if (typeof func === "function") {
            subscribers[name] = func
        } else {
            Logger.w("Global::subscribe", "Tried to subscribe non-function:", name)
        }
    }

    /**
     * Unregister a function
     */
    function unsubscribe(name) {
        delete subscribers[name]
    }

    /**
     * Run a subscribed function by name, with optional arguments
     * Example: Global.run("openSettings", true)
     */
    function run(name, ...args) {
        if (subscribers[name]) {
            return subscribers[name].apply(this, args)
        } else {
            Logger.w("Global::run", "No subscriber found for", name)
        }
    }
    Component.onCompleted: {
        Quickshell.execDetached(["mkdir", "-p", Directories.runtimeDir]);
    }
    Process {
        command: ["ls", Directories.runtimeDir + "/config.json"]
        running: true; stderr: StdioCollector { onStreamFinished: if (this.text != "") Quickshell.execDetached(["touch", Directories.runtimeDir + "/config.json"]); }
    }
    Process {
        command: ["ls", Directories.runtimeDir + "/notifications.json"]
        running: true; stderr: StdioCollector { onStreamFinished: if (this.text != "") Quickshell.execDetached(["touch", Directories.runtimeDir + "/notifications.json"]); }
    }
    Process {
        command: ["ls", Directories.runtimeDir + "/widgets.json"]
        running: true; stderr: StdioCollector { onStreamFinished: if (this.text != "") Quickshell.execDetached(["touch", Directories.runtimeDir + "/widgets.json"]); }
    }
    Process {
        command: ["ls", Directories.runtimeDir + "/runtime"]
        running: true; stderr: StdioCollector { onStreamFinished: if (this.text != "") Quickshell.execDetached(["touch", Directories.runtimeDir + "/runtime"]); }
    }
    FileView {
        id: runtimeF
        path: Directories.runtimeDir + "/runtime"
        blockLoading: true
        JsonAdapter {
            id: runtimeAd
            property string processId: Quickshell.processId
        }
        Component.onCompleted: {
            runtimeAd.processId = Quickshell.processId
            writeAdapter()
        }
    }
}