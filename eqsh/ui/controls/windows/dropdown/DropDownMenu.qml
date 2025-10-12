import Quickshell
import QtQuick
import QtQuick.VectorImage
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland
import qs.config
import qs
import qs.core.foundation
import qs.ui.controls.auxiliary
import qs.ui.controls.advanced
import qs.ui.controls.providers
import QtQuick.Controls.Fusion
import qs.ui.controls.windows

Scope {
  id: root
  property int x: 0
  property int y: 0
  property int minWidth: 200
  property int contentWidth: 200
  property int padding: 8
  property int spacing: 0
  property var hoverColor: AccentColor.color
  function open() {
    pop.opened = true
  }
  property list<DropDownItem> model // ⌘, ⌃, ⌥, ⇧
  default property Component delegate: Item {
    id: dropItem
    required property var modelData
    width: root.contentWidth
    height: modelData.type == "spacer" ? 10 : 30
    property bool hover: false
    Loader {
      anchors.fill: parent
      active: modelData.type == "spacer" ? true : false
      sourceComponent: Item {
        anchors.fill: parent
        Rectangle {
          anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
          }
          height: 1
          radius: 2
          color: "#50ffffff"
        }
      }
    }
    Loader {
      anchors.fill: parent
      active: modelData.type == "spacer" ? false : true
      sourceComponent: MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: dropItem.hover = true
        onExited: dropItem.hover = false
        enabled: !modelData.disabled
        onClicked: {
          if (modelData.type == "item") {
            modelData.action()
            pop.opened = false
          }
        }
        property var mDName: dropItem.modelData.name
        TextMetrics {
          id: metrics
          text: modelData.name
          font.pixelSize: 15
        }
        Component.onCompleted: {
          // Add icon + margins (100px) to the measured text width
          const w = metrics.width + (!modelData.kb ? 0 : 100)
          if (w > root.contentWidth)
          root.contentWidth = w
        }
        onMDNameChanged: {
          const w = metrics.width + (!modelData.kb ? 0 : 100)
          if (w > root.contentWidth)
          root.contentWidth = w
        }
        Rectangle {
          anchors.fill: parent
          radius: 8
          color: dropItem.hover ? root.hoverColor : "transparent"
          IconImage {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 5
            height: 15
            width: 15
            source: modelData.icon
            layer.enabled: true
            layer.effect: MultiEffect {
              colorization: 1
              colorizationColor: modelData.disabled ? "#50ffffff" : "white"
            }
          }
          Text {
            anchors.fill: parent
            anchors.leftMargin: 30
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            text: modelData.name
            font.pixelSize: 15
            color: modelData.disabled ? "#50ffffff" : "white"
          }
          Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 5
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            text: modelData.kb
            font.pixelSize: 15
            color: "#50ffffff"
          }
        }
      }
    }
  }
  Pop {
    id: pop
    content: Item {
      BoxExperimental {
        x: root.x
        y: root.y
        radius: 15
        width: Math.max(root.contentWidth + root.padding * 2, 200)
        height: list.contentHeight+(root.padding*2)
        ListView {
          id: list
          anchors.fill: parent
          anchors.margins: root.padding
          delegate: root.delegate
          model: root.model
          spacing: root.spacing
        }
      }
    }
  }
}