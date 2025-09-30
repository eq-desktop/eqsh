pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root
    FontLoader { id: sFProRounded; source: Qt.resolvedUrl(Quickshell.shellDir + "/media/fonts/SFPR/SF-Pro-Rounded-Bold.otf") }
    FontLoader { id: sFProRoundedRegular; source: Qt.resolvedUrl(Quickshell.shellDir + "/media/fonts/SFPR/SF-Pro-Rounded-Regular.otf") }
    FontLoader { id: sFProDisplayRegular; source: Qt.resolvedUrl(Quickshell.shellDir + "/media/fonts/SFPD/SF-Pro-Display-Regular.otf") }
    property var sFProRounded: sFProRounded.font
    property var sFProRoundedRegular: sFProRoundedRegular.font
    property var sFProDisplayRegular: sFProDisplayRegular.font
}