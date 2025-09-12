import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import Quickshell.Wayland
import qs.widgets.misc
import qs.config
import QtQuick.Effects

Scope {
    id: root

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio
        function onVolumeChanged() {
            popup.show()
        }
    }

    OSDPopup {
        id: popup
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
                    source: Qt.resolvedUrl(Quickshell.shellDir + "/assets/svgs/volume/audio-volume-3.svg");
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

                        Behavior on width {
                            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                        }

                        width: parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0)
                    }
                }
            }
        }
    }
}
