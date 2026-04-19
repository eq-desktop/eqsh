import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs
import qs.services
import qs.config

PanelWindow {
    id: panelWindow
    screen: {
        let result;
        if (CompositorService.isHyprland)
            result = Quickshell.screens.find(screen => screen.name == (Hyprland.focusedMonitor?.name || ""))
        if (CompositorService.isNiri)
            result = Quickshell.screens.find(screen => screen.name == NiriService.currentOutput)
        return result ? result : Quickshell.screens[0]
    }
} 