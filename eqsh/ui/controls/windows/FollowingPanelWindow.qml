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
        if (CompositorService.isHyprland)
            return Quickshell.screens.find(screen => screen.name == Hyprland.focusedMonitor.name)
        if (CompositorService.isNiri)
            return Quickshell.screens.find(screen => screen.name == NiriService.currentOutput)
        return Quickshell.screens[0]
    }
} 