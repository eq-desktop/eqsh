import Quickshell
import Quickshell.Widgets
import QtQuick.VectorImage
import QtQuick
import QtQuick.Layouts
import qs.ui.controls.auxiliary
import Quickshell.Services.SystemTray

GlintButton {
  id: root

  height: parent.height
  implicitWidth: rowLayout.implicitWidth
  property int tempWidth

  property bool opened: true

  RowLayout {
    id: rowLayout

    anchors.fill: parent
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
        Layout.rightMargin: !opened ? -tempWidth * 3 : 0
        Behavior on Layout.rightMargin {
          PropertyAnimation {
            duration: 1000
            easing.type: Easing.InOutBack
            easing.overshoot: 0.5
          }
        }
      }
    }

    VectorImage {
      id: stToggle
      Layout.rightMargin: 5
      source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/chevron-right.svg")
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