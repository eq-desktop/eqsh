import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config

ShellRoot {
	id: root
	property bool visible: Config.general.activationKey == ""
	Variants {
		model: Quickshell.screens

		PanelWindow {
			id: w

			property string position: "br"
			visible: root.visible

			property var modelData
			screen: modelData

			anchors {
				right: true
				bottom: true
			}

			margins {
				right: 50
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
					text: "Activate eqOS"
					color: "#50ffffff"
					font.pointSize: 22
				}

				Text {
					text: "Go to Settings to activate eqOS"
					color: "#50ffffff"
					font.pointSize: 14
				}
			}
		}
	}
}
