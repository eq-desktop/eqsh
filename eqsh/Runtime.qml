pragma Singleton

import QtQuick
import Quickshell
import qs.config
import Quickshell.Io

Singleton {
    property string customAppName: ""
    property bool   locked: false
    property int    notchHeight: 0
    property bool   settingsOpen: false
    property bool   spotlightOpen: false
    property bool   launchpadOpen: false
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