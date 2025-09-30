import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.VectorImage
import qs
import qs.config
import qs.ui.controls.providers
import qs.ui.controls.primitives
import Quickshell
import Quickshell.Services.UPower

BaseWidget {
    content: Item {
        id: root

        property var devices: [
            { type: UPower.displayDevice.isLaptopBattery ? "laptop" : "desktop", name: "Micky's Macbook Air 2019", level: UPower.displayDevice.percentage },
            { type: "", name: "", level: 0 },
            { type: "", name: "", level: 0 },
            { type: "", name: "", level: 0 }
        ]

        RowLayout {
            id: batteryRow
            anchors.centerIn: parent
            spacing: 20

            Repeater {
                model: root.devices

                ColumnLayout {
                    spacing: 6
                    Layout.alignment: Qt.AlignHCenter

                    // Simple battery circle
                    CFCircularProgress {
                        id: battery
                        implicitSize: 60
                        lineWidth: 4
                        colPrimary: AccentColor.color
                        colSecondary: Config.general.darkMode ? "#444" : "#ddd"
                        gapAngle: 0
                        value: modelData.level

                        Loader {
                            id: batteryIcon
                            active: modelData.name != ""
                            anchors.centerIn: parent
                            VectorImage {
                                id: bIcon
                                source: modelData.name == "" ? "" :  Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/devices/" + modelData.type + ".svg")
                                width: 20
                                height: 20
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                preferredRendererType: VectorImage.CurveRenderer
                                anchors.centerIn: parent
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    colorization: 1
                                    colorizationColor: AccentColor.color
                                }
                            }
                        }
                    }

                    // Label
                    Text {
                        text: Math.round(modelData.level * 100) + "%"
                        opacity: (modelData.name == "") ? 0 : 1
                        color: Config.general.darkMode ? "#fff" : "#222"
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}
