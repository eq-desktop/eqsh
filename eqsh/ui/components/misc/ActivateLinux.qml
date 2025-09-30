import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs

ShellRoot {
	id: root
	property bool visible: Config.account.activationKey == ""
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
					text: Translation.tr("Activate Equora")
					color: "#50ffffff"
					font.pointSize: 22
				}

				Text {
					text: Translation.tr("Go to Settings to activate your Account.")
					color: "#50ffffff"
					font.pointSize: 14
				}
			}
		}
	}
}
