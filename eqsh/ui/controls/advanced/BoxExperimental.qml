import QtQuick
import QtQuick.Controls
import qs.ui.controls.auxiliary
import qs.ui.controls.providers
import QtQuick.Effects

Item {
    id: box

    property color color: "#bb000000"
    property int borderSize: 1
    property real shadowOpacity: 0.5
    property color highlight: '#fff'
    property bool enableShadow: highlight != "transparent"
    property color negHighlight: Colors.complementary(highlight)

    // Individual corner radii
    property int radius: 20

    property int animationSpeed: 16
    property int animationSpeed2: 16

    Behavior on color { PropertyAnimation { duration: animationSpeed; easing.type: Easing.InSine } }
    Behavior on highlight { PropertyAnimation { duration: animationSpeed2; easing.type: Easing.InSine } }
    
    Box {
        id: boxContainer
        anchors.fill: parent
        color: box.color
        radius: box.radius
        highlight: box.highlight
        opacity: box.enableShadow ? 0 : 1
    }

    // First inner shadow
    InnerShadow {
        strength: 3
        offsetX: 0
        offsetY: -3
        color: "#fff"
        opacity: 0.5
        visible: box.enableShadow
    }

    // Second inner shadow
    InnerShadow {
        strength: 3
        offsetX: 0
        offsetY: 3
        color: "#000"
        opacity: 0.3
        visible: box.enableShadow
    }

    Box {
        id: boxContainer2
        anchors.fill: parent
        color: "#40000000"
        radius: box.radius
        highlight: "#eeaaaaaa"
        opacity: box.enableShadow ? 1 : 0
    }
}
