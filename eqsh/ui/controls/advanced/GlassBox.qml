import QtQuick
import Quickshell
import QtQuick.Controls
import QtQuick.Effects

Item {
    id: box

    property color color: "#10ffffff"
    property bool highlightEnabled: true
    property bool transparent: false
    default property var source: null
    property var blurSource: null
    property real boxW: width-2
    property real boxH: height-2
    property var boxPos: Qt.size(0, 0)
    property var boxSize: Qt.size(boxW, boxH)
    
    property color light: '#40ffffff'
    property var   lightDir: Qt.point(1, -0.2)
    property real  rimSize: 0.8
    property real  rimStrength: 1.0

    // Individual corner radii
    property int radius: 50

    property int animationSpeed: 16
    property int animationSpeed2: 16

    property real glassBevel: 15
    property real glassMaxRefractionDistance: glassBevel
    property real glassHairlineWidthPixels: 5
    property real glassHairlineReflectionDistance: 20

    Behavior on color { PropertyAnimation { duration: animationSpeed; easing.type: Easing.InSine } }
    
    Glass {
        id: boxContainer
        anchors.fill: parent
        color: box.transparent ? "transparent" : box.color
        radius: box.radius
        source: box.source
        boxPos: box.boxPos
        blurSource: box.blurSource
        boxSize: box.boxSize
        glassBevel: Math.min(box.glassBevel, boxContainer.smallerVal / 2)
        glassMaxRefractionDistance: box.glassMaxRefractionDistance
        glassHairlineWidthPixels: box.glassHairlineWidthPixels
        glassHairlineReflectionDistance: box.glassHairlineReflectionDistance
        glowColor: box.highlightEnabled ? box.light : Qt.rgba(0,0,0,0)
        lightDir: box.lightDir
        glowEdgeBand: box.rimSize
        glowAngWidth: box.rimStrength
    }
}
