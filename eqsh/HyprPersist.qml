import Quickshell.Io
import QtQuick
import qs.config
import qs.common as Common
import qs.services

Item {
    property bool isHyprland: CompositorService.isHyprland
    onIsHyprlandChanged: {
        if (isHyprland) {
            Common.Proc.runCommand("hyprpersist::al",  ["hyprctl", "keyword", "layerrule", "abovelock true, ^eqsh:lock\$"])
            Common.Proc.runCommand("hyprpersist::alb", ["hyprctl", "keyword", "layerrule", "abovelock true, ^eqsh:lock-blur\$"])
            Common.Proc.runCommand("hyprpersist::bl",  ["hyprctl", "keyword", "layerrule", "blur, ^eqsh:blur\$"])
            Common.Proc.runCommand("hyprpersist::blb", ["hyprctl", "keyword", "layerrule", "blur, ^eqsh:lock-blur\$"])
            Common.Proc.runCommand("hyprpersist::iz",  ["hyprctl", "keyword", "layerrule", "ignorezero, ^.*\$"])
            Common.Proc.runCommand("hyprpersist::bp",  ["hyprctl", "keyword", "layerrule", "blurpopups, ^.*\$"])
            Common.Proc.runCommand("hyprpersist::ms",  ["hyprctl", "keyword", "misc:session_lock_xray", "true"])

            // Indexing
            Common.Proc.runCommand("hyprpersist::no",  ["hyprctl", "keyword", "layerrule", "order -100, ^eqsh:notch\$"])
            Common.Proc.runCommand("hyprpersist::al",  ["hyprctl", "keyword", "layerrule", "abovelock true, ^eqsh:notch\$"])
            Common.Proc.runCommand("hyprpersist::sco",  ["hyprctl", "keyword", "layerrule", "order -101, ^eqsh:screencorners\$"])
            Common.Proc.runCommand("hyprpersist::scl",  ["hyprctl", "keyword", "layerrule", "abovelock true, ^eqsh:screencorners\$"])
        }
    }
}