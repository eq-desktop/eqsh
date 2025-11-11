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
  property int verticalOffset: 0
  property int horizontalOffset: 0
  property int contentWidth: 200
  property int padding: 4
  property int spacing: 0
  property var margins: [0, 0, 0, 0]
  property alias opened: pop.opened
  property bool new_Focus_Method: false
  property var windows: []
  property bool closeOnClick: true
  property var hoverColor: AccentColor.color
  property var color: Config.general.darkMode ? "#1e1e1e" : "#dfdfdf" //"#20000000" : "#50ffffff"
  property var textColor: Config.general.darkMode ? "#ffffff" : "#1e1e1e" //"#20000000" : "#50ffffff"
  property var hoverTextColor: "#ffffff" //"#20000000" : "#50ffffff"
  enum AnchorPoint { TopLeft = 0, TopRight = 1, BottomLeft = 2, BottomRight = 3, Auto = 4 }
  property int anchorPoint: DropDownMenu.AnchorPoint.Auto
  property bool invertY: [DropDownMenu.AnchorPoint.BottomLeft, DropDownMenu.AnchorPoint.BottomRight].includes(anchorPoint)
  property bool invertH: [DropDownMenu.AnchorPoint.TopRight, DropDownMenu.AnchorPoint.BottomRight].includes(anchorPoint)
  function open() {
    pop.opened = true
  }
  signal cleared()
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
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
          }
          width: root.contentWidth - 20
          height: 1
          radius: 2
          color: Config.general.darkMode ? "#50ffffff" : "#50000000"
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
            pop.opened = !root.closeOnClick
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
          const w = metrics.width + (!modelData.kb ? 0 : 100) + 44 // 60 = Icon width + right Icon width
          if (w > root.contentWidth)
          root.contentWidth = w
        }
        onMDNameChanged: {
          const w = metrics.width + (!modelData.kb ? 0 : 100) + 44 // 60 = Icon width + right Icon width
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
            anchors.leftMargin: 2
            height: 15
            width: 15
            source: modelData.icon
            layer.enabled: true
            layer.effect: MultiEffect {
              colorization: 1
              colorizationColor: modelData.disabled ? (Config.general.darkMode ? "#50ffffff" : "#50000000") : dropItem.hover ? root.hoverTextColor : Config.general.darkMode ? "#ffffff" : "#1e1e1e"
            }
          }
          Text {
            anchors.fill: parent
            anchors.leftMargin: 22
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            text: modelData.name
            font.pixelSize: 15
            color: modelData.disabled ? (Config.general.darkMode ? "#50ffffff" : "#50000000") : dropItem.hover ? root.hoverTextColor : Config.general.darkMode ? "#ffffff" : "#1e1e1e"
          }
          Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 5
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            text: modelData.kb
            font.pixelSize: 15
            color: dropItem.hover ? "#50ffffff" : Config.general.darkMode ? "#50ffffff" : "#50000000"
          }
        }
      }
    }
  }
  Pop {
    id: pop
    blur: true
    windows: root.windows
    margins {
      left: root.margins[0]
      top: root.margins[1]
      right: root.margins[2]
      bottom: root.margins[3]
    }
    new_Focus_Method: root.new_Focus_Method
    new_Focus_Method_X: pop.contentItem ? pop.contentItem.xV : 0
    new_Focus_Method_Y: pop.contentItem ? pop.contentItem.yV : 0
    implicitWidth: root.new_Focus_Method ? (pop.contentItem ? pop.contentItem.widthV : 0) : width
    implicitHeight: root.new_Focus_Method ? (pop.contentItem ? pop.contentItem.heightV : 0) : height
    onCleared: {
      root.cleared()
    }
    content: Item {
      property int xV: box.x
      property int yV: box.y
      property int widthV: box.width
      property int heightV: box.height
      Box {
        id: box
        radius: 15
        x: root.invertH ? (root.x + (-root.horizontalOffset)) - box.width : root.x + root.horizontalOffset
        y: root.invertY ? (root.y + (-root.verticalOffset)) - (list.contentHeight+(root.padding*2)) : root.y + root.verticalOffset
        width: Math.max(root.contentWidth + root.padding * 2, 200)
        height: list.contentHeight+(root.padding*2)
        color: Qt.alpha(root.color, 0.7)
        ListView {
          id: list
          anchors.fill: parent
          anchors.margins: root.padding
          delegate: root.delegate
          model: root.model
          spacing: root.spacing
          property int rootX: root.x
          property int rootY: root.y
          Component.onCompleted:   { recalculate() }
          onRootXChanged:          { recalculate() }
          onRootYChanged:          { recalculate() }
          onContentWidthChanged:  { recalculate() }
          onContentHeightChanged: { recalculate() }
          function recalculate() {
            if (root.anchorPoint == DropDownMenu.AnchorPoint.Auto) {
              if (root.x + box.width > pop.screen.width) { root.invertH = true } else { root.invertH = false }
              if (root.y + list.contentHeight+(root.padding*2) > pop.screen.height) { root.invertY = true } else { root.invertY = false }
            }
          }
        }
      }
    }
  }
}