import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import Quickshell
import qs.config

Item {
    id: root
    anchors.fill: parent

    property int radius: 20        // corner radius
    property real xPos: 100        // rectangle position x
    property real yPos: 100        // rectangle position y
    property real widthVal: 400    // rectangle width
    property real heightVal: 250   // rectangle height

    // Background image with aspect ratio preserved
    Image {
        id: img
        anchors.fill: parent
        source: Config.wallpaper.path
        fillMode: Image.PreserveAspectCrop
        smooth: true
        visible: false
    }

    // Rounded rectangle mask
    Shape {
        id: maskShape
        width: widthVal
        height: heightVal
        x: xPos
        y: yPos
        preferredRendererType: Shape.CurveRenderer
        smooth: true
        antialiasing: true

        ShapePath {
            strokeWidth: 0
            fillColor: "white"

            startX: 0; startY: radius

            PathLine { x: 0; y: height}

            PathLine { x: width; y: height }

            PathLine { x: width; y: 0 }

            PathLine { x: 0; y: 0 }
        }
    }

    // Mask source
    ShaderEffectSource {
        id: maskSource
        sourceItem: maskShape
        hideSource: true
    }

    // Apply mask to image
    MultiEffect {
        anchors.fill: parent
        source: img
        maskSource: maskSource
        maskEnabled: true
        maskInverted: false
    }
}
