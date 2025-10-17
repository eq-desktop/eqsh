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
    property var dynamicColor: colorQuantizer.colors.slice(-1)[0]
    property var color: Config.appearance.dynamicAccentColor ? colorQuantizer.colors.slice(-1)[0] || "#fff" : Config.appearance.accentColor
    property var textColor: Colors.tintWhiteWith(color, 0.2)
    property var textColorT: Qt.alpha(textColor, 0.9)
    property var textColorM: Qt.alpha(textColor, 0.7)
    property var textColorH: Qt.alpha(textColor, 0.5)
}