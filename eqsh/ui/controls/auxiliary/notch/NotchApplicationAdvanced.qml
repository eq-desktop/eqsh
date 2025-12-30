import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.config
import qs.core.system
import qs.ui.controls.providers
import QtQuick.VectorImage
import QtQuick.Effects

Item {
    id: root
    property var screen
    property Details details: Details {}
    property Meta meta: Meta {}
    property bool onlyActive: false
    property bool isActive: onlyActive
    property string notchState: isActive ? "active" : "indicative" // indicative, active
    property bool   noMode: onlyActive
    property Component indicative: null
    property Component active: null
    property int _pullHeight: 0
    property bool immortal: false
    property real _xScaleIndicativeLoader: 1
    z: 99

    Behavior on _xScaleIndicativeLoader { NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutBack; easing.overshoot: 1 } }

    //Rectangle {
    //    id: notchBg
    //    anchors.fill: parent
    //    color: Config.notch.backgroundColor
    //    topLeftRadius: Config.notch.islandMode ? Config.notch.radius : 0
    //    topRightRadius: Config.notch.islandMode ? Config.notch.radius : 0
    //    bottomLeftRadius: Config.notch.radius
    //    bottomRightRadius: Config.notch.radius
    //}

    component Meta: QtObject {
        property int    width: notch.defaultWidth
        property int    height: notch.defaultHeight
        property int    indicativeWidth: notch.defaultWidth
        property int    indicativeHeight: notch.defaultHeight
        property int    xOffset: 0
        property real   startScale: 1
        property real   startOpacity: 0
        property int    animDuration: 500
        property int    closeAfterMs: -1
        property string name: ""
        property int    shrinkMs: 125
        property int    scrollHeight: 50
        property var    shadowOpacity: undefined
        property var    id: null
    }

    component Details: QtObject {
        property string version: "0.1.2"
        /*deprecated*/ property string shadowColor: "#000000"
        property string appType: "indicator"
    }

    anchors.fill: parent
    opacity: meta.startOpacity
    scale: meta.startScale

    function activate() {
        if (notchState !== "active") {
            notchState = "active"
        }
    }

    function setIndicative() {
        if (notchState !== "indicative") {
            notchState = "indicative"
        }
    }

    onNotchStateChanged: {
        if (notchState === "active") {
            notch.setSize(meta.width, meta.height, false, root.meta.id)
        } else {
            notch.setSize(meta.indicativeWidth, meta.indicativeHeight, false, root.meta.id, true)
        }
    }

    Component.onCompleted: {
        opacity = 1
        scale = 1
        if (notchState === "active") {
            notch.setSize(meta.width, meta.height, false, root.meta.id)
        } else {
            notch.setSize(meta.indicativeWidth, meta.indicativeHeight, false, root.meta.id)
        }
    }

    Timer {
        id: closeTimer
        interval: meta.animDuration
        running: false
        onTriggered: notch.closeNotchInstance(meta.id)
    }

    function closeMe() {
        notchState = "closed"
        closing()
        closeTimer.running = true
    }

    signal closing()

    Behavior on opacity {
        NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
    }
    Behavior on scale {
        NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
    }

    property var runningNotchInstances: notch.runningNotchInstances
    onRunningNotchInstancesChanged: {
        if (meta.id !== null && !runningNotchInstances.includes(meta.id)) {
            if (immortal) return;
            shadowOpacity = 0
            root.destroy()
        }
    }

    Timer {
        interval: meta.closeAfterMs
        running: meta.closeAfterMs !== -1
        repeat: false
        onTriggered: closeMe()
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        preventStealing: true
        scrollGestureEnabled: true
        onEntered: {
            exitTimer.running = false
            shadowOpacity = 0.5
        }
        onExited: {
            exitTimer.running = true
            shadowOpacity = 0
            root._pullHeight = 0
            root.scaleY = 1
        }
        onWheel: (wheel) => {
            let delta = Math.min(meta.scrollHeight, Math.round(wheel.angleDelta.y/50))
            root._pullHeight = Math.max(-40, root._pullHeight + delta)
            if (wheel.angleDelta.y === 0) {
                root._pullHeight = 0
            }
            activeLoader.scaleYN = Math.min(1.2, Math.max(0.9, 1 + (-0.9, -(root._pullHeight/(meta.scrollHeight*2)))))
            if (root._pullHeight < -30) {
                root._pullHeight = 0
                root.setIndicative()
            }
        }
        enabled: !root.noMode
        Loader {
            id: activeLoader
            anchors.fill: parent
            sourceComponent: root.active
            property real scaleY: root.notchState === "active" || root.notchState === "closed" ? 1 : 1.5
            property real scaleYN: 1
            opacity: root.notchState === "active" ? 1 : 0
            transform: Scale {
                xScale: 1
                yScale: activeLoader.scaleYN !== 1 ? activeLoader.scaleYN : activeLoader.scaleY
                origin.y: activeLoader.height
                Behavior on yScale { NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutCubic } }
            }
            visible: opacity > 0
            layer.enabled: true
            layer.effect: MultiEffect {
                id: blurActive
                blurEnabled: true
                blur: 1
                blurMax: 64
                Component.onCompleted: {
                    blur = root.notchState === "active" || root.notchState === "closed" ? 0 : 1
                }
                Connections {
                    target: root
                    function onClosing() {
                        blurActive.blur = 1
                    }
                    function onNotchStateChanged() {
                        blurActive.blur = root.notchState === "active" || root.notchState === "closed" ? 0 : 1
                    }
                }
                Behavior on blur { NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutCubic } }
            }
            Behavior on opacity { NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutCubic } }
        }

        Loader {
            id: indicativeLoader
            anchors.fill: parent
            sourceComponent: root.indicative
            transform: Scale {
                xScale: root._xScaleIndicativeLoader
                origin.x: indicativeLoader.width / 2
                yScale: root.scaleY
                Behavior on yScale { NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutCubic } }
            }
            opacity: root.notchState === "indicative" ? 1 : 0
            visible: opacity > 0
            layer.enabled: true
            layer.effect: MultiEffect {
                id: blurIndicative
                blurEnabled: true
                blur: 1
                blurMax: 64
                Component.onCompleted: {
                    blur = root.notchState === "indicative" || root.notchState === "closed" ? 0 : 1
                }
                Connections {
                    target: root
                    function onClosing() {
                        blurIndicative.blur = 1
                    }
                    function onNotchStateChanged() {
                        blurIndicative.blur = root.notchState === "indicative" || root.notchState === "closed" ? 0 : 1
                    }
                }
                Behavior on blur { NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutCubic } }
            }
            Behavior on opacity { NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutCubic } }
        }
    }


    Timer {
        id: exitTimer
        interval: meta.shrinkMs
        repeat: false
        running: false
        onTriggered: if (notchState === "active" && !root.noMode) notchState = "indicative"
    }

    Timer {
        id: openTimer
        interval: Config.notch.openHoverMs
        repeat: false
        running: false
        onTriggered: if (notchState === "indicative" && !root.noMode) notchState = "active"
    }

    property real scaleY: 1

    MouseArea {
        anchors.fill: parent
        z: 99
        onClicked: root.activate()
        hoverEnabled: true
        scrollGestureEnabled: true
        onEntered: {
            notch.setSize(meta.indicativeWidth+10, meta.indicativeHeight+5, false, root.meta.id)
            shadowOpacity = 0.5
            if (Config.notch.openOnHover) {
                openTimer.start()
            }
        }
        onExited: {
            if (notchState !== "active") {
                notch.setSize(meta.indicativeWidth, meta.indicativeHeight, false, root.meta.id)
                shadowOpacity = 0
                root._pullHeight = 0
                root.scaleY = 1
            }
        }
        onWheel: (wheel) => {
            let delta = Math.min(meta.scrollHeight, Math.round(wheel.angleDelta.y/50))
            root._pullHeight = Math.max(-80, root._pullHeight + delta)
            if (wheel.angleDelta.y === 0) {
                root._pullHeight = 0
            }
            root.scaleY = Math.max(0.9, 1 + (root._pullHeight/(meta.scrollHeight*2)))
            notch.setSize(meta.indicativeWidth-(root.scaleY*20), meta.indicativeHeight+5+Math.max(-10, root._pullHeight), false, root.meta.id)
            if (root._pullHeight > meta.scrollHeight) {
                root.activate()
                root.scaleY = 1
            }
            if (root._pullHeight < -50) {
                root._pullHeight = 0
                root.closeMe()
            }
        }
        onPressed: {
            notch.setSize(meta.indicativeWidth-10, meta.indicativeHeight+5, false, root.meta.id)
        }
        enabled: (root.notchState === "indicative") && !root.noMode
    }
}
