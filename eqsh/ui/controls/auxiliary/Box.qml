import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Item {
    id: box

    property color color: "#20000000"
    property int borderSize: 1
    property color highlight: '#40ffffff'

    // Individual corner radii
    property int radius: 20
    property int topLeftRadius: radius
    property int topRightRadius: radius
    property int bottomRightRadius: radius
    property int bottomLeftRadius: radius

    property int animationSpeed: 16
    property int animationSpeed2: 16

    Behavior on color { PropertyAnimation { duration: animationSpeed; easing.type: Easing.InSine } }
    Behavior on highlight { PropertyAnimation { duration: animationSpeed2; easing.type: Easing.InSine } }

    Rectangle {
        anchors.fill: parent
        radius: box.radius
        color: "transparent"
        border {
            width: box.borderSize
            color: box.highlight
        }
    }
    Rectangle {
        anchors.fill: parent
        radius: box.radius
        color: box.color
    }
}
