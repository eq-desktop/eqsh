import QtQuick
import QtQuick.Effects
import Quickshell

Item {
    id: box
    property real radius: 20.0
    property var color: "#fff"
    property var source: null
    property var blurSource: null
    property real smallerVal: Math.min(width, height)
    property var cornerRadii: Qt.vector4d(Math.min(radius, smallerVal / 2),
                                          Math.min(radius, smallerVal / 2),
                                          Math.min(radius, smallerVal / 2),
                                          Math.min(radius, smallerVal / 2))
    onCornerRadiiChanged: {
        cornerRadii.x = Math.min(cornerRadii.x, smallerVal / 2)
        cornerRadii.y = Math.min(cornerRadii.y, smallerVal / 2)
        cornerRadii.z = Math.min(cornerRadii.z, smallerVal / 2)
        cornerRadii.w = Math.min(cornerRadii.w, smallerVal / 2)
    }
    property var iResolution: Qt.point(width, height)
    property var boxPos: Qt.point(0, 0)
    property var boxSize: Qt.point(width, height)
    property var glowColor: Qt.rgba(1,1,1,1)
    property real glowIntensity: 1.0
    property real glowEdgeBand: 1.0
    property real glowAngWidth: 1.7
    property real glowTheta1: 0.0
    property real glowTheta2: Math.PI
    property var lightDir: Qt.vector2d(1, 1)
    property real glassBevel: Math.min(requestedGlassBevel, smallerVal / 2)
    property real requestedGlassBevel: 0
    property real glassMaxRefractionDistance: glassBevel
    property real glassHairlineWidthPixels: 2
    property real glassHairlineReflectionDistance: 20
    ShaderEffect {
        id: glowBox
        anchors.fill: parent
        property var iResolution: box.iResolution
        property var boxPos: box.boxPos
        property var boxSize: box.boxSize
        property var cornerRadii: box.cornerRadii
        property var glowColor: box.glowColor
        property real glowIntensity: box.glowIntensity
        property real glowEdgeBand: box.glowEdgeBand
        property real glowAngWidth: box.glowAngWidth
        property real glowTheta1: box.glowTheta1
        property real glowTheta2: box.glowTheta2
        property real glassBevel: box.glassBevel
        property real glassMaxRefractionDistance: box.glassMaxRefractionDistance
        property real glassHairlineWidthPixels: box.glassHairlineWidthPixels*100
        property real glassHairlineReflectionDistance: box.glassHairlineReflectionDistance
        property bool blurAvailable: box.blurSource !== null
        property var  source: box.source
        property var  blurSource: box.blurSource ? box.blurSource : box.source

        property var lightDir: box.lightDir

        fragmentShader: Qt.resolvedUrl(Quickshell.shellDir + "/media/shaders/lgxframe.frag.qsb")
        vertexShader: Qt.resolvedUrl(Quickshell.shellDir + "/media/shaders/lgxframe.vert.qsb")
    }
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin:  box.boxPos.y
        anchors.leftMargin: box.boxPos.x
        width: box.boxSize.x
        height: box.boxSize.y
        color: box.color
        radius: box.radius
    }
}