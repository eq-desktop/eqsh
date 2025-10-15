import Quickshell
import QtQuick
import QtQuick.VectorImage
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs
import qs.core.foundation
import qs.ui.controls.auxiliary
import qs.ui.controls.providers
import QtQuick.Controls.Fusion

Button {
  id: root
  signal click()
  signal hover()
  signal exited()
  palette.buttonText: "#fff"
  Layout.minimumWidth: 50
  Layout.preferredHeight: 25
  property color hoverColor: Config.bar.buttonColorMode == 1 ? Qt.darker(AccentColor.color, 2) : Config.bar.buttonColorMode == 2 ? "transparent" : Config.bar.buttonColor
  scale: 1
  Layout.maximumHeight: Config.bar.height * 1.05
  padding: 10
  background: Box {
    id: bgRect
    color: "transparent"
    radius: 20
    highlight: "transparent"
  }
  contentItem: Text {
    id: content
    anchors.fill: parent
    color: palette.buttonText
    text: root.text
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    font: root.font
    renderType: Text.NativeRendering
    renderTypeQuality: Text.VeryHighRenderTypeQuality
  }
  SequentialAnimation {
    id: jumpAnim
    running: false
    loops: 1
    PropertyAnimation { target: root; property: "scale"; to: 1.2; duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1 }
    PropertyAnimation { target: root; property: "scale"; to: 1  ; duration: 500; easing.type: Easing.OutBack; easing.overshoot: 1 }
  }
  function jumpUp() {
    if (Config.bar.animateButton) jumpAnim.running = true
  }
  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: {
      bgRect.color = root.hoverColor;
      root.hover()
    }
    onExited: {
      bgRect.color = "transparent";
      root.exited()
    }
    onClicked: {
      root.click()
    }
  }
}