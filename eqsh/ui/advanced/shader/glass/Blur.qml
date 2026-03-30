import QtQuick
import Quickshell
import QtQuick.Effects


ShaderEffectSource {
    id: root
    anchors.fill: parent
    property var source
    property real radius: 32
    ShaderEffect {
        id: blurX
        anchors.fill: parent
        property variant source: root.source
        property vector2d iResolution: Qt.vector2d(width, height)
        property vector2d direction: Qt.vector2d(1, 0)
        property real radius: root.radius
        fragmentShader: Qt.resolvedUrl(Quickshell.shellDir + "/media/shaders/blur.frag.qsb")
        vertexShader: Qt.resolvedUrl(Quickshell.shellDir + "/media/shaders/blur.vert.qsb")
        layer.enabled: true
    }
    ShaderEffect {
        id: blurY
        anchors.fill: blurX
        property variant source: blurX
        property vector2d iResolution: Qt.vector2d(width, height)
        property vector2d direction: Qt.vector2d(0, 1)
        property real radius: root.radius
        fragmentShader: Qt.resolvedUrl(Quickshell.shellDir + "/media/shaders/blur.frag.qsb")
        vertexShader: Qt.resolvedUrl(Quickshell.shellDir + "/media/shaders/blur.vert.qsb")
    }
    sourceItem: blurY
}