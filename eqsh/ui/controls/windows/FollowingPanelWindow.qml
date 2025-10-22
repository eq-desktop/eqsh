import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs

import qs.config
PanelWindow {
    id: panelWindow
    Connections {
        target: Hyprland
        function onFocusedMonitorChanged() {
            panelWindow.screen = Quickshell.screens.filter(screen => screen.name == Hyprland.focusedMonitor.name)[0];
        }
    }
} 