import Quickshell
import QtQuick
import qs.config
import qs.ui.controls.auxiliary

Item {
	implicitWidth: parent.width
	implicitHeight: parent.height
	anchors {
		fill: parent
	}
	CutoutCorner {
        corners: 4
		cornerHeight: Config.screenEdges.radius
		cornerType: "inverted"
        anchors {
          right: parent.right
        }
		color: Config.screenEdges.color
	}
}