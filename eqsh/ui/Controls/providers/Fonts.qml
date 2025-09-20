pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root
    FontLoader { id: sFProRounded; source: Qt.resolvedUrl(Quickshell.shellDir + "/Media/fonts/SFPR/SF-Pro-Rounded-Bold.otf") }
    property var sFProRounded: sFProRounded.font
}