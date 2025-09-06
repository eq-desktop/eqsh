import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick.Layouts
import Quickshell.Widgets
import QtQuick.Controls
import QtQuick.VectorImage
import qs.components.misc

import qs.config
import qs.services
import "root:/scripts/notification_utils.js" as NotificationUtils


AniRectangle {
	id: singleNotif
	property bool expanded
	property bool popup: false

	property real notifSize: {
		if (modelData.body == bodyPreviewMetrics.elidedText && expanded) return 100
		if (modelData.body != bodyPreviewMetrics.elidedText && expanded) return 120
		else return 80
	}

	radius: 27
	color: Config.notifications.backgroundColor
	implicitHeight:	notifSize
	implicitWidth: 400

	highlight: modelData.urgency == "critical" ? "#ff555555" : "#22555555"

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

		onClicked: singleNotif.popup ? Notifications.timeoutNotification(modelData.id) : Notifications.discardNotification(modelData.id)
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

					text: NotificationUtils.getFriendlyNotifTimeString(modelData.time)

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
				color: "#aa555555"
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
					source: singleNotif.expanded ? "../../assets/svgs/chevron-left.svg" : "../../assets/svgs/chevron-right.svg"
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
					onEntered: parent.color = "#aa888888"
					onExited: parent.color = "#aa555555"
				}
			}
		}
	}
}