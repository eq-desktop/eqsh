pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property string customAppName: ""
    property bool   locked: false
    Process {
        command: ["ls", Quickshell.shellDir + "/Runtime/config.json"]
        running: true; stderr: StdioCollector { onStreamFinished: if (this.text != "") Quickshell.execDetached(["touch", Quickshell.shellDir + "/Runtime/config.json"]); }
    }
    Process {
        command: ["ls", Quickshell.shellDir + "/Runtime/notifications.json"]
        running: true; stderr: StdioCollector { onStreamFinished: if (this.text != "") Quickshell.execDetached(["touch", Quickshell.shellDir + "/Runtime/notifications.json"]); }
    }
    Process {
        command: ["ls", Quickshell.shellDir + "/Runtime/widgets.json"]
        running: true; stderr: StdioCollector { onStreamFinished: if (this.text != "") Quickshell.execDetached(["touch", Quickshell.shellDir + "/Runtime/widgets.json"]); }
    }
    Process {
        command: ["ls", Quickshell.shellDir + "/Runtime/runtime"]
        running: true; stderr: StdioCollector { onStreamFinished: if (this.text != "") Quickshell.execDetached(["touch", Quickshell.shellDir + "/Runtime/runtime"]); }
    }
    FileView {
        id: runtimeF
        path: Quickshell.shellDir + "/Runtime/runtime"
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