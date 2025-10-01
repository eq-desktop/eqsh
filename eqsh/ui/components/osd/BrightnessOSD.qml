import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import Quickshell.Wayland
import qs.ui.controls.auxiliary
import qs.core.system
import qs.config
import QtQuick.Effects

Scope {
    id: root

    Variants {
        model: Quickshell.screens
        OSDPopup {
            id: popup

            property real brightness: Brightness.getMonitorForScreen(popup.modelData).brightness
            onBrightnessChanged: { popup.show() }
            Item {
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    Layout.alignment: Qt.AlignCenter

                    IconImage {
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 60
                        implicitHeight: 60
                        source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/sun-huge.svg");
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 12
                        radius: 6
                        color: "#40ffffff"

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }
                            radius: parent.radius
                            color: "white"

                            Behavior on width { NumberAnimation { duration: 100 } }

                            width: parent.width * (Brightness.monitors[0].brightness ?? 0)
                        }
                    }
                }
            }
        }
    }
}
