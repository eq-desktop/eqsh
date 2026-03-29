import Quickshell.Io
import QtQuick
import qs.config

Item {
    component Proc: Process { running: true }
    Proc {
        running: true
        command: ["hyprctl", "keyword", "layerrule", "abovelock true, ^eqsh:lock\$"]
    }
    Proc {
        running: true
        command: ["hyprctl", "keyword", "layerrule", "abovelock true, ^eqsh:lock-blur\$"]
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
    Proc {
        command: ["hyprctl", "keyword", "misc:session_lock_xray", "true"]
    }
}