import QtQuick
import QtQuick.VectorImage
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import qs.core.system

Item {
  id: root

  property int iconSize: 24
  property string color: "#fff"

  readonly property bool wifiEnabled: NetworkManager.wifiEnabled
  property int networkStrength: NetworkManager.active ? NetworkManager.active.strength : 0
  property string networkIcon: {
    (networkStrength > 90) ? "100" : (networkStrength > 66) ? "66" : (networkStrength > 33) ? "33" : "0";
  }

  anchors.centerIn: parent

  VectorImage {
    id: rBWifi
    source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/wifi/nm-signal-" + networkIcon +  "-symbolic.svg")
    width: root.iconSize
    height: root.iconSize
    Layout.preferredWidth: root.iconSize
    Layout.preferredHeight: root.iconSize
    preferredRendererType: VectorImage.CurveRenderer
    anchors {
      centerIn: parent
    }
    transform: Translate {y:-4}
    layer.enabled: true
    layer.samples: 16
    layer.effect: MultiEffect {
      colorization: 1
      colorizationColor: root.color
    }
  }
}