import QtQuick
import QtQuick.VectorImage
import QtQuick.Effects
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Widgets
import QtQuick.Layouts
import Quickshell.Wayland
import qs.ui.controls.auxiliary
import qs.ui.controls.providers
import qs.ui.controls.advanced
import qs.ui.controls.windows
import qs.core.system
import qs.config
import QtQuick.Controls.Fusion

Scope {
    function open() {
        panelWindow.opened = true;
    }
    id: root
    Pop {
        id: panelWindow
        margins.right: 30
        property int box: 65
        property int boxMargin: 10
        property int gridW: 4
        property int gridH: 6
        property int gridImplicitWidth: ((box*gridW)+(boxMargin*gridW)+boxMargin)
        property int gridImplicitHeight: ((box*gridH)+(boxMargin*gridH)+boxMargin)

        component BoxButton: BoxExperimental {
            id: boxbutton
            radius: 40
            property bool enabled: false
            color: {Config.appearance.glassMode == 0 ?
                boxbutton.enabled ? "#fff" : "#77000000" : Config.appearance.glassMode == 1 ?
                boxbutton.enabled ? "#fff" : "#bb000000" : Config.appearance.glassMode == 2 ?
                boxbutton.enabled ? "#fff" : "#bb000000" : Config.appearance.glassMode == 3 ?
                boxbutton.enabled ? "#fff" : "#bb000000" : "#fff"
            }
            shadowOpacity: Config.appearance.glassMode == 3 ? 0.8 : 0.5
            highlight: {Config.appearance.glassMode == 2 ?
                (boxbutton.enabled ? "transparent" : "#f00") : boxbutton.enabled ?
                "transparent" : AccentColor.color
            }
        }

        component UIText: Text {
            id: uitext
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "#000000"
                shadowBlur: 0.5
            }
        }
        
        component Button1x1: BoxButton {
            id: buttonx1
            width: panelWindow.box
            height: panelWindow.box
        }
        
        content: Item {
            Rectangle {
                transform: [
                    Translate {
                        y: -10
                    },
                    Scale {
                        origin.x: (rect.width/1.5)
                        origin.y: 0
                        xScale: panelWindow.hiding ? 0.5 : panelWindow.opened ? 1 : 0.5
                        yScale: panelWindow.hiding ? 0.5 : panelWindow.opened ? 1 : 0.5
                        Behavior on xScale { PropertyAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1 } }
                        Behavior on yScale { PropertyAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1 } }
                    }
                ]
                id: rect
                width: panelWindow.gridImplicitWidth
                height: panelWindow.gridImplicitHeight
                color: "transparent"
                anchors {
                    top: parent.top
                    right: parent.right
                    topMargin: Config.bar.height
                }
                BoxButton {
                    id: wifiWidget
                    width: panelWindow.box*2+panelWindow.boxMargin
                    height: panelWindow.box
                    radius: 40
                    anchors {
                        top: parent.top
                        left: parent.left
                        margins: 10
                    }
                    ClippingRectangle {
                        id: wifiClipping
                        anchors {
                            left: parent.left
                            leftMargin: 15
                            verticalCenter: parent.verticalCenter
                        }
                        radius: 40
                        width: 40
                        height: 40
                        color: NetworkManager.active ? "#fff" : "transparent"
                        VectorImage {
                            transform: Translate {y:-3}
                            id: rBWifi
                            source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/wifi/nm-signal-100-symbolic.svg")
                            width: 25
                            height: 25
                            preferredRendererType: VectorImage.CurveRenderer
                            anchors.centerIn: parent
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                colorization: 1
                                colorizationColor: NetworkManager.active ? "#2495ff" : "#fff"
                            }
                        }
                    }
                    UIText {
                        text: "Wi-Fi"
                        font.weight: 600
                        color: "#fff"
                        anchors {
                            left: wifiClipping.right
                            leftMargin: 5
                            top: wifiClipping.top
                        }
                    }
                    UIText {
                        text: NetworkManager.active ? NetworkManager.active.ssid : "No network"
                        elide: Text.ElideRight
                        color: "#eee"
                        height: 20
                        width: panelWindow.box+10
                        anchors {
                            left: wifiClipping.right
                            leftMargin: 5
                            bottom: wifiClipping.bottom
                        }
                    }
                }
                Button1x1 {
                    id: bluetoothWidget
                    anchors {
                        top: wifiWidget.bottom
                        left: wifiWidget.left
                        topMargin: 10
                    }
                    enabled: Bluetooth.defaultAdapter?.enabled || false
                    VectorImage {
                        id: rBBluetooth
                        source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/bluetooth-clear.svg")
                        width: panelWindow.box-10
                        height: panelWindow.box-10
                        preferredRendererType: VectorImage.CurveRenderer
                        anchors.centerIn: parent
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            colorization: 1
                            colorizationColor: bluetoothWidget.enabled ? "#2495ff" : "#fff"
                        }
                    } 
                }
                Button1x1 {
                    id: airdropWidget
                    anchors {
                        top: wifiWidget.bottom
                        right: wifiWidget.right
                        topMargin: 10
                    }
                }
                BoxButton {
                    id: focusWidget
                    width: panelWindow.box*2+panelWindow.boxMargin
                    height: panelWindow.box
                    radius: 40
                    anchors {
                        top: airdropWidget.bottom
                        left: parent.left
                        topMargin: 10
                        leftMargin: 10
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            NotificationDaemon.toggleDND()
                        }
                    }
                    ClippingRectangle {
                        id: focusClipping
                        anchors {
                            left: parent.left
                            leftMargin: 15
                            verticalCenter: parent.verticalCenter
                        }
                        radius: 40
                        width: 40
                        height: 40
                        color: NotificationDaemon.popupInhibited ? "#ffffff" : "#60ffffff"
                        VectorImage {
                            id: rBFocus
                            source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/dnd.svg")
                            width: 40
                            height: 40
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            preferredRendererType: VectorImage.CurveRenderer
                            anchors.centerIn: parent
                            layer.enabled: true
                            layer.effect: MultiEffect {
                                colorization: 1
                                colorizationColor: NotificationDaemon.popupInhibited ? "#2495ff" : "#fff"
                            }
                        }
                    }
                    UIText {
                        text: "Focus"
                        font.weight: 600
                        color: "#fff"
                        anchors {
                            left: focusClipping.right
                            leftMargin: 5
                            verticalCenter: parent.verticalCenter
                        }
                    }
                }
                BoxButton {
                    id: musicWidget
                    width: panelWindow.box*2+panelWindow.boxMargin
                    height: panelWindow.box*2+panelWindow.boxMargin
                    radius: 40
                    anchors {
                        top: parent.top
                        left: wifiWidget.right
                        leftMargin: 10
                        topMargin: 10
                    }
                }
                Button1x1 {
                    id: stageWidget
                    anchors {
                        top: musicWidget.bottom
                        left: musicWidget.left
                        topMargin: 10
                    }
                }
                Button1x1 {
                    id: screenshareWidget
                    anchors {
                        top: musicWidget.bottom
                        right: musicWidget.right
                        topMargin: 10
                    }
                }
                BoxButton {
                    id: displayWidget
                    width: panelWindow.box*4+panelWindow.boxMargin*3
                    height: panelWindow.box+10
                    radius: 25
                    anchors {
                        top: focusWidget.bottom
                        left: parent.left
                        margins: 10
                    }
                }
                BoxButton {
                    id: volumeWidget
                    width: panelWindow.box*4+panelWindow.boxMargin*3
                    height: panelWindow.box+10
                    radius: 25
                    anchors {
                        top: displayWidget.bottom
                        left: parent.left
                        margins: 10
                    }
                }
                Button1x1 {
                    id: darkModeWidget
                    anchors {
                        top: volumeWidget.bottom
                        left: volumeWidget.left
                        topMargin: 10
                    }
                }
                Button1x1 {
                    id: calculatorWidget
                    anchors {
                        top: volumeWidget.bottom
                        left: darkModeWidget.right
                        topMargin: 10
                        leftMargin: 10
                    }
                }
                Button1x1 {
                    id: clockWidget
                    anchors {
                        top: volumeWidget.bottom
                        left: calculatorWidget.right
                        topMargin: 10
                        leftMargin: 10
                    }
                }
                Button1x1 {
                    id: screenshotWidget
                    anchors {
                        top: volumeWidget.bottom
                        left: clockWidget.right
                        topMargin: 10
                        leftMargin: 10
                    }
                }
            }
        }
    }
}