import Quickshell
import QtQuick
import QtQuick.VectorImage
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import qs.config
import qs
import qs.core.foundation
import qs.ui.controls.auxiliary
import qs.ui.controls.apps
import qs.ui.controls.providers
import QtQuick.Controls.Fusion

Scope {
  id: root

  property bool blurEnabled: false
  function toggle() {
    for (let i = 0; i < rootVar.instances.length; i++) {
      let delegate = rootVar.instances[i];
      if (delegate && delegate.toggle) {
        delegate.toggle();
      }
    }
  }

  property bool      zoomLayerOne: true
  property bool      zoomLayerTwo: true
  property Component contentLayerOne
  property Component contentLayerTwo
  property bool animate: true
  property real scaleVal: animate ? 1.1 : 1
  property int  duration: 500


  Behavior on scaleVal {
    NumberAnimation { duration: root.duration; easing.type: Easing.InOutQuad}
  }
  Variants {
    id: rootVar
    model: Quickshell.screens

    PanelWindow {
      id: panelWindow
      WlrLayershell.layer: WlrLayer.Overlay
      required property var modelData
      screen: modelData
      WlrLayershell.namespace: "eqsh"
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      anchors {
        top: true
        left: true
        right: true
        bottom: true
      }

      focusable: true

      mask: Region {}

      exclusiveZone: -1
      color: "#00000000"
      Behavior on color { ColorAnimation { duration: 500; easing.type: Easing.InOutQuad} }
      function toggle() {
        if (fullWindow.shown) {
          fullWindow.shown = false;
          hideAnim.start();
        } else {
          fullWindow.shown = true;
          showAnim.start();
        }
      }
      Loader {
        id: fullWindow
        active: true
        focus: true
        property real blurVal
        property bool shown: false
        anchors.fill: parent
        Keys.onEscapePressed: {
          fullWindow.shown = false;
          hideAnim.start();
        }
        PropertyAnimation {
          id: showAnim
          target: fullWindow.item
          property: "opacity"
          to: 1
          duration: 500
          easing.type: Easing.InOutQuad
          onStarted: {
            fullWindow.focus = true;
            const width = root.width
            const height = root.height
            panelWindow.mask = FullMask
            panelWindow.color = "#ff000000";
            root.scaleVal = 1
            fullWindow.blurVal = 1
          }
        }
        PropertyAnimation {
          id: hideAnim
          target: fullWindow.item
          property: "opacity"
          to: 0
          duration: 500
          easing.type: Easing.InOutQuad
          onStarted: {
            panelWindow.color = "#00000000";
            root.scaleVal = root.animate ? 1.1 : 1
            fullWindow.blurVal = 0
          }
          onFinished: {
            fullWindow.focus = false;
            panelWindow.mask = Qt.createQmlObject("import Quickshell; Region {}", hideAnim);
          }
        }
        sourceComponent: Item {
          id: fullWindowContainer
          opacity: 0
          Behavior on opacity {
            NumberAnimation { duration: 500; easing.type: Easing.InOutQuad}
          }
          BackgroundImage {
            anchors.fill: parent
            duration: 500
          }
          Loader {
            anchors.fill: parent
            scale: zoomLayerOne ? root.scaleVal : 1
            active: true; sourceComponent: root.contentLayerOne
          }
          Loader {
            anchors.fill: parent
            scale: zoomLayerTwo ? root.scaleVal : 1
            active: true; sourceComponent: root.contentLayerTwo
          }
        }
      }
    }
  }
}