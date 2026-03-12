import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.ui.controls.advanced

Scope {
	id: root
	property bool failed
	property string errorString

	// Connect to the Quickshell global to listen for the reload signals.
	Connections {
		target: Quickshell

		function onReloadCompleted() {
			Quickshell.inhibitReloadPopup();
			root.failed = false;
			popupLoader.loading = true;
		}

		function onReloadFailed(error: string) {
			Quickshell.inhibitReloadPopup();
			// Close any existing popup before making a new one.
			popupLoader.active = false;

			root.failed = true;
			root.errorString = error;
			popupLoader.loading = true;
		}
	}

	// Keep the popup in a loader because it isn't needed most of the timeand will take up
	// memory that could be used for something else.
	LazyLoader {
		id: popupLoader

		active: true // SET TO TRUE TO ENABLE

		PanelWindow {
			id: popup

			anchors {
				top: true
				left: true
				right: true
				bottom: true
			}

			// color blending is a bit odd as detailed in the type reference.
			color: "transparent"

			mask: Region {
				item: rect
			}

			BoxGlass {
				id: rect
				color: failed ?  "#802020" : "#202020"
                radius: 25
                clip: true

				anchors {
					top: parent.top
					left: parent.left
					margins: 25
				}

				implicitHeight: 0
				implicitWidth: 0

				Behavior on implicitWidth { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
				Behavior on implicitHeight { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }

				Component.onCompleted: {
					implicitHeight = layout.implicitHeight + 50
					implicitWidth = layout.implicitWidth + 100
				}

				// Fills the whole area of the rectangle, making any clicks go to it,
				// which dismiss the popup.
				MouseArea {
					id: mouseArea
					anchors.fill: parent
					onClicked: popupLoader.active = false

					// makes the mouse area track mouse hovering, so the hide animation
					// can be paused when hovering.
					hoverEnabled: true
				}

				ColumnLayout {
					id: layout
					anchors {
						top: parent.top
						topMargin: 20
						left: parent.left
						leftMargin: 20
						right: parent.right
						rightMargin: 20
					}

					Text {
						id: title
						text: root.failed ? "Reload failed." : "Reload completed!"
						color: "white"
						font.pixelSize: 12
						verticalAlignment: Text.AlignVCenter
					}

					Text {
						text: root.errorString
						color: "white"
						// When visible is false, it also takes up no space.
						visible: root.errorString != ""
					}
				}

				// A progress bar on the bottom of the screen, showing how long until the
				// popup is removed.

                Timer {
                    id: timer
                    interval: failed ? 10000 : 800
                    running: true
                    repeat: false
                    onTriggered: popupLoader.active = false

                    // Pause the timer when hovering
                    onRunningChanged: {
                        if (!running && mouseArea.containsMouse) {
                            running = true;
                        }
                    }
                }
			}
		}
	}
}
