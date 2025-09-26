pragma Singleton

import Quickshell.Hyprland
import Quickshell
import QtQuick
import qs.Core.Foundation

Singleton {
    id: root
    property bool appInFullscreen: false
    property string applicationName: ""
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            let eventName = event.name;
            switch (eventName) {
                case "fullscreen": {
                    root.appInFullscreen = event.data == "1";
                    break;
                }
                case "activewindow":
                case "closewindow": {
                    root.applicationName = SPAppName.getAppName(event.data.split(",")[0]);
                    break;
                }
            }
        }
    }
}