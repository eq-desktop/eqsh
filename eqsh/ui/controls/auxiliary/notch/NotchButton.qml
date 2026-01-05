import QtQuick
import Quickshell
import qs.config
import qs
import qs.core.system
import qs.ui.controls.providers
import qs.ui.controls.auxiliary.notch
import qs.ui.components.panel
import qs.ui.controls.advanced
import QtQuick.VectorImage
import QtQuick.Controls
import QtQuick.Effects

Button {
    id: root
    width: 40
    height: 40
    property string backgroundColor: "#30ff4925"
    property string iconSource: ""
    property int _lenIconSource: root.iconSource.split(".").length
    property int iconSize: 25
    property string iconColor: "#ff4925"
    property string color: "#ffffff"
    background: BoxGlass {
        anchors.fill: parent
        color: root.backgroundColor
        light: Qt.lighter(root.backgroundColor)
        radius: 99
        VectorImage {
            source: root.iconSource.split(".")[root._lenIconSource-1] === "svg" ? root.iconSource : ""
            visible: root.iconSource.split(".")[root._lenIconSource-1] === "svg"
            width: root.iconSize
            height: root.iconSize
            preferredRendererType: VectorImage.CurveRenderer
            anchors.centerIn: parent
            layer.enabled: true
            layer.effect: MultiEffect {
                colorization: 1
                colorizationColor: root.iconColor
            }
        }
        Image {
            source: root.iconSource.split(".")[root._lenIconSource-1] === "png" ? root.iconSource : ""
            visible: root.iconSource.split(".")[root._lenIconSource-1] === "png"
            width: root.iconSize
            height: root.iconSize
            anchors.centerIn: parent
            fillMode: Image.PreserveAspectFit
        }
    }
    palette.buttonText: root.color
    onClicked: {}
}