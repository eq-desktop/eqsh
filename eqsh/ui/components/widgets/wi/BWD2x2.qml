import QtQuick
import Quickshell
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

        property string location: "Düren"
        property int temperature: 21
        property string description: "Partly Cloudy"
        property string hlVal: "H: 23°C, L: 15°C"
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
            text: root.temperature + "°C"
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
            layer.enabled: true
            layer.effect: MultiEffect {
                colorization: 1
                colorizationColor: Config.general.darkMode ? "#fff" : "#222"
            }
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
