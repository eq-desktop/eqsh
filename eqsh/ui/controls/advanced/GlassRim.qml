import QtQuick
import QtQuick.Effects
import Quickshell

Item {
    id: box
    property real radius: 20.0
    property var source: null
    property real smallerVal: Math.min(width, height)
    property vector4d cornerRadii: Qt.vector4d(Math.min(smallerVal/2, radius), Math.min(smallerVal/2, radius), Math.min(smallerVal/2, radius), Math.min(smallerVal/2, radius))
    property vector2d iResolution: Qt.vector2d(width+2, height+2)
    property vector2d boxSize: Qt.vector2d(width/2, height/2)
    property color glowColor: Qt.color(1., 1., 1., .15)
    property real glowEdgeBand: 0.01
    property color baseColor: "#10000000"
    property color _baseColor: "#10000000"
    property vector2d lightDir: Qt.vector2d(-1., 1.)
    ShaderEffect {
        id: glowBox
        anchors.fill: parent
        property vector2d iResolution: box.iResolution
        property vector2d boxSize: box.boxSize
        property vector4d cornerRadii: box.cornerRadii
        property vector4d glowColor: Qt.vector4d(box.glowColor.r, box.glowColor.g, box.glowColor.b, box.glowColor.a)
        property real glowEdgeBand: box.glowEdgeBand
        property vector4d baseColor: Qt.vector4d(box.baseColor.r, box.baseColor.g, box.baseColor.b, box.baseColor.a)
        property var source: box.source

        property var lightDir: box.lightDir

        fragmentShader: Qt.resolvedUrl(Quickshell.shellDir + "/media/shaders/grxframe.frag.qsb")
        vertexShader: Qt.resolvedUrl(Quickshell.shellDir + "/media/shaders/grxframe.vert.qsb")
    }
}