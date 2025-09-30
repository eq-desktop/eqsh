import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.VectorImage
import QtQuick.Effects
import qs
import qs.config
import qs.ui.controls.providers

Control {
    id: root
    anchors.fill: parent
    padding: 10
    property Component content: null
    property Component bg: Rectangle {
        id: bg
        anchors.fill: parent
        scale: 2
        rotation: 0
        gradient: Gradient {
            GradientStop { position: 0.0; color: Config.general.darkMode ? "#222" : "#fff" }
            GradientStop { position: 1.0; color: Config.general.darkMode ? "#111" : "#fff" }
        }
    }

    contentItem: ClippingRectangle {
        radius: Config.widgets.radius
        color: "transparent"
        Loader {
            id: loader
            anchors.fill: parent
            sourceComponent: root.bg
        }

        Loader {
            id: contentLoader
            anchors.fill: parent
            active: true
            sourceComponent: root.content
        }
    }
}
