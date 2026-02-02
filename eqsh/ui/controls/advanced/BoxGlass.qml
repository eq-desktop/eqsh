import QtQuick
import Quickshell
import QtQuick.Controls
import QtQuick.Effects
import qs.ui.controls.advanced

Item {
    id: box

    property color color: "#10000000"
    property bool highlightEnabled: true
    property bool transparent: false
    
    property color light: '#40ffffff'
    property vector2d   lightDir: Qt.vector2d(-1, 1)
    property real  rimSize: 0.01
    property real  rimStrength: 1.0

    property var negLight: ""
    property var highlight: ""
    property var shadowOpacity: ""

    // Individual corner radii
    property real radius: 50

    property int animationSpeed: 16
    property int animationSpeed2: 16

    Behavior on color { PropertyAnimation { duration: animationSpeed; easing.type: Easing.InSine } }
    
    GlassRim {
        id: boxContainer
        anchors.fill: parent
        baseColor: box.transparent ? "transparent" : box.color
        radius: box.radius
        glowColor: box.highlightEnabled ? box.light : "#00000000"
        lightDir: box.lightDir
        glowEdgeBand: box.rimSize
    }
}
