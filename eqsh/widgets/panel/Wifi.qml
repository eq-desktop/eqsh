import QtQuick
import QtQuick.VectorImage
import QtQuick.Layouts
import Quickshell
import qs.services

Item {
  id: root

  property int iconSize: 24

  readonly property bool wifiEnabled: Network.wifiEnabled
  readonly property int networkStrength: Network.active ? Network.active.strength : 0
  property string networkIcon: {
    (networkStrength > 90) ? "100" : (networkStrength > 66) ? "66" : (networkStrength > 33) ? "33" : "0";
  }

  anchors.centerIn: parent

  VectorImage {
    id: rBWifi
    source: "../../assets/svgs/wifi/nm-signal-" + networkIcon +  "-symbolic.svg"
    width: root.iconSize
    height: root.iconSize
    Layout.preferredWidth: root.iconSize
    Layout.preferredHeight: root.iconSize
    preferredRendererType: VectorImage.CurveRenderer
    anchors {
      centerIn: parent
    }
    transform: Translate {y:-4}
  }
}