import Quickshell.Io
import QtQuick
import qs.config

Item {
    component Proc: Process { running: true }
    Proc {
        command: ["hyprctl", "keyword", "layerrule", "abovelock "+Config.notch.interactiveLockscreen+", ^eqsh:lock\$"]
    }
    Proc {
        command: ["hyprctl", "keyword", "layerrule", "blur, ^eqsh:blur\$"]
    }
    Proc {
        command: ["hyprctl", "keyword", "layerrule", "ignorezero, ^.*$"]
    }
    Proc {
        command: ["hyprctl", "keyword", "layerrule", "blurpopups, ^.*$"]
    }
}