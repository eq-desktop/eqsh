import QtQuick
import Quickshell

ShaderEffect {
    id: highlight
    property size iResolution: Qt.size(width, height)
    property real iTime: Qt.frameTime / 1000.0
    property color glowColor: "white"
    property real glowIntensity: 0.9
    property real glowSpeed: 1.2
    property real glowAngWidth: 0.75
    property real glowEdgeBand: 0.06
    property real radiusX: 100
    property real radiusY: 100
    property real shapeExp: 4.0

    fragmentShader: Qt.resolvedUrl(Quickshell.shellDir + "/media/shaders/glassrim.frag.qsb")
}
2