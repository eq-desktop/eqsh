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

CheckBox {
    property string textVal: ""
    text: `<font color=\"${Config.general.darkMode ? '#fff' : '#000'}\">${textVal}</font>`
    font.pixelSize: 16
}