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
            // if appId = org.Quickshell then use the title
            root.applicationName = SPAppName.getAppName(window.appId);
            if (window.appId == "org.quickshell") {
                root.applicationName = window.title;
            }
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
                    let appId = event.data.split(",")[0]
                    let appTitle = event.data.split(",")[1]
                    root.applicationName = SPAppName.getAppName(appId);
                    if (appId == "org.quickshell") {
                        root.applicationName = appTitle;
                    }
                    if (root.applicationName == "") {
                        root.appInFullscreen = false;
                    }
                    break;
                }
            }
        }
    }
}