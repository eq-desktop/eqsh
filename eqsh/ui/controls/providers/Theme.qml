pragma Singleton

import Quickshell
import QtQuick
import qs.config

Singleton {
    // Config.appearance.glass // 0=Clear | 1=Tinted | 2=Room Light | 3=Dark | 4=Opaque
    property color glassColor: Config.appearance.glass == 0 ? "#20ffffff" // Clear
        :Config.appearance.glass == 1 ? "#50555555" // Tinted
        :Config.appearance.glass == 2 ? Qt.alpha(Colors.tintWhiteWith(AccentColor.color, 0.2), 0.2) // Room Light
        :Config.appearance.glass == 3 ? "#20000000" // Dark
        :Config.appearance.glass == 4 ? "#333" // Opaque
        :Config.appearance.glass == 5 ? Qt.alpha(Colors.tintBlackWith(AccentColor.color, 0.2), 0.2) // Room Dark
        :Config.appearance.glass == 6 ? "#60000000" // Thick Dark
        :Config.appearance.glass == 7 ? Config.appearance.glass_Color // Custom
        : "#20ffffff"
    property color glassRimColor: "#80ffffff"
    property real  glassRimStrength: 1.0
    property real  glassRimStrengthStrong: 1.3
    property point glassLightDirStrong: Qt.point(1, -0.2)
    property color textColor: "#ffffff"
}