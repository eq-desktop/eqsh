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
    id: root
    color: Config.general.darkMode ? "#fff" : "#000"
    font.pixelSize: 16
    Layout.minimumWidth: 250
    renderType: TextInput.NativeRendering
    font.family: Fonts.sFProDisplayBlack.family
    property color backgroundColor: Config.general.darkMode ? "#2a2a2a" : "#fefefe"
    background: Rectangle {
        id: bg
        anchors.fill: parent
        color: root.backgroundColor
        border {
            width: 1
            color: "#aaa"
        }
        radius: 15
    }
    placeholderTextColor: Config.general.darkMode ? "#777" : "#888"
}