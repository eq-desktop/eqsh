import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.components.misc
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
        content: Item {Rectangle {
            id: rect
            width: 250
            height: 400
            color: "transparent"
            anchors {
                top: parent.top
                right: parent.right
                topMargin: Config.bar.height
            }
            Box {
                id: wifiWidget
                width: 110
                height: 47.5
                radius: 40
                anchors {
                    top: parent.top
                    left: parent.left
                    margins: 15
                }
            }
            Box {
                id: bluetoothWidget
                width: 47.5
                height: 47.5
                radius: 40
                anchors {
                    top: wifiWidget.bottom
                    left: wifiWidget.left
                    topMargin: 15
                }
            }
            Box {
                id: airdropWidget
                width: 47.5
                height: 47.5
                radius: 40
                anchors {
                    top: wifiWidget.bottom
                    right: wifiWidget.right
                    topMargin: 15
                }
            }
            Box {
                id: focusWidget
                width: 110
                height: 47.5
                radius: 40
                anchors {
                    top: airdropWidget.bottom
                    left: parent.left
                    topMargin: 15
                    leftMargin: 15
                }
            }
            Box {
                id: musicWidget
                width: 110
                height: 110
                anchors {
                    top: parent.top
                    right: parent.right
                    topMargin: 15
                }
            }
            Item {
                anchors {
                    top: focusWidget.bottom
                    left: panelWindow.left
                    topMargin: 15
                    leftMargin: 15
                }
                width: 235
                height: 67.5
                Rectangle {
                    id: displayWidget
                    width: 235
                    height: 67.5
                    radius: 30
                    color: "#f00"
                    layer.enabled: true
                    layer.effect: LiquidGlass {
                        width: 235
                        height: 67.5
                        source: displayWidget
                    }
                }
            }
        }}
    }
}