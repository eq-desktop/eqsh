import Quickshell.Io
import QtQuick
import qs.config

Item {
    Process {
        id: hyprctl
        command: ["hyprctl", "keyword", "layerrule", "abovelock "+Config.notch.interactiveLockscreen+", ^eqsh:lock\$"]
        running: true
    }
}