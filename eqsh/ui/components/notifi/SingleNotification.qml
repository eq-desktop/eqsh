import QtQuick
import Quickshell
import QtQuick.Effects
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick.Layouts
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.VectorImage
import qs.ui.controls.auxiliary
import qs.ui.controls.advanced
import qs.ui.controls.providers
import qs

import qs.config
import qs.core.system
import "root:/agents/notification_utils.js" as NotificationUtils


BoxExperimental {
	id: singleNotif
	property bool expanded
	property bool popup: false

	property real notifSize: {
		if (modelData.body == bodyPreviewMetrics.elidedText && expanded) return 100
		if (modelData.body != bodyPreviewMetrics.elidedText && expanded) return 120
		else return 80
	}

	radius: 27
	implicitHeight:	notifSize
	implicitWidth: 400

	highlight: modelData.urgency == "critical" ? "#ff0000" : AccentColor.color

	anchors.topMargin: 20

	Behavior on implicitHeight {
		PropertyAnimation {
			duration: 400
			easing.type: Easing.OutBack
			easing.overshoot: 3
		}
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		hoverEnabled: true

		onEntered: {
			closeButton.scale = 1
		}

		onExited: {
			closeButton.scale = 0
		}
		onClicked: singleNotif.popup ? NotificationDaemon.timeoutNotification(modelData.id) : NotificationDaemon.discardNotification(modelData.id)

		ClippingRectangle {
			id: closeButton
			anchors.top: parent.top
			anchors.left: parent.left
			width: 24
			height: 24
			radius: 12
			scale: 0
			opacity: scale
			Behavior on scale {
				NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1 }
			}
			Behavior on width {
				NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1 }
			}
			border {
				color: "#50ffffff"
				width: 1
			}
			color: Config.general.darkMode ? "#aa111111" : "#aaffffff"
			Item {
				anchors.fill: parent
				id: closeButtonIcon
				VectorImage {
					id: closeIcon
					source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/x.svg")
					anchors.left: parent.left
					anchors.leftMargin: 5
					anchors.verticalCenter: parent.verticalCenter
					width: 12
					height: 12
					layer.enabled: true
					layer.effect: MultiEffect {
						colorization: 1
						colorizationColor: Config.general.darkMode ? "#fff" : "#222"
					}
				}
				Label {
					id: closeButtonText
					anchors.left: closeIcon.right
					anchors.leftMargin: 5
					anchors.verticalCenter: parent.verticalCenter
					text: Translation.tr("Remove")
					color: Config.general.darkMode ? "#fff" : "#222"
					font.pixelSize: 12
					opacity: 0
					Behavior on opacity {
						NumberAnimation { duration: 100; }
					}
				}
			}
			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				hoverEnabled: true
				onEntered: {
					closeButton.width = closeIcon.implicitWidth + closeButtonText.implicitWidth + 10
					closeButtonText.opacity = 1
				}
				onExited: {
					closeButton.width = 24
					closeButtonText.opacity = 0
				}
				onClicked: NotificationDaemon.discardNotification(modelData.id)
			}
		}
	}

	RowLayout {
		anchors.centerIn: parent

		anchors.topMargin: 13
		anchors.bottomMargin: 13
		anchors.leftMargin: 5
		anchors.rightMargin: 10

		implicitWidth: 400
		spacing: 2

		ClippingWrapperRectangle { // image
			visible: (modelData.appIcon == "") ? false : true
			radius: 50

			Layout.alignment: root.expanded ? Qt.AlignLeft | Qt.AlignTop : Qt.AlignLeft
			Layout.leftMargin: 0
			Layout.preferredWidth: 50
			Layout.preferredHeight: 50

			Behavior on Layout.alignment {
				PropertyAnimation {
					duration: 200
					easing.type: Easing.InSine
				}
			}

			color: "transparent"

			IconImage {
				visible: (modelData.appIcon == "") ? false : true
				source: Qt.resolvedUrl(modelData.appIcon)
			}
		}

		Text { // backup image
			Layout.alignment: root.expanded ? Qt.AlignLeft | Qt.AlignTop : Qt.AlignLeft
			Layout.leftMargin: 5
			Layout.rightMargin: 10

			Behavior on Layout.alignment {
				PropertyAnimation {
					duration: 200
					easing.type: Easing.InSine
				}
			}

			visible: (modelData.appIcon == "") ? true : false
			text: ""

			color: "#fff"

			font.family: "FiraCode"
			font.pixelSize: 35
		}

		ColumnLayout { //content
			id: textWrapper

			Layout.alignment: Qt.AlignLeft
			Layout.preferredWidth: 240
			Layout.leftMargin: 10

			RowLayout { //expanded bit
				Layout.alignment: Qt.AlignLeft | Qt.AlignTop
				Layout.topMargin: expanded ? 0 : 15
				spacing: 4

				visible: (Layout.topMargin == 0) ? true : false

				clip: true

				Behavior on Layout.topMargin {
					PropertyAnimation {
						duration: 200
						easing.type: Easing.InSine
					}
				}

				Text {
					text: modelData.appName
					color: "#aaa"

					font.weight: 600
					font.pixelSize: 11

					visible: parent.visible

					Behavior on visible {
						PropertyAnimation {
							duration: 400
							easing.type: Easing.OutBack
						}
					}

				}
				Text {
					text: "·"
					color: "#555"

					font.weight: 600
					font.pixelSize: 11

					visible: parent.visible

					Behavior on visible {
						PropertyAnimation {
							duration: 200
							easing.type: Easing.InSine
						}
					}
				}
				Text {
					color: "#fff"

					text: NotificationUtils.getFriendlyNotifTimeString(modelData.time, Translation)

					font.weight: 600
					font.pixelSize: 11

					visible: parent.visible

					Behavior on visible {
						PropertyAnimation {
							duration: 200
							easing.type: Easing.InSine
						}
					}
				}

			}

			// Text content

			Text {
				Layout.alignment: Qt.AlignLeft

				text: summaryPreviewMetrics.elidedText

				visible: {
					if (modelData.summary == "") return false
					else return true
				}

				Behavior on visible {
					PropertyAnimation {
						duration: 150
						easing.type: Easing.InSine
					}
				}

				color: "#fff"

				font.weight: 600
				font.pixelSize: 15
			}

			TextMetrics {
				id: summaryPreviewMetrics

				text: modelData.summary

				elide: Qt.ElideRight
				elideWidth: 210
			}

			Text {
				id: bodyPreview
				Layout.alignment: Qt.AlignLeft

				text: bodyPreviewMetrics.elidedText

				color: "#fff"

				font.pixelSize: 13

				visible: {
					if (singleNotif.notifSize == 100) return true
					if (singleNotif.notifSize == 120) return false
					if (modelData.body == "") return false
					else return true
				}

				Behavior on visible {
					PropertyAnimation {
						duration: 150
						easing.type: Easing.InSine
					}
				}
			}

			TextMetrics {
				id: bodyPreviewMetrics

				text: modelData.body

				elide: Qt.ElideRight
				elideWidth: 240
			}

			ScrollView {
				visible:  {
					if (singleNotif.notifSize == 100) return false
					if (singleNotif.notifSize == 120) return true
					else return false
				}
				Layout.alignment: Qt.AlignLeft

				implicitWidth: 240
				implicitHeight: 35

				ScrollBar.horizontal: ScrollBar {
					policy: ScrollBar.AlwaysOff
				}

				ScrollBar.vertical: ScrollBar {
					policy: ScrollBar.AlwaysOff
				}

				Text {
					width: 240
					height: 50
					text: modelData.body

					font.pixelSize: 13
					color: "#fff"

					visible: singleNotif.expanded

					wrapMode: Text.Wrap
				}

				Behavior on visible {
					PropertyAnimation {
						duration: 150
						easing.type: Easing.InSine
					}
				}
			}
		}

		// Expand button
		ColumnLayout {
			Layout.alignment: Qt.AlignTop
			Layout.preferredWidth: 45
			Layout.preferredHeight: 25
			Layout.leftMargin: 20

			Box {
				Layout.alignment: Qt.AlignTop
				id: expandBtn
				width: 45
				height: 25
				color: "#50555555"
				radius: 50
				visible: true

				Behavior on color {
					PropertyAnimation {
						duration: 150
						easing.type: Easing.InSine
					}
				}

				VectorImage {
					id: stToggle
					anchors.centerIn: parent
					source: singleNotif.expanded ? Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/chevron-left.svg") : Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/chevron-right.svg")
					width: 23
					height: 23
					Layout.preferredWidth: 23
					Layout.preferredHeight: 23
					preferredRendererType: VectorImage.CurveRenderer
				}

				MouseArea {
					anchors.fill: parent
					cursorShape: Qt.PointingHandCursor

					hoverEnabled: true

					onClicked: singleNotif.expanded = !singleNotif.expanded
					onEntered: parent.color = "#50888888"
					onExited: parent.color = "#50555555"
				}
			}
		}
	}
}