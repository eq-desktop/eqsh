import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.VectorImage
import QtQuick.Effects
import qs
import qs.Config
import qs.ui.Controls.providers

Control {
    id: weatherWidget
    anchors.fill: parent
    padding: 10

    contentItem: ClippingRectangle {
        id: root
        radius: Config.widgets.radius
        Rectangle {
            id: bg
            anchors.fill: parent
            scale: 2
            rotation: -20
            gradient: Gradient {
                GradientStop { position: 0.0; color: Config.general.darkMode ? Qt.darker(AccentColor.color, 5) : Qt.lighter(AccentColor.color, 2) }
                GradientStop { position: 1.0; color: Config.general.darkMode ? AccentColor.color : AccentColor.color }
            }
        }

        Timer {
            id: notifTimer
            interval: 10000 // 2 minutes
            running: true
            repeat: true
            onTriggered: {
                weatherProc.running = true
            }
        }

        Process {
            id: weatherProc
            command: ["sh", "-c", `curl -s wttr.in/${Config.widgets.location}?format=j1 | jq '{location: .nearest_area[0].areaName[0].value, temperature: .current_condition[0].temp_${Config.widgets.tempUnit}, feelsLikeTemp: .current_condition[0].FeelsLike${Config.widgets.tempUnit}, description: .current_condition[0].weatherDesc[0].value, highTemp: .weather[0].maxtemp${Config.widgets.tempUnit}, lowTemp: .weather[0].mintemp${Config.widgets.tempUnit}}'`]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    const text = this.text;
                    const json = JSON.parse(text);
                    root.location = Config.widgets.useLocationInUI ? Config.widgets.location : json.location;
                    root.temperature = json.temperature;
                    root.description = json.description;
                    root.hlVal = "H: " + json.highTemp + "°" + Config.widgets.tempUnit + ", L: " + json.lowTemp + "°" + Config.widgets.tempUnit;
                }
            }
        }

        property string location: "--"
        property int temperature: 0
        property string description: ""
        property string hlVal: "H: --, L: --"
        property url icon: Qt.resolvedUrl(Quickshell.shellDir + "/Media/icons/weather/cloud-sun.svg")

        Text {
            id: locationT
            text: root.location
            color: Config.general.darkMode ? "#fff" : "#222"
            font.pixelSize: 14
            topPadding: 10
            leftPadding: 10
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignLeft
        }

        Text {
            text: root.temperature + "°" + Config.widgets.tempUnit
            color: Config.general.darkMode ? "#fff" : "#222"
            font.pixelSize: 28
            font.weight: 300
            leftPadding: 10
            anchors.top: locationT.bottom
            horizontalAlignment: Text.AlignLeft
        }

        VectorImage {
            id: icon
            source: root.icon
            width: 20
            height: 20
            preferredRendererType: VectorImage.CurveRenderer
            anchors.bottom: descriptionT.top
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.bottomMargin: 3
        }

        // Description
        Text {
            id: hlT
            text: root.hlVal
            color: Config.general.darkMode ? "#fff" : "#222"
            font.pixelSize: 12
            leftPadding: 10
            bottomPadding: 10
            horizontalAlignment: Text.AlignLeft
            anchors.bottom: parent.bottom
        }

        Text {
            id: descriptionT
            text: root.description
            color: Config.general.darkMode ? "#fff" : "#222"
            font.pixelSize: 12
            leftPadding: 10
            anchors.bottom: hlT.top
        }
    }
}
