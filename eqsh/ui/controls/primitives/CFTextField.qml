import Quickshell
import QtQuick
import qs
import qs.config
import qs.ui.controls.providers
import qs.ui.controls.advanced
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
    property color backgroundColor: Config.general.darkMode ? "#20ffffff" : "#20555555"
    background: BoxGlass {
        id: bg
        anchors.fill: parent
        color: root.backgroundColor
        rimStrength: 0.2
        lightDir: Qt.point(1, -0.05)
        radius: 15
    }
    placeholderTextColor: Config.general.darkMode ? "#777" : "#888"
}