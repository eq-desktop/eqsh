import Quickshell
import QtQuick
import qs
import qs.config
import qs.ui.controls.providers

Text {
    id: uitext
    property bool gray: false
    property string colorDarkMode: "#fff"
    property string colorLightMode: "#1e1e1e"
    renderType: Text.NativeRendering
    renderTypeQuality: Text.VeryHighRenderTypeQuality
    color: gray ? (Config.general.darkMode ? AccentColor.textColorM : "#a01e1e1e") : Config.general.darkMode ? uitext.colorDarkMode : uitext.colorLightMode
}