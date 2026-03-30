/*
src: https://github.com/AvengeMedia/DankMaterialShell/blob/master/quickshell/Services/CompositorService.qml
Thanks to AvengeMedia@dms for the original implementation.

This is a slightly modified version of the original
*/

pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common // Looking to migrate things from / to /common e.g. Logger.qml
import qs

Singleton {
    id: root

    property bool isHyprland: false
    property bool isNiri: false
    property string compositor: "unknown"

    readonly property string hyprlandSignature: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")
    readonly property string niriSocket: Quickshell.env("NIRI_SOCKET")
    property bool useNiriSorting: isNiri && NiriService

    signal event(var event)

    function getFocusedScreen() {
        let screenName = "";
        if (isHyprland && Hyprland.focusedWorkspace?.monitor)
            screenName = Hyprland.focusedWorkspace.monitor.name;
        else if (isNiri && NiriService.currentOutput)
            screenName = NiriService.currentOutput;

        if (!screenName)
            return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;

        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === screenName)
                return Quickshell.screens[i];
        }
        return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
    }

    Connections {
        target: isHyprland ? Hyprland : null
        enabled: isHyprland

        function onRawEvent(event) {
            if (event.name === "openwindow" || event.name === "closewindow" || event.name === "movewindow" || event.name === "movewindowv2" || event.name === "workspace" || event.name === "workspacev2" || event.name === "focusedmon" || event.name === "focusedmonv2" || event.name === "activewindow" || event.name === "activewindowv2" || event.name === "changefloatingmode" || event.name === "fullscreen" || event.name === "moveintogroup" || event.name === "moveoutofgroup") {
                root.event(event);
                try {
                    Hyprland.refreshToplevels();
                    Hyprland.refreshMonitors();
                } catch (e) {
                    Logger.e("CompositorService", "Failed to refresh Hyprland toplevels:", e);
                }
            }
        }
    }

    Component.onCompleted: {
        detectCompositor();
    }


    function _get(o, path, fallback) {
        try {
            let v = o;
            for (let i = 0; i < path.length; i++) {
                if (v === null || v === undefined)
                    return fallback;
                v = v[path[i]];
            }
            return (v === undefined || v === null) ? fallback : v;
        } catch (e) {
            return fallback;
        }
    }

    function filterCurrentWorkspace(toplevels, screen) {
        if (useNiriSorting)
            return NiriService.filterCurrentWorkspace(toplevels, screen);
        if (isHyprland)
            return filterHyprlandCurrentWorkspaceSafe(toplevels, screen);
        return toplevels;
    }

    function filterCurrentDisplay(toplevels, screenName) {
        if (!toplevels || toplevels.length === 0 || !screenName)
            return toplevels;
        if (useNiriSorting)
            return NiriService.filterCurrentDisplay(toplevels, screenName);
        if (isHyprland)
            return filterHyprlandCurrentDisplaySafe(toplevels, screenName);
        return toplevels;
    }

    function filterHyprlandCurrentDisplaySafe(toplevels, screenName) {
        if (!toplevels || toplevels.length === 0 || !Hyprland.toplevels)
            return toplevels;

        let monitorWindows = new Set();
        try {
            const hy = Array.from(Hyprland.toplevels.values);
            for (const t of hy) {
                const mon = _get(t, ["monitor", "name"], "");
                if (mon === screenName && t.wayland)
                    monitorWindows.add(t.wayland);
            }
        } catch (e) {}

        return toplevels.filter(w => monitorWindows.has(w));
    }

    function filterHyprlandCurrentWorkspaceSafe(toplevels, screenName) {
        if (!toplevels || toplevels.length === 0 || !Hyprland.toplevels)
            return toplevels;

        let currentWorkspaceId = null;
        try {
            if (Hyprland.monitors) {
                const monitor = Hyprland.monitors.values.find(m => m.name === screenName);
                if (monitor)
                    currentWorkspaceId = _get(monitor, ["activeWorkspace", "id"], null);
            }

            if (currentWorkspaceId === null) {
                const hy = Array.from(Hyprland.toplevels.values);
                for (const t of hy) {
                    const mon = _get(t, ["monitor", "name"], "");
                    const wsId = _get(t, ["workspace", "id"], null);
                    const active = !!_get(t, ["activated"], false);
                    if (mon === screenName && wsId !== null) {
                        if (active) {
                            currentWorkspaceId = wsId;
                            break;
                        }
                        if (currentWorkspaceId === null)
                            currentWorkspaceId = wsId;
                    }
                }
            }

            if (currentWorkspaceId === null && Hyprland.workspaces) {
                const wss = Array.from(Hyprland.workspaces.values);
                const focusedId = _get(Hyprland, ["focusedWorkspace", "id"], null);
                for (const ws of wss) {
                    const monName = _get(ws, ["monitor", "name"], "");
                    const wsId = _get(ws, ["id"], null);
                    if (monName === screenName && wsId !== null) {
                        if (focusedId !== null && wsId === focusedId) {
                            currentWorkspaceId = wsId;
                            break;
                        }
                        if (currentWorkspaceId === null)
                            currentWorkspaceId = wsId;
                    }
                }
            }
        } catch (e) {
            Logger.w("CompositorService", "workspace snapshot failed: " + e);
        }

        if (currentWorkspaceId === null)
            return toplevels;

        let map = new Map();
        try {
            const hy = Array.from(Hyprland.toplevels.values);
            for (const t of hy) {
                const wsId = _get(t, ["workspace", "id"], null);
                if (t && t.wayland && wsId !== null)
                    map.set(t.wayland, wsId);
            }
        } catch (e) {}

        return toplevels.filter(w => map.get(w) === currentWorkspaceId);
    }

    Timer {
        id: compositorInitTimer
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            detectCompositor();
        }
    }

    function detectCompositor() {
        if (hyprlandSignature && hyprlandSignature.length > 0 && !niriSocket) {
            isHyprland = true;
            isNiri = false;
            compositor = "hyprland";
            Logger.i("CompositorService", "Detected Hyprland");
            return;
        }

        if (niriSocket && niriSocket.length > 0) {
            Proc.runCommand("niriSocketCheck", ["test", "-S", niriSocket], (output, exitCode) => {
                if (exitCode === 0) {
                    isNiri = true;
                    isHyprland = false;
                    compositor = "niri";
                    Logger.i("CompositorService", "Detected Niri with socket: " + niriSocket);
                }
            }, 0);
            return;
        }
    }

    function powerOffMonitors() {
        if (isNiri)
            return NiriService.powerOffMonitors();
        if (isHyprland)
            return// Hyprland.dispatch("dpms off");
        Logger.w("CompositorService", "Cannot power off monitors, unknown compositor");
    }

    function powerOnMonitors() {
        if (isNiri)
            return NiriService.powerOnMonitors();
        if (isHyprland)
            return// Hyprland.dispatch("dpms on");
        Logger.w("CompositorService", "Cannot power on monitors, unknown compositor");
    }
}