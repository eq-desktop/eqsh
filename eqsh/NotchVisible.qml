import Quickshell
import QtQuick
import qs.config
import qs.components.misc

Item {
	implicitWidth: parent.width
	implicitHeight: parent.height
	anchors {
		fill: parent
	}
	Rectangle {
		anchors {
			top: parent.top
			horizontalCenter: parent.horizontalCenter
		}
		implicitWidth: 160
		implicitHeight: Config.notch.height
		topLeftRadius: Config.notch.islandMode ? 15 : 0
		topRightRadius: Config.notch.islandMode ? 15 : 0
		bottomLeftRadius: 15
		bottomRightRadius: 15
		color: Config.notch.backgroundColor
		Text {
			anchors.fill: parent
			text: Config.notch.signature
			color: "#fff"
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter
		}
	}
	Corner {
		visible: Config.notch.fluidEdge && !Config.notch.islandMode
		orientation: 1
		width: 20
		height: 20 * Config.notch.fluidEdgeStrength
		anchors {
			top: parent.top
			left: parent.left
		}
		color: Config.notch.backgroundColor
	}
	Corner {
		visible: Config.notch.fluidEdge && !Config.notch.islandMode
		orientation: 1
		invertH: true
		width: 20
		height: 20 * Config.notch.fluidEdgeStrength
		anchors {
			top: parent.top
			right: parent.right
		}
		color: Config.notch.backgroundColor
	}
}