import QtQuick
import QtQuick.VectorImage
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower

Item {
  id: root

  property int iconSize: 24

  readonly property bool batCharging: UPower.onBattery ? (UPower.displayDevice.state == UPowerDeviceState.Charging) : true
  readonly property string batIcon: {
    (batPercentage > 0.98) ? "100" : (batPercentage > 0.90) ? "090" : (batPercentage > 0.80) ? "080" : (batPercentage > 0.70) ? "070" : (batPercentage > 0.60) ? "060" : (batPercentage > 0.50) ? "050" : (batPercentage > 0.40) ? "040" : (batPercentage > 0.30) ? "030" : (batPercentage > 0.20) ? "020" : (batPercentage > 0.10) ? "010" : "000";
  }
  readonly property real batPercentage: UPower.onBattery ? UPower.displayDevice.percentage: 1

  anchors.centerIn: parent

  VectorImage {
    id: rBWifi
    source: "../../assets/svgs/battery/battery-" + batIcon + (batCharging ? "-charging" : "") + ".svg"
    width: root.iconSize
    height: root.iconSize
    Layout.preferredWidth: root.iconSize
    Layout.preferredHeight: root.iconSize
    preferredRendererType: VectorImage.CurveRenderer
    anchors.centerIn: parent
  }
}