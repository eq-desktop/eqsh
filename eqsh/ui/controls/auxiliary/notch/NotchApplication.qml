import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.config
import qs.core.system
import qs.ui.controls.providers
import QtQuick.VectorImage
import QtQuick.Effects

Item {
    /*
    Advanced NotchApplication Object
    Made by: Eq-Desktop
    License: Apache-2.0
    Made for Elephant-1

    */
    id: root
    property var screen
    property Details details: Details {}
    property Meta meta: Meta {}
    property Properties properties: Properties {}
    property bool onlyActive: false
    property bool isActive: onlyActive
    property string notchState: isActive ? "active" : "indicative" // indicative, active
    property bool   noMode: onlyActive
    property Component indicative: null
    property Component active: null
    property bool immortal: false
    property var notchContainer: parent
    property var isFocused: notch.focusedRunningInstance?.meta.id == meta.id || false
    property var indicativeShowAnim: indicativeShowAnimComp

    property alias scaleY: root.properties.scaleY
    property alias scaleX: root.properties.scaleX

    z: 99

    PropertyAnimation {
        id: indicativeShowAnimComp
        target: root.properties
        property: "scaleX"
        from: root.properties.startScaleX
        to: root.properties.endScaleX
        duration: root.properties.scaleXDuration
        easing.type: Easing.OutBack
        easing.overshoot: 1
        easing.amplitude: 1.0
    }

    Behavior on width { NumberAnimation { duration: properties.animDuration; easing.type: Easing.OutBack; easing.overshoot: 1 } }
    Behavior on height { NumberAnimation { duration: properties.animDuration; easing.type: Easing.OutBack; easing.overshoot: 1 } }

    anchors.fill: parent

    Rectangle {
        id: notchBg
        anchors.fill: parent
        color: Config.notch.backgroundColor
        topLeftRadius: Config.notch.islandMode ? Config.notch.radius : 0
        topRightRadius: Config.notch.islandMode ? Config.notch.radius : 0
        bottomLeftRadius: Config.notch.radius
        bottomRightRadius: Config.notch.radius
        Behavior on opacity {
            NumberAnimation { duration: root.properties.animDuration; easing.type: Easing.InOutQuad }
        }
    }

    onClosing: {
        notchBg.opacity = 0
    }

    component Meta: QtObject {
        property var    id: null
        property bool   inCreation: false
        property string name: ""
        property int    width: notch.defaultWidth
        property int    height: notch.defaultHeight
        property int    xOffset: 0
        property int    indicativeWidth: notch.defaultWidth
        property int    indicativeHeight: notch.defaultHeight
        property int    informativeWidth: indicativeWidth+10
        property int    informativeHeight: indicativeHeight+5

        property int    closeAfterMs: -1
        property int    shrinkMs: 300
        property int    scrollHeight: 50
        property var    shadowOpacity: undefined
        property bool   resizeExit: false
    }

    component Properties: QtObject {
        property real startScaleX: 0.5
        property real scaleX: 1
        property real endScaleX: 1
        property bool useScaleX: true
        property int  scaleXDuration: 500
        property real scaleY: 1
        property bool useScaleY: true
        property int  scaleYDuration: 500

        property real startScale: 1
        property real startOpacity: 0

        property int  animDuration: 500
    }

    component Details: QtObject {
        property string version: "Elephant-1"
        /*deprecated*/ property string shadowColor: "#000000"
        property string appType: "indicator" // indicator, media
    }

    opacity: properties.startOpacity
    scale: properties.startScale

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

    function setInformative() {
        if (notchState !== "informative") {
            notchState = "informative"
        }
    }

    function isIndicative() {
        return notchState === "indicative" || notchState === "informative"
    }

    function setSize(width, height) {
        notchContainer.width = width
        notchContainer.height = height
    }

    function setSizeDefault() {
        notchContainer.width = notch.defaultWidth
        notchContainer.height = notch.defaultHeight
    }

    function setWidth(width) { notchContainer.width = width }
    function setHeight(height) { notchContainer.height = height }

    onNotchStateChanged: {
        if (notchState === "closed") return;
        resize()
    }

    function resize() {
        if (notchState === "active") {
            notchContainer.width = meta.width
            notchContainer.height = meta.height
        } else if (notchState === "indicative") {
            notchContainer.width = meta.indicativeWidth
            notchContainer.height = meta.indicativeHeight
        } else if (notchState === "informative") {
            notchContainer.width = meta.informativeWidth
            notchContainer.height = meta.informativeHeight
        } else {
            notchContainer.width = meta.indicativeWidth
            notchContainer.height = meta.indicativeHeight
        }
    }

    function initSetup() {
        notchContainer.xOffset = root.meta.xOffset
    }

    Component.onCompleted: {
        opacity = 1
        scale = 1
        resize()
    }

    Timer {
        id: closeTimer
        interval: meta.shrinkMs
        running: false
        onTriggered: {notch.closeNotchInstanceById(meta.id)}
    }

    function closeMe() {
        if (immortal) return; 
        if (meta.resizeExit) root.setSizeDefault()
        notchState = "closed"
        closing()
        closeTimer.running = true
    }

    signal closing()

    Connections {
        target: notch
        function onFocusedInstance(instance) {
            if (instance.meta.id !== root.meta.id && root.details.appType === "indicator") {
                root.closeMe()
            }
            if (instance.meta.id === root.meta.id) {
                root.resize()
                root.initSetup()
            }
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: root.properties.animDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
    }
    Behavior on scale {
        NumberAnimation { duration: root.properties.animDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
    }

    property var runningNotchInstances: notch.runningNotchInstances
    onRunningNotchInstancesChanged: {
        if (runningNotchInstances.length === 0) return;
        if (meta.inCreation) return;
        if (root.meta.id !== null && !notch.idIsRunning(root.meta.id)) {
            if (immortal) return;
            shadowOpacity = 0
            console.info("Killed", root.meta.id)
            root.destroy()
        }
    }

    Timer {
        interval: meta.closeAfterMs
        running: meta.closeAfterMs !== -1
        repeat: false
        onTriggered: root.closeMe()
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        preventStealing: true
        scrollGestureEnabled: true
        onClicked: {}
        onEntered: {
            exitTimer.running = false
            shadowOpacity = 0.5
        }
        onExited: {
            exitTimer.running = true
            shadowOpacity = 0
        }
        enabled: true
        ClippingRectangle {
            anchors.fill: parent
            topLeftRadius: Config.notch.islandMode ? 20 : 0
            topRightRadius: Config.notch.islandMode ? 20 : 0
            bottomLeftRadius: 20
            bottomRightRadius: 20
            color: "transparent"
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
                    Behavior on yScale { NumberAnimation { duration: root.properties.animDuration; easing.type: Easing.OutCubic } }
                }
                visible: opacity > 0
                layer.enabled: true
                layer.samples: 8
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
                    Behavior on blur { NumberAnimation { duration: root.properties.animDuration; easing.type: Easing.OutCubic } }
                }
                Behavior on opacity { NumberAnimation { duration: root.properties.animDuration; easing.type: Easing.OutCubic } }
            }

            Loader {
                id: indicativeLoader
                anchors.fill: parent
                sourceComponent: root.indicative
                transform: Scale {
                    origin.x: indicativeLoader.width / 2
                    xScale: root.properties.useScaleX ? root.properties.scaleX : 1
                    yScale: root.properties.useScaleY ? root.properties.scaleY : 1
                    Behavior on yScale { NumberAnimation { duration: root.properties.animDuration; easing.type: Easing.OutCubic } }
                }
                opacity: root.isIndicative() ? 1 : 0
                visible: opacity > 0
                layer.enabled: true
                layer.samples: 8
                layer.effect: MultiEffect {
                    id: blurIndicative
                    blurEnabled: true
                    blur: 1
                    blurMax: 64
                    Component.onCompleted: {
                        blur = root.isIndicative() || root.notchState === "closed" ? 0 : 1
                    }
                    Connections {
                        target: root
                        function onClosing() {
                            blurIndicative.blur = 1
                        }
                        function onNotchStateChanged() {
                            blurIndicative.blur = root.isIndicative() || root.notchState === "closed" ? 0 : 1
                        }
                    }
                    Behavior on blur { NumberAnimation { duration: root.properties.animDuration; easing.type: Easing.OutCubic } }
                }
                Behavior on opacity { NumberAnimation { duration: root.properties.animDuration; easing.type: Easing.OutCubic } }
            }
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

    MouseArea {
        anchors.fill: parent
        z: 99
        onClicked: {if (!root.noMode) root.activate()}
        hoverEnabled: true
        scrollGestureEnabled: true
        onEntered: {
            notchContainer.width = meta.indicativeWidth+10
            notchContainer.height = meta.indicativeHeight+5
            root.setInformative()
            shadowOpacity = 0.5
            if (Config.notch.openOnHover) {
                openTimer.start()
            }
        }
        onExited: {
            if (notchState !== "active") {
                notchContainer.width = meta.indicativeWidth
                notchContainer.height = meta.indicativeHeight
                root.setIndicative()
                shadowOpacity = 0
            }
        }
        enabled: (root.isIndicative())
    }
}
