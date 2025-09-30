pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property string customAppName: ""
    property bool   locked: false
    property int    notchHeight: 0
    property bool   settingsOpen: false
    property bool   spotlightOpen: false
    property bool   launchpadOpen: false
    Process {
        command: ["ls", Quickshell.shellDir + "/runtime/config.json"]
        running: true; stderr: StdioCollector { onStreamFinished: if (this.text != "") Quickshell.execDetached(["touch", Quickshell.shellDir + "/runtime/config.json"]); }
    }
    Process {
        command: ["ls", Quickshell.shellDir + "/runtime/notifications.json"]
        running: true; stderr: StdioCollector { onStreamFinished: if (this.text != "") Quickshell.execDetached(["touch", Quickshell.shellDir + "/runtime/notifications.json"]); }
    }
    Process {
        command: ["ls", Quickshell.shellDir + "/runtime/widgets.json"]
        running: true; stderr: StdioCollector { onStreamFinished: if (this.text != "") Quickshell.execDetached(["touch", Quickshell.shellDir + "/runtime/widgets.json"]); }
    }
    Process {
        command: ["ls", Quickshell.shellDir + "/runtime/runtime"]
        running: true; stderr: StdioCollector { onStreamFinished: if (this.text != "") Quickshell.execDetached(["touch", Quickshell.shellDir + "/runtime/runtime"]); }
    }
    FileView {
        id: runtimeF
        path: Quickshell.shellDir + "/runtime/runtime"
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