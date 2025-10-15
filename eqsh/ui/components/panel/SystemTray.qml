import Quickshell
import Quickshell.Widgets
import QtQuick.VectorImage
import QtQuick
import QtQuick.Layouts
import qs.ui.controls.auxiliary
import qs.config
import Quickshell.Services.SystemTray

BButton {
  id: root

  height: 25
  implicitWidth: rowLayout.implicitWidth
  property int tempWidth

  property bool opened: true

  RowLayout {
    id: rowLayout

    anchors.fill: parent
    Layout.minimumWidth: 50
    spacing: 5
    clip: true

    Item {
      Layout.preferredWidth: 5
    }

    Repeater {
      model: SystemTray.items
      SysTrayItem {
        Layout.alignment: Qt.AlignCenter
        required property SystemTrayItem modelData
        item: modelData
        Layout.rightMargin: !opened ? -tempWidth*2 : 0
      }
    }

    VectorImage {
      id: stToggle
      Layout.rightMargin: 5
      source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/chevron-left.svg")
      width: 23
      height: 23
      Layout.preferredWidth: 23
      Layout.preferredHeight: 23
      preferredRendererType: VectorImage.CurveRenderer
      MouseArea {
        anchors.fill: parent
        onClicked: {
          opened = !opened
          if (opened) {
            stToggle.source = Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/chevron-left.svg")
          } else {
            tempWidth = rowLayout.implicitWidth
            stToggle.source = Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/chevron-right.svg")
          }
        }
      }
    }
  }
}