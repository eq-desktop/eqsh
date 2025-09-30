import QtQuick
import QtQuick.Shapes
import QtQuick.VectorImage
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import qs.config
import Quickshell.Widgets
import Quickshell.Services.UPower

Item {
  id: root

  property int iconSize: 24
  property string batteryMode: Config.bar.batteryMode
  property string chargeColor: "#fff"
  property string textColor: "#000"
  property string borderColor: "#aaa"
  property bool allowZap: true
  readonly property bool batCharging: UPower.onBattery ? (UPower.displayDevice.state == UPowerDeviceState.Charging) : true
  readonly property string batIcon: {
    (batPercentage > 0.98) ? "100" : (batPercentage > 0.90) ? "090" : (batPercentage > 0.80) ? "080" : (batPercentage > 0.70) ? "070" : (batPercentage > 0.60) ? "060" : (batPercentage > 0.50) ? "050" : (batPercentage > 0.40) ? "040" : (batPercentage > 0.30) ? "030" : (batPercentage > 0.20) ? "020" : (batPercentage > 0.10) ? "010" : "000";
  }
  readonly property real batPercentage: UPower.displayDevice.isLaptopBattery ? UPower.displayDevice.percentage : 1

  anchors.centerIn: parent

  component BatteryCon: Shape {
    id: rBContact
    width: 8
    height: rBLoader.height
    anchors.left: rBPillBorder.right
    anchors.leftMargin: 2
    anchors.verticalCenter: parent.verticalCenter
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      strokeWidth: 0
      fillColor: root.borderColor

      startX: 0
      startY: 0

      PathAngleArc {
        centerX: 0
        centerY: rBContact.height / 2
        radiusX: 2
        radiusY: 2
        startAngle: -90
        sweepAngle: 180
      }
    }
  }
 
  Loader {
    id: rBLoader
    anchors.centerIn: parent
    property Component pillMode: Rectangle {
      id: rBBackground
      width: root.iconSize+6
      height: root.iconSize+6
      anchors.centerIn: parent
      color: "transparent"
      Rectangle {
        id: rBPillBorder
        width: parent.width - 4
        height: parent.height - 17
        radius: 5
        color: "transparent"
        border {
          width: 1
          color: root.borderColor
        }
        anchors.centerIn: parent
        ClippingRectangle {
          id: rBPill
          width: parent.width - 4
          height: parent.height - 4
          radius: 3
          anchors.centerIn: parent
          color: "transparent"
          Rectangle {
            id: rBForeground
            width: parent.width * batPercentage
            height: parent.height
            anchors.left: parent.left
            color: root.chargeColor
          }
        }
        Text {
          id: rBText
          text: Math.round(batPercentage * 100) + Config.bar.batteryMode == "percentage-pill" ? "%" : ""
          anchors.centerIn: parent
          color: root.textColor
          font.pixelSize: 8
          visible: Config.bar.batteryMode != "pill"
        }
      }
      BatteryCon {}
    }
    property Component percentageMode: Rectangle {
      Text {
        id: rBText
        text: Math.round(batPercentage * 100) + (Config.bar.batteryMode == "percentage" ? "%" : "")
        anchors.centerIn: parent
        color: root.textColor
        font.pixelSize: 12
      }
    }
    property Component bubbleMode: Rectangle {
      id: rBBackground
      width: root.iconSize+6
      height: root.iconSize+6
      anchors.centerIn: parent
      color: "transparent"
      ClippingRectangle {
        id: rBPill
        width: parent.width - 4
        height: parent.height - 16
        radius: 5
        anchors.centerIn: parent
        color: "#80ffffff"
        Rectangle {
          id: rBForeground
          width: parent.width * batPercentage
          height: parent.height
          anchors.left: parent.left
          color: root.chargeColor
        }
      }
      Text {
        id: rBText
        text: Math.round(batPercentage * 100)
        anchors.centerIn: parent
        color: root.textColor
        font.weight: 600
        transform: Translate { x: -1; }
        visible: Config.bar.batteryMode == "bubble-percentage"
        font.pixelSize: 12
      }
      BatteryCon {
        anchors.left: rBPill.right
      }
    }
    sourceComponent: ["pill", "percentage-pill", "number-pill"].includes(root.batteryMode) ? pillMode : ["percentage", "number"].includes(root.batteryMode) ? percentageMode : bubbleMode
  }

  VectorImage {
    id: rBWifi
    source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/battery/zap.svg")
    width: 14
    height: 14
    Layout.preferredWidth: 14
    Layout.preferredHeight: 14
    preferredRendererType: VectorImage.CurveRenderer
    anchors.centerIn: parent
    visible: (!UPower.onBattery && ["pill", "bubble", "percentage-pill", "number-pill"].includes(root.batteryMode)) && root.allowZap
  }
}