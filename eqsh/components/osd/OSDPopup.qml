import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import Quickshell.Wayland
import qs.widgets.misc
import qs.Config
import QtQuick.Effects

Scope {
    id: root
    default required property Component content

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
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "eqsh:blur"
        implicitWidth: 180
        implicitHeight: 360
        color: "transparent"
        exclusiveZone: 0
        mask: Region {}

        Box {
            id: box
            radius: 24
            implicitWidth: 180
            implicitHeight: 180
            scale: Config.osd.animation == "scale" ? 0 : 1
            opacity: Config.osd.animation == "fade" ? 0 : 1
            color: Config.osd.color
            anchors {
                id: osdAnchor
                bottom: parent.bottom
                bottomMargin: Config.osd.animation == "bubble" ? -180 : 20
            }

            layer.enabled: true
            layer.smooth: true

            PropertyAnimation {
                id: showAnim
                target: Config.osd.animation == "bubble" ? osdAnchor : box
                property: Config.osd.animation == "bubble" ? "bottomMargin" : Config.osd.animation == "scale" ? "scale" : "opacity"
                duration: Config.osd.duration
                to: Config.osd.animation == "bubble" ? 20 : 1
                easing.type: Easing.OutBack
                easing.overshoot: 1
            }

            PropertyAnimation {
                id: hideAnim
                target: Config.osd.animation == "bubble" ? osdAnchor : box
                property: Config.osd.animation == "bubble" ? "bottomMargin" : Config.osd.animation == "scale" ? "scale" : "opacity"
                duration: Config.osd.duration
                to: Config.osd.animation == "bubble" ? -180 : 0
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
