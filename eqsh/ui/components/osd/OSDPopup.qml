import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import Quickshell.Wayland
import qs.ui.controls.auxiliary
import qs.ui.controls.advanced
import qs.ui.controls.providers
import qs.config
import QtQuick.Effects

Scope {
    id: root
    default required property Component content
    required property var modelData

    function show() {
        showAnim.start()
        hideTimer.restart()
    }

    function hide() {
        hideAnim.start()
    }

    Timer {
        id: hideTimer
        interval: 1200
        onTriggered: {
            popup.hide()
        }
    }

    PanelWindow {
        anchors {
            bottom: true
        }
        margins {
            bottom: 0
        }
        screen: root.modelData
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "eqsh:blur"
        implicitWidth: 180
        implicitHeight: 360
        color: "transparent"
        exclusiveZone: 0
        mask: Region {}

        BoxExperimental {
            id: box
            radius: 30
            implicitWidth: 180
            implicitHeight: 180
            scale: Config.osd.animation == 1 ? 0 : 1
            opacity: Config.osd.animation == 2 ? 0 : 1
            highlight: AccentColor.color
            color: Config.osd.color
            anchors {
                id: osdAnchor
                bottom: parent.bottom
                bottomMargin: Config.osd.animation == 3 ? -180 : 20
            }

            layer.enabled: true
            layer.smooth: true

            PropertyAnimation {
                id: showAnim
                target: Config.osd.animation == 3 ? osdAnchor : box
                property: Config.osd.animation == 3 ? "bottomMargin" : Config.osd.animation == 1 ? "scale" : "opacity"
                duration: 2 == Config.osd.animation ? 0 :  Config.osd.duration
                to: Config.osd.animation == 3 ? 20 : 1
                easing.type: Easing.OutBack
                easing.overshoot: 1
            }

            PropertyAnimation {
                id: hideAnim
                target: Config.osd.animation == 3 ? osdAnchor : box
                property: Config.osd.animation == 3 ? "bottomMargin" : Config.osd.animation == 1 ? "scale" : "opacity"
                duration: Config.osd.duration
                to: Config.osd.animation == 3 ? -180 : 0
                easing.type: Easing.OutBack
                easing.overshoot: 1
            }

            Loader {
                id: loader
                anchors.fill: parent
                active: true
                sourceComponent: root.content
            }
        }
    }
}
