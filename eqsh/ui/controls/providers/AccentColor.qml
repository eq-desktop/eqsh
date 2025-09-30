pragma Singleton

import Quickshell
import QtQuick
import qs.config

Singleton {
    ColorQuantizer {
        id: colorQuantizer
        source: Qt.resolvedUrl(Config.wallpaper.path)
        depth: 5 // Will produce 8 colors (2³)
        rescaleSize: 64 // Rescale to 64x64 for faster processing
    }
    property var colors: colorQuantizer.colors
    property var color: Config.appearance.dynamicAccentColor ? colorQuantizer.colors.slice(-1)[0] || "#fff" : Config.appearance.accentColor
    property var textColor: Qt.lighter(color, 1.5)
    property var textColorT: Qt.alpha(textColor, 0.9)
    property var textColorH: Qt.alpha(textColor, 0.5)
}