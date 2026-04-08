import Quickshell.Io
import QtQuick
import qs.config
import qs.common as Common
import qs.services

Item {
    property bool isHyprland: CompositorService.isHyprland
    onIsHyprlandChanged: {
        if (isHyprland) {
            root.applyAll()
        }
    }
    QtObject {
        id: root

        // ─── Rule descriptor type ─────────────────────────────────────────
        // Each entry: { id, prop, match }
        //   id    – unique hyprpersist key suffix
        //   prop  – the layerrule property string (new 0.53+ syntax)
        //   match – the namespace pattern (RE2, no anchoring needed here)
        //
        // For misc keywords (not layerrule), use { id, misc: true, key, value }

        // ─── Rule groups ──────────────────────────────────────────────────

        readonly property var lockRules: [
            { id: "al",  prop: "above_lock 2", match: "eqsh:lock"      },
            { id: "alb", prop: "above_lock 2", match: "eqsh:lock-blur" },
        ]

        readonly property var blurRules: [
            { id: "bl",  prop: "blur on",        match: "eqsh:blur"      },
            { id: "blb", prop: "blur on",        match: "eqsh:lock-blur" },
        ]

        readonly property var globalRules: [
            { id: "iz",  prop: "ignore_alpha 0", match: ".*"             },
            { id: "bp",  prop: "blur_popups on", match: ".*"             },
        ]

        readonly property var ddmRules: [
            { id: "ddmo",  prop: "order -52",    match: "eqsh:ddm"      },
            { id: "ddmbo", prop: "order -53",    match: "eqsh:ddm-blur" },
            { id: "ddmbb", prop: "blur on",      match: "eqsh:ddm-blur" },
        ]

        readonly property var spotlightRules: [
            { id: "slb", prop: "blur on",           match: "eqsh:spotlight" },
            { id: "sla", prop: "ignore_alpha 0.2",  match: "eqsh:spotlight" },
            { id: "slo", prop: "order -50",         match: "eqsh:spotlight" },
        ]

        readonly property var indexingRules: [
            { id: "no",  prop: "order -100",     match: "eqsh:notch"        },
            { id: "nal", prop: "above_lock 2", match: "eqsh:notch"        },
            { id: "sco", prop: "order -101",     match: "eqsh:screencorners" },
            { id: "scl", prop: "above_lock 2", match: "eqsh:screencorners" },
        ]

        // misc keywords (not layerrule) — keep as a separate list
        readonly property var miscRules: [
            { id: "ms", key: "misc:session_lock_xray", value: "true" },
        ]

        // ─── All rule groups in application order ─────────────────────────
        readonly property var allLayerRuleGroups: [
            lockRules,
            blurRules,
            globalRules,
            ddmRules,
            spotlightRules,
            indexingRules,
        ]

        // ─── Application logic ────────────────────────────────────────────
        function applyAll() {
            // Apply layerrules
            for (const group of allLayerRuleGroups) {
                for (const rule of group) {
                    _applyLayerRule(rule)
                }
            }
            // Apply misc keywords
            for (const rule of miscRules) {
                _applyMisc(rule)
            }
        }

        function _applyLayerRule(rule) {
            // New 0.53+ inline syntax:
            //   hyprctl keyword layerrule "<prop>, match:namespace <match>"
            const value = `${rule.prop}, match:namespace ${rule.match}`
            Common.Proc.runCommand(
                `hyprpersist::${rule.id}`,
                ["hyprctl", "keyword", "layerrule", value]
            )
        }

        function _applyMisc(rule) {
            Common.Proc.runCommand(
                `hyprpersist::${rule.id}`,
                ["hyprctl", "keyword", rule.key, rule.value]
            )
        }
    }
}