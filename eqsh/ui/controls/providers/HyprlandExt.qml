pragma Singleton

import Quickshell.Hyprland
import Quickshell
import QtQuick
import qs.core.foundation

Singleton {
    id: root
    property bool appInFullscreen: false
    property string applicationName: ""
    Connections {
        target: Hyprland
        function onActiveToplevelChanged(event) {
            const window = Hyprland.activeToplevel.wayland;
            if (window == null) {
                root.applicationName = "";
                root.appInFullscreen = false;
                return;
            }
            root.applicationName = SPAppName.getAppName(window.appId);
            root.appInFullscreen = window.fullscreen;
        }
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
                    if (root.applicationName == "") {
                        root.appInFullscreen = false;
                    }
                    break;
                }
            }
        }
    }
}