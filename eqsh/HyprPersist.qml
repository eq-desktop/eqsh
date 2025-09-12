import Quickshell.Io
import QtQuick
import qs.Config

Item {
    component Proc: Process { running: true }
    Proc {
        command: ["hyprctl", "keyword", "layerrule", "abovelock "+Config.notch.interactiveLockscreen+", ^eqsh:lock\$"]
    }
    Proc {
        command: ["hyprctl", "keyword", "layerrule", "blur, ^eqsh:blur\$"]
    }
    Proc {
        command: ["hyprctl", "keyword", "layerrule", "ignorezero, ^eqsh:blur\$"]
    }
    Proc {
        command: ["hyprctl", "keyword", "layerrule", "blurpopups, ^eqsh:blur\$"]
    }
}