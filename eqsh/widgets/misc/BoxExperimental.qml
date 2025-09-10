import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

Item {
    id: box

    property color color: "#bb000000"
    property int borderSize: 1
    property string highlight: '#fff'

    // Individual corner radii
    property int radius: 20

    property int animationSpeed: 16
    property int animationSpeed2: 16

    Behavior on color { PropertyAnimation { duration: animationSpeed; easing.type: Easing.InSine } }
    Behavior on highlight { PropertyAnimation { duration: animationSpeed2; easing.type: Easing.InSine } }

    InnerShadow {
        id: boxContainerEffect2
        anchors.fill: boxContainerEffect1
        radius: 1
        samples: 16
        spread: 0
        color: highlight
        horizontalOffset: -1
        verticalOffset: -1
        source: boxContainerEffect1
    }
    InnerShadow {
        id: boxContainerEffect1
        anchors.fill: boxContainer
        radius: 1
        samples: 16
        spread: 0
        color: highlight
        horizontalOffset: 1
        verticalOffset: 1
        source: boxContainer
    }

    Rectangle {
        id: boxContainer
        anchors.fill: parent
        color: box.color
        radius: box.radius
        opacity: 0
    }
}
