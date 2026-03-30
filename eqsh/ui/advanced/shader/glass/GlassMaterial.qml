import QtQuick
import Quickshell
import QtQuick.Effects


Item {
    id: root
    property var source
    property var blurSource
    property var bloomSource
    property var maskSource
    property int materialType: 1
    property real xPos: 0
    property real yPos: 0
    property real xDisplayPos: xPos
    property real yDisplayPos: yPos
    property real widthSize: 100
    property real heightSize: 100
    property vector2d pos: Qt.vector2d(xPos, yPos)
    property vector2d displayPos: Qt.vector2d(xDisplayPos, yDisplayPos)
    property vector2d size: Qt.vector2d(widthSize, heightSize)
    Behavior on widthSize { NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 2 } }
    Behavior on heightSize { NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 2 } }
    Behavior on xPos { NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1 } }
    Behavior on yPos { NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1 } }
    property real rot: 0
    property real radius: 25

    property real glassRefractionDim: 25
    property real glassRefractionMag: 25
    property real glassRefractionAberration: 5
    property vector3d glassRefractionIOR: Qt.vector3d(1.51, 1.52, 1.53)

    property real glassEdgeDim: 1
    property vector4d glassTintColor: Qt.vector4d(1, 1, 1, 0)
    property int blurAmount: 15

    property vector2d rimLightDir: Qt.point(-1, 1)
    property vector4d rimLightColor: Qt.vector4d(1, 1, 1, .15)

    property real reflectionOffsetMin: 0
    property real reflectionOffsetMag: 0

    property real fieldSmoothing: 5
    ShaderEffect {
        id: glass
        anchors.fill: parent
        property variant source: root.source
        property variant blurSource: root.blurSource
        property variant bloomSource: root.bloomSource
        property variant maskSource: root.maskSource
        property vector2d iResolution: Qt.vector2d(width, height)

        property vector4d glassRefraction: Qt.vector4d(root.glassRefractionDim, root.glassRefractionMag, root.glassRefractionAberration, 0)
        property vector4d glassRefractionIOR: Qt.vector4d(root.glassRefractionIOR.x, root.glassRefractionIOR.y, root.glassRefractionIOR.z, 0)

        property vector4d glassEdgeDim: Qt.vector4d(root.glassEdgeDim, 0, 0, 0)  // Edge area size
        property vector4d glassTintColor: Qt.vector4d(root.glassTintColor.x, root.glassTintColor.y, root.glassTintColor.z, root.glassTintColor.w)  // Tint color
        property vector4d blurAmount: Qt.vector4d(root.blurAmount, 0, 0, 0)  // Blur

        property vector4d rimLightDir: Qt.vector4d(root.rimLightDir.x, root.rimLightDir.y, 0, 0)  // Rim light angle
        property vector4d rimLightColor: Qt.vector4d(root.rimLightColor.x, root.rimLightColor.y, root.rimLightColor.z, root.rimLightColor.w)  // Rim light color

        property vector4d reflectionOffset: Qt.vector4d(root.reflectionOffsetMin, root.reflectionOffsetMag, 0, 0)  // min mag

        property vector4d fieldSmoothing: Qt.vector4d(root.fieldSmoothing, 0, 0, 0)
        property vector4d shape: Qt.vector4d(root.pos.x, root.pos.y, root.size.x/2, root.size.y/2)
        property vector4d shapeExt: Qt.vector4d(root.radius, root.rot, root.materialType, 0)
        fragmentShader: Qt.resolvedUrl(Quickshell.shellDir + "/media/shaders/glassMatVulkan.frag.qsb")
        vertexShader: Qt.resolvedUrl(Quickshell.shellDir + "/media/shaders/vertex.vert.qsb")
    }
}