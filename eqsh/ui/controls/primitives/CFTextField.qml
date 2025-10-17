import Quickshell
import QtQuick
import qs
import qs.config
import qs.ui.controls.providers
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Shapes
import QtQuick.VectorImage

TextField {
    color: Config.general.darkMode ? "#fff" : "#000"
    font.pixelSize: 16
    Layout.minimumWidth: 250
    background: Rectangle {
        anchors.fill: parent
        color: Config.general.darkMode ? "#2a2a2a" : "#fefefe"
        border {
            width: 1
            color: "#aaa"
        }
        radius: 10
    }
}