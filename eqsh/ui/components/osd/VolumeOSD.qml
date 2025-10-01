import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import Quickshell.Wayland
import qs.ui.controls.auxiliary
import qs.config
import QtQuick.Effects

Scope {
    id: root

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    property bool muted: Pipewire.defaultAudioSink?.audio.muted || false

    Connections {
        target: Pipewire.defaultAudioSink?.audio || null
        ignoreUnknownSignals: true
        function onVolumeChanged() {
            popup.show()
        }
        function onMutedChanged() {
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
                    source: root.muted ? Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/volume/audio-volume-0.svg") : Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/volume/audio-volume-3.svg");
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
                            NumberAnimation { duration: 150; }
                        }

                        width: parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0)
                    }
                }
            }
        }
    }
}
