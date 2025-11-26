//@ pragma UseQApplication
//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma IconTheme MacTahoe-dark
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes

Scope {
  id: root

  PanelWindow {
    mask: Region {}

    anchors {
      top: true
      left: true
      right: true
      bottom: true
    }

    color: "transparent"
    Item {
      id: win

      anchors.fill: parent
      anchors.margins: -20

      opacity: 0

      Component.onCompleted: {
        opacity = 1
        anchors.margins = 0
      }

      Behavior on opacity {
        NumberAnimation {
          duration: 500
        }
      }

      Behavior on anchors.margins {
        NumberAnimation {
          duration: 500
        }
      }

      ConicalGradient {
        id: cg
        centerX: border.width / 2
        centerY: border.height / 2
        GradientStop { position: 0.08; color: "#C686FF" }
        GradientStop { position: 0.19; color: "#FFBA71" }
        GradientStop { position: 0.30; color: "#FF6778" }
        GradientStop { position: 0.42; color: "#AA6EEE" }
        GradientStop { position: 0.64; color: "#8D99FF" }
        GradientStop { position: 0.76; color: "#F5B9EA" }
        GradientStop { position: 0.83; color: "#BC82F3" }
        GradientStop { position: 1.00; color: "#C686FF" }
      }
      SequentialAnimation {
        id: anim
        running: true
        loops: -1
        PropertyAnimation { target: win; property: "angle"; from: 270; to: 360; duration: 1000; easing.type: Easing.Linear }
        PropertyAnimation { target: win; property: "angle"; from: 0; to: 90; duration: 1000; easing.type: Easing.Linear }
        PropertyAnimation { target: win; property: "angle"; to: 180; duration: 1000; easing.type: Easing.Linear }
        PropertyAnimation { target: win; property: "angle"; to: 270; duration: 1000; easing.type: Easing.Linear }
      }

      property int angle: 0

      Border {
        id: border
        borderWidth: 4
        angle: win.angle
        borderGradient: cg
        visible: false
      }
      Border {
        id: border2
        borderWidth: 7
        angle: win.angle
        borderGradient: cg
        visible: false
      }
      MultiEffect {
        id: blur
        source: border
        anchors.fill: parent
        blurEnabled: true
        blur: 0.2
        visible: true
      }
      MultiEffect {
        id: blur2
        source: border2
        anchors.fill: parent
        blurEnabled: true
        blur: 1.0
        blurMax: 64
        visible: true
      }
    }
  }
}
