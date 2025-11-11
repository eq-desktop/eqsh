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
  property bool blockHoverColor: false
  property bool blockHoverColorSelected: false
  property bool selected: false
  property bool isHovered: false
  palette.buttonText: "#fff"
  Layout.fillHeight: true
  Layout.fillWidth: true
  height: 25
  Layout.maximumHeight: 25
  Layout.minimumWidth: 50

  implicitWidth: Math.max(contentItem.implicitWidth + leftPadding + rightPadding, 50)
  implicitHeight: 25

  property color hoverColor: Config.bar.buttonColorMode == 1 ? Qt.darker(AccentColor.color, 2) : Config.bar.buttonColorMode == 2 ? "transparent" : Config.bar.buttonColor
  scale: 1
  padding: 10
  background: Box {
    id: bgRect
    color: (root.selected && !root.blockHoverColorSelected ? root.hoverColor : (root.isHovered && !root.blockHoverColor ? root.hoverColor : "transparent"))
    radius: 20
    opacity: 0.8
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
      root.hover()
      root.isHovered = true
    }
    onExited: {
      root.exited()
      root.isHovered = false
    }
    onClicked: {
      root.click()
    }
  }
}