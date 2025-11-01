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
    id: bw
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
                        Layout.alignment: Qt.AlignVCenter
                        id: battery
                        implicitSize: 80*bw.sF
                        lineWidth: 4
                        colPrimary: Config.appearance.multiAccentColor ? "#3cc969" : AccentColor.color
                        colSecondary: Config.general.darkMode ? "#444" : "#ddd"
                        gapAngle: 0
                        value: modelData.level

                        Loader {
                            id: batteryIcon
                            active: modelData.name != ""
                            anchors.centerIn: parent
                            CFVI {
                                id: bIcon
                                source: modelData.name == "" ? "" :  Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/devices/" + modelData.type + ".svg")
                                size: bw.textSizeXL
                                anchors.centerIn: parent
                                color: Config.appearance.multiAccentColor ? (Config.general.darkMode ? '#fff' : "#222") : AccentColor.color
                            }
                        }
                    }

                    // Label
                    CFText {
                        text: Math.round(modelData.level * 100) + "%"
                        opacity: (modelData.name == "") ? 0 : 1
                        color: Config.general.darkMode ? "#fff" : "#222"
                        font.pixelSize: bw.textSizeM
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}
