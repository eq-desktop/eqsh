import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell

Rectangle {
  id: root
  anchors.fill: parent
  property Gradient borderGradient: null
  property int borderWidth: 4
  property int angle: 0
  radius: 20
  color: "transparent"

  Loader {
    id: loader
    anchors.fill: parent
    active: borderGradient
    sourceComponent: border
  }

  Component {
    id: border
    Item {
      ConicalGradient {
        id: borderFill
        anchors.fill: parent
        gradient: borderGradient
        angle: root.angle
        visible: false
      }

      Rectangle {
        id: mask
        radius: root.radius
        border.width: root.borderWidth
        anchors.fill: parent
        color: 'transparent'
        visible: false
      }

      OpacityMask {
        id: opM
        anchors.fill: parent
        source: borderFill
        maskSource: mask
      }
    }
  }
}