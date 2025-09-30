import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Io
import QtQuick.Controls

import qs.config
import qs
import qs.core.system
import qs.ui.controls.auxiliary
import qs.ui.controls.advanced

Scope {
	id: scope
	signal finished();

	property bool showAll: false
	Variants {
		model: Quickshell.screens;

		PanelWindow {
			id: root
			WlrLayershell.namespace: "eqsh:blur"
			WlrLayershell.layer: WlrLayer.Overlay

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

			Item {
				id: emptyItem
				implicitWidth: 0
				implicitHeight: 0
			}
			property int notificationCount: scope.showAll ? NotificationDaemon.list.length : NotificationDaemon.popupList.length

			mask: Region {
				item: scope.showAll ? maskId.contentItem : (notificationCount > 0 ? maskId.contentItem : emptyItem)
				Region {
					item: scope.showAll ? maskId.headerItem.children[0] : emptyItem
				}
			}

			EdgeShadow {
				id: layerShadow
				blurPower: 64
				color: "#aa000000"
				strength: 100
				edge: EdgeShadow.Right
				visible: scope.showAll
			}

			visible: true

			ListView {
				id: maskId
				model: ScriptModel {
					values: scope.showAll ? [...NotificationDaemon.list].reverse() : [...NotificationDaemon.popupList].reverse()
				}

				implicitHeight: parent.height - 40
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

				headerPositioning: ListView.OverlayHeader

				header: Item {
					implicitWidth: 200
					implicitHeight: 30
					anchors {
						horizontalCenter: parent.horizontalCenter
					}
					Button {
						implicitWidth: 200
						implicitHeight: 30
						anchors {
							top: parent.top
							topMargin: -10
							horizontalCenter: parent.horizontalCenter
						}
						background: Item {}
						z: 2
						onClicked: {
							NotificationDaemon.discardAllNotifications();
						}
						Box {
							id: removeAllButton
							width: 200
							height: 30
							color: Config.general.darkMode ? "#aa222222" : "#eee"
							visible: scope.showAll && maskId.y // scrolling is above 0
							Text {
								text: Translation.tr("Remove all notifications")
								color: Config.general.darkMode ? "#eee" : "#222"
								anchors.fill: parent
								verticalAlignment: Text.AlignVCenter
								horizontalAlignment: Text.AlignHCenter
							}
						}
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