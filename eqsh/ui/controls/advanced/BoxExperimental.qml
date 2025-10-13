import QtQuick
import QtQuick.Controls
import qs.config
import qs.ui.controls.auxiliary
import qs.ui.controls.providers
import QtQuick.Effects

Item {
    id: box

    property color color: Config.general.darkMode ? "#20000000" : "#50ffffff"
    property int borderSize: 1
    property real shadowOpacity: 0.5
    property bool highlightEnabled: true
    
    property color light: '#a0ffffff'
    property real  glowStrength: 0.8
    property color negLight: '#80000000'

    // Individual corner radii
    property int radius: 20

    property int animationSpeed: 16
    property int animationSpeed2: 16

    Behavior on color { PropertyAnimation { duration: animationSpeed; easing.type: Easing.InSine } }
    
    Box {
        id: boxContainer
        anchors.fill: parent
        color: box.color
        radius: box.radius
        highlight: "transparent"
    }

    // First inner shadow
    InnerShadow {
        strength: box.glowStrength*2.5 // 0.8*
        offsetX: 0
        offsetY: -box.glowStrength*2.5
        color: box.light
        opacity: box.glowStrength
        blurMax: 40
        visible: box.highlightEnabled
    }

    // Second inner shadow
    InnerShadow {
        strength: 3
        offsetX: 0
        offsetY: 3
        color: box.negLight
        blurMax: 64
        opacity: 0.7
        visible: box.highlightEnabled
    }

    Box {
        id: boxContainer2
        anchors.fill: parent
        color: "transparent"
        radius: box.radius
        highlight: highlightEnabled ? "#20ffffff" : "transparent"
    }
}
