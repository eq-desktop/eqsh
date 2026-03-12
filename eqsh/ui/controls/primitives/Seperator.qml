import QtQuick
import Quickshell
import Quickshell.Widgets

Rectangle {
  id: sep
  property bool horizontal: false
  width: horizontal  ? parent.width : 1
  height: horizontal ? 1            : parent.height
  color: "#555"
}