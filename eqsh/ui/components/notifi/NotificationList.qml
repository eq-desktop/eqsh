import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Io

import qs.Config
import qs.Core.System
import qs.ui.Controls.Auxiliary
import qs.ui.Controls.Advanced

Scope {
	id: scope
	signal finished();

	property bool showAll: false
	Variants {
		model: Quickshell.screens;

		PanelWindow {
			id: root
			WlrLayershell.namespace: "eqsh:blur"

			property var modelData
			screen: modelData

			anchors {
				top: true
				right: true
				bottom: true
			}

			margins {
				top: Config.bar.height
			}

			aboveWindows: true
			exclusionMode: ExclusionMode.Ignore
			implicitWidth: 450

			color: "transparent"

			property int notificationCount: scope.showAll ? NotificationDaemon.list.length : NotificationDaemon.popupList.length

			LayerShadow {
				id: layerShadow
				anchors: [
					true,
					false,
					true,
					true
				]
				margins: [0, 0, -100, 0]
				rounding: 100
				width: 650
				height: maskId.implicitHeight
				blurPower: 64
				color: "#50000000"
				layer: WlrLayer.Top
				visible: scope.showAll
			}

			visible: true

			mask: Region {
				item: maskId.contentItem
			}

			ListView {
				id: maskId
				model: ScriptModel {
					values: scope.showAll ? [...NotificationDaemon.list].reverse() : [...NotificationDaemon.popupList].reverse()
				}

				implicitHeight: parent.height
				implicitWidth: 400

				anchors.top: parent.top
				anchors.topMargin: 20

				anchors.right: parent.right
				anchors.rightMargin: 20

				Behavior on implicitWidth {
					NumberAnimation {
						duration: 200
						easing.type: Easing.OutBack
						easing.overshoot: 1
					}
				}

				spacing: 20

				add: Transition {
					NumberAnimation {
						duration: 700
						easing.type: Easing.OutBack
						easing.overshoot: 0.2
						from: 500
						property: "x"
					}
				}

				addDisplaced: Transition {
					NumberAnimation {
						duration: 500
						easing.type: Easing.OutBack
						easing.overshoot: 1
						properties: "x,y"
					}
				}

				delegate: SingleNotification {
					popup: true
					required property NotificationDaemon.Notif modelData
				}

				remove: Transition {
					NumberAnimation {
						duration: 700
						easing.type: Easing.OutBack
						easing.overshoot: 1
						property: "x"
						to: 500
					}
				}

				removeDisplaced: Transition {
					NumberAnimation {
						duration: 500
						easing.type: Easing.OutBack
						easing.overshoot: 1
						properties: "x,y"
					}
				}
			}
		}
	}
	IpcHandler {
		target: "notificationCenter"
		function toggle() {
			scope.showAll = !scope.showAll;
		}
	}
	CustomShortcut {
		name: "notification-center"
		description: "Toggle Notification Center"
		onPressed: {
			scope.showAll = !scope.showAll;
		}
	}
	CustomShortcut {
		name: "notification-center-open"
		description: "Open Notification Center"
		onPressed: {
			scope.showAll = true;
		}
	}
	CustomShortcut {
		name: "notification-center-close"
		description: "Close Notification Center"
		onPressed: {
			scope.showAll = false;
		}
	}
}