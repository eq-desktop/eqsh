import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config

ShellRoot {
	id: root
	property bool visible: Config.misc.showVersion
	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: w

			property string position: "br"
			visible: root.visible

			property var modelData
			screen: modelData

			anchors {
				left: true
				bottom: true
			}

			margins {
				left: 50
				bottom: 50
			}

			implicitWidth: content.width
			implicitHeight: content.height

			color: "transparent"

			mask: Region {}

			WlrLayershell.layer: WlrLayer.Overlay

			ColumnLayout {
				id: content

				Text {
					text: Config.version
					color: "#50ffffff"
					font.pointSize: 22
				}
			}
		}
	}
}
