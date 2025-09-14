import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Wayland

import qs.Config
import qs.Core.System
import qs.ui.Controls.Auxiliary

Scope {
	signal finished();

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

			property int notificationCount: NotificationDaemon.popupList.length

			visible: true

			mask: Region {
				item: maskId.contentItem
			}

			ListView {
				id: maskId
				model: ScriptModel {
					values: [...NotificationDaemon.popupList].reverse()
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
}