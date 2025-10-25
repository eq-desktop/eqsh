import Quickshell.Io
import QtQuick
import qs.config

Item {
    component Proc: Process { running: true }
    Proc {
        property bool interactiveLockscreen: Config.notch.interactiveLockscreen
        onInteractiveLockscreenChanged: {
            running = true
        }
        command: ["hyprctl", "keyword", "layerrule", "abovelock "+Config.notch.interactiveLockscreen+", ^eqsh:lock\$"]
    }
    Proc {
        property bool interactiveLockscreen: Config.notch.interactiveLockscreen
        onInteractiveLockscreenChanged: {
            running = true
        }
        command: ["hyprctl", "keyword", "layerrule", "abovelock "+Config.notch.interactiveLockscreen+", ^eqsh:lock-blur\$"]
    }
    Proc {
        command: ["hyprctl", "keyword", "layerrule", "blur, ^eqsh:blur\$"]
    }
    Proc {
        command: ["hyprctl", "keyword", "layerrule", "blur, ^eqsh:lock-blur\$"]
    }
    Proc {
        command: ["hyprctl", "keyword", "layerrule", "ignorezero, ^.*$"]
    }
    Proc {
        command: ["hyprctl", "keyword", "layerrule", "blurpopups, ^.*$"]
    }
}