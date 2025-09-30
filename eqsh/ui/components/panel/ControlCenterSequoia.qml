import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import qs.ui.controls.auxiliary
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
        property int box: 50
        property int boxMargin: 10
        property int gridW: 4
        property int gridH: 6
        property int gridImplicitWidth: ((box*gridW)+(boxMargin*gridW))
        property int gridImplicitHeight: ((box*gridH)+(boxMargin*gridH))
        
        content: Item {Rectangle {
            id: rect
            width: panelWindow.gridImplicitWidth
            height: panelWindow.gridImplicitHeight
            color: "transparent"
            anchors {
                top: parent.top
                right: parent.right
                topMargin: Config.bar.height
            }
            Box {
                id: wifiWidget
                width: 110
                height: 50
                radius: 40
                anchors {
                    top: parent.top
                    left: parent.left
                    margins: 10
                }
            }
            Box {
                id: bluetoothWidget
                width: 50
                height: 50
                radius: 40
                anchors {
                    top: wifiWidget.bottom
                    left: wifiWidget.left
                    topMargin: 10
                }
            }
            Box {
                id: airdropWidget
                width: 50
                height: 50
                radius: 40
                anchors {
                    top: wifiWidget.bottom
                    right: wifiWidget.right
                    topMargin: 10
                }
            }
            Box {
                id: focusWidget
                width: 110
                height: 50
                radius: 40
                anchors {
                    top: airdropWidget.bottom
                    left: parent.left
                    topMargin: 10
                    leftMargin: 10
                }
            }
            Box {
                id: musicWidget
                width: 110
                height: 110
                radius: 30
                anchors {
                    top: parent.top
                    right: parent.right
                    topMargin: 10
                }
            }
            Box {
                id: stageWidget
                width: 50
                height: 50
                radius: 40
                anchors {
                    top: musicWidget.bottom
                    left: musicWidget.left
                    topMargin: 10
                }
            }
            Box {
                id: screenshareWidget
                width: 50
                height: 50
                radius: 40
                anchors {
                    top: musicWidget.bottom
                    right: musicWidget.right
                    topMargin: 10
                }
            }
            Box {
                id: displayWidget
                width: 230
                height: 60
                radius: 25
                anchors {
                    top: focusWidget.bottom
                    left: parent.left
                    margins: 10
                }
            }
            Box {
                id: volumeWidget
                width: 230
                height: 60
                radius: 25
                anchors {
                    top: displayWidget.bottom
                    left: parent.left
                    margins: 10
                }
            }
            Box {
                id: darkModeWidget
                width: 50
                height: 50
                radius: 40
                anchors {
                    top: volumeWidget.bottom
                    left: volumeWidget.left
                    topMargin: 10
                }
            }
            Box {
                id: calculatorWidget
                width: 50
                height: 50
                radius: 40
                anchors {
                    top: volumeWidget.bottom
                    left: darkModeWidget.right
                    topMargin: 10
                    leftMargin: 10
                }
            }
            Box {
                id: clockWidget
                width: 50
                height: 50
                radius: 40
                anchors {
                    top: volumeWidget.bottom
                    left: calculatorWidget.right
                    topMargin: 10
                    leftMargin: 10
                }
            }
            Box {
                id: screenshotWidget
                width: 50
                height: 50
                radius: 40
                anchors {
                    top: volumeWidget.bottom
                    left: clockWidget.right
                    topMargin: 10
                    leftMargin: 10
                }
            }
        }}
    }
}