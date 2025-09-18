import QtQuick
import QtQuick.Controls
import qs.ui.Controls.Auxiliary
import qs.ui.Controls.providers
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

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
        opacity: box.enableShadow ? 0 : 1
    }

    // Capture it as a texture
    ShaderEffectSource {
        id: rectSource
        sourceItem: boxContainer
        live: true
        hideSource: box.enableShadow
        visible: box.enableShadow
    }

    // First inner shadow
    InnerShadow {
        anchors.fill: parent
        source: rectSource
        radius: 6
        samples: 16
        horizontalOffset: 0
        verticalOffset: -3
        color: highlight // "#ff0000"
        opacity: box.shadowOpacity
        visible: box.enableShadow
    }

    // Second inner shadow
    InnerShadow {
        anchors.fill: parent
        source: rectSource
        radius: 4
        samples: 16
        horizontalOffset: 0
        verticalOffset: 3
        color: negHighlight// "#0000ff"
        opacity: box.shadowOpacity/2
        visible: box.enableShadow
    }

    Box {
        id: boxContainer2
        anchors.fill: parent
        color: "transparent"
        radius: box.radius
        opacity: box.enableShadow ? 1 : 0
    }
}
