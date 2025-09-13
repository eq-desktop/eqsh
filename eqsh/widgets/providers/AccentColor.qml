pragma Singleton

import Quickshell
import QtQuick
import qs.Config

Singleton {
    ColorQuantizer {
        id: colorQuantizer
        source: Qt.resolvedUrl(Config.wallpaper.path)
        depth: 3 // Will produce 8 colors (2³)
        rescaleSize: 64 // Rescale to 64x64 for faster processing
    }
    property var color: colorQuantizer.colors.slice(-1)[0] || "#fff"
}