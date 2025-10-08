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

    Rectangle {
        id: notchBg
        anchors.fill: parent
        color: Config.notch.backgroundColor
        topLeftRadius: Config.notch.islandMode ? Config.notch.radius : 0
        topRightRadius: Config.notch.islandMode ? Config.notch.radius : 0
        bottomLeftRadius: Config.notch.radius
        bottomRightRadius: Config.notch.radius
    }

    HyprlandFocusGrab {
        id: grab
        windows: [ screen ]
        onCleared: if (notchState === "active") notchState = "indicative"
    }

    component Meta: QtObject {
        property int  width: notch.defaultWidth
        property int  height: notch.defaultHeight
        property real startScale: 1
        property real startOpacity: 0
        property int  animDuration: 200
        property int  closeAfterMs: -1
        property var  id: null
    }

    component Details: QtObject {
        property string version: "0.1.1"
        property string shadowColor: "#000000"
        property string appType: "indicator"
    }

    anchors.fill: parent
    opacity: meta.startOpacity
    scale: meta.startScale

    function activate() {
        if (notchState !== "active")
            notchState = "active"
    }

    function setIndicative() {
        if (notchState !== "indicative")
            notchState = "indicative"
    }

    onNotchStateChanged: {
        if (notchState === "active") {
            notch.setSize(meta.width, meta.height)
            grab.active = true
        } else {
            notch.resetSize()
            grab.active = false
        }
    }

    Component.onCompleted: {
        opacity = 1
        scale = 1
        if (notchState === "active") {
            notch.setSize(meta.width, meta.height)
            grab.active = true
        } else {
            notch.resetSize()
            grab.active = false
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
    }
    Behavior on scale {
        NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
    }

    property var runningNotchInstances: notch.runningNotchInstances
    onRunningNotchInstancesChanged: {
        if (meta.id !== null && !runningNotchInstances.includes(meta.id))
            root.destroy()
    }

    Timer {
        interval: meta.closeAfterMs
        running: meta.closeAfterMs !== -1
        repeat: false
        onTriggered: notch.closeNotchInstance(meta.id)
    }

    Loader {
        id: activeLoader
        anchors.fill: parent
        sourceComponent: root.active
        opacity: root.notchState === "active" ? 1 : 0
        visible: opacity > 0
        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: root.notchState === "active" ? 0 : 1
            Behavior on blur { NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutCubic } }
        }
        Behavior on opacity { NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutCubic } }
    }

    Loader {
        id: indicativeLoader
        anchors.fill: parent
        sourceComponent: root.indicative
        opacity: root.notchState === "indicative" ? 1 : 0
        visible: opacity > 0
        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: root.notchState === "indicative" ? 0 : 1
            Behavior on blur { NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutCubic } }
        }
        Behavior on opacity { NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.activate()
        enabled: (root.notchState === "indicative") && !root.noMode
    }
}
