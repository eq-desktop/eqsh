import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell
import qs.components.misc
import qs.config
import qs.widgets.panel
import qs

Rectangle {
	id: root
	required property LockContext context
	readonly property ColorGroup colors: Window.active ? palette.active : palette.inactive
	property string wallpaperImage: Config.lockScreen.useCustomWallpaper ? Config.lockScreen.customWallpaperPath : Config.wallpaper.path

	PropertyAnimation {
		id: fadeOutAnim
		target: locksur
		property: "opacity"
		to: 0
		duration: Config.lockScreen.fadeDuration
		onStopped: {
			if (root.context) root.context.unlocked();
		}
	}

	function unlock() {
		if (fadeOutAnim.running)
			return;
		fadeOutAnim.start();
		scaleAnim.start();
		scaleAnim2.start();
		scaleAnim3.start();
	}


	PropertyAnimation {
		id: scaleAnim
		target: contentItem
		property: "scale"
		to: Config.lockScreen.zoom
		duration: Config.lockScreen.zoomDuration
		easing.type: Easing.InOutQuad
	}
	PropertyAnimation {
		id: scaleAnim2
		target: contentItem
		property: "opacity"
		to: 0
		duration: Config.lockScreen.zoomDuration
		easing.type: Easing.InOutQuad
	}
	PropertyAnimation {
		id: scaleAnim3
		target: backgroundImageBlur
		property: "scale"
		to: 1
		duration: Config.lockScreen.fadeDuration / 1.5
		easing.type: Easing.InOutQuad
	}

	opacity: 0;
	color: "transparent"

	Behavior on opacity {
		NumberAnimation { duration: Config.lockScreen.fadeDuration; easing.type: Easing.InOutQuad }
	}

	Component.onCompleted: {
		root.opacity = 1;
	}

	MultiEffect {
		id: backgroundImageBlur
		anchors.fill: backgroundImage
		source: backgroundImage
		blurEnabled: true
		autoPaddingEnabled: false
		blur: Config.lockScreen.blur
		blurMax: 64 * Config.lockScreen.blurStrength
		blurMultiplier: 1
		scale: 1
		SequentialAnimation on blur {
			loops: Animation.Infinite
			running: Config.lockScreen.liquidBlur
			PropertyAnimation { to: 1; duration: (Config.lockScreen.liquidDuration / 2) }
			PropertyAnimation { to: 0.4; duration: (Config.lockScreen.liquidDuration / 2) }
		}
		SequentialAnimation on blurMax {
			loops: Animation.Infinite
			running: Config.lockScreen.liquidBlurMax
			PropertyAnimation { to: 128 * Config.lockScreen.blurStrength; duration: (Config.lockScreen.liquidDuration / 2) }
			PropertyAnimation { to: 64 * Config.lockScreen.blurStrength; duration: (Config.lockScreen.liquidDuration / 2) }
		}
		Component.onCompleted: {
			backgroundImageBlur.scale = 1.1;
		}
		Behavior on scale {
			NumberAnimation { duration: 1000; easing.type: Easing.InOutQuad }
		}
	}

	ShaderEffect {
		id: shader
		visible: Config.lockScreen.enableShader
		anchors.fill: parent
		property vector2d sourceResolution: Qt.vector2d(width, height)
		property vector2d resolution: Qt.vector2d(width, height)
		property real time: 0
		property variant source: backgroundImage
		FrameAnimation {
			running: true
			onTriggered: {
				shader.time = this.elapsedTime;
			}
		}
		vertexShader: "../../" + Config.lockScreen.shaderVert
		fragmentShader: "../../" + Config.lockScreen.shaderFrag
	}

	Image {
		id: backgroundImage
		source: wallpaperImage
		fillMode: Image.PreserveAspectCrop
		opacity: 0
		anchors.fill: parent
	}

	Item {
		id: contentItem
		anchors.fill: parent
		scale: Config.lockScreen.zoom
		transform: Translate {
			id: trans
			y: -50
			Behavior on y {
				NumberAnimation { duration: Config.lockScreen.zoomDuration*2; easing.type: Easing.InOutQuad }
			}
		}
		opacity: 0
		Component.onCompleted: {
			contentItem.scale = 1;
			contentItem.opacity = 1;
			trans.y = 0;
		}
		Behavior on scale {
			NumberAnimation { duration: Config.lockScreen.zoomDuration; easing.type: Easing.InOutQuad }
		}
		Behavior on opacity {
			NumberAnimation { duration: Config.lockScreen.zoomDuration; easing.type: Easing.InOutQuad }
		}
		Label {
			id: clock
			property var date: new Date()

			anchors {
				horizontalCenter: parent.horizontalCenter
				top: parent.top
				topMargin: 100
			}

			renderType: Text.NativeRendering
			color: "#ccffffff"
			font.pointSize: 80
			font.weight: Font.Bold

			Timer {
				running: true
				repeat: true
				interval: 1000

				onTriggered: clock.date = new Date();
			}

			text: {
				return Qt.formatDateTime(clock.date, Config.lockScreen.timeFormat);
			}
		}

		Label {
			id: dateClock
			property var date: new Date()

			anchors {
				horizontalCenter: parent.horizontalCenter
				top: parent.top
				topMargin: 75
			}

			renderType: Text.NativeRendering
			color: "#bbffffff"
			font.pointSize: 18
			font.weight: Font.Bold

			Timer {
				running: true
				repeat: true
				interval: 60000

				onTriggered: clock.date = new Date();
			}

			text: {
				return Qt.formatDateTime(clock.date, Config.lockScreen.dateFormat);
			}
		}

		Rectangle {
			id: batteryIndicator
			anchors {
				top: parent.top
				right: parent.right
				topMargin: 10
				rightMargin: 60
			}
			Battery {}
		}

		Rectangle {
			id: wifiIndicator
			anchors {
				top: parent.top
				right: parent.right
				topMargin: 10
				rightMargin: 30
			}
			Wifi {}
		}

		ColumnLayout {
			id: inputArea
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: 50
			}

			width: parent.width

			Text {
				Layout.alignment: Qt.AlignHCenter
				text: Config.lockScreen.userNote
				color: "#bbffffff"
				font.pointSize: 12
				font.weight: Font.Normal
				Layout.bottomMargin: 10
			}

			ClippingRectangle {
				id: avatarContainer
				width: Config.lockScreen.avatarSize
				height: Config.lockScreen.avatarSize
				radius: 50
				clip: true

				Layout.alignment: Qt.AlignHCenter

				Image {
					anchors.fill: parent
					source: Config.lockScreen.avatarPath
					fillMode: Image.PreserveAspectCrop
					opacity: 0.95
				}
			}

			property bool freeSpace: Config.lockScreen.autohideInput && Config.lockScreen.hideOpacity == 0 ? (passwordBox.text == "" ? true : false) : false
			RowLayout {
				Layout.alignment: Qt.AlignHCenter
				Box {
					id: passwordBoxContainer
					width: 200
					height: 35
					highlight: "#ffffff"
					color: "#22ffffff"
					opacity: Config.lockScreen.autohideInput ? (passwordBox.text == "" ? Config.lockScreen.hideOpacity : 1) : 1
					Behavior on opacity {
						NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
					}
					SequentialAnimation {
						id: wiggleAnim
						running: false
						loops: 1
						PropertyAnimation { target: passwordBoxContainer; property: "x"; to: passwordBoxContainer.x - 10; duration: 100; easing.type: Easing.InOutQuad }
						PropertyAnimation { target: passwordBoxContainer; property: "x"; to: passwordBoxContainer.x + 10; duration: 100; easing.type: Easing.InOutQuad }
						PropertyAnimation { target: passwordBoxContainer; property: "x"; to: passwordBoxContainer.x - 7; duration: 100; easing.type: Easing.InOutQuad }
						PropertyAnimation { target: passwordBoxContainer; property: "x"; to: passwordBoxContainer.x + 7; duration: 100; easing.type: Easing.InOutQuad }
						PropertyAnimation { target: passwordBoxContainer; property: "x"; to: passwordBoxContainer.x; duration: 100; easing.type: Easing.InOutQuad }
					}
					TextField {
						id: passwordBox
						anchors.horizontalCenter: parent.horizontalCenter

						background: Rectangle {
							color: "transparent";
							anchors.fill: parent
							Text {
								anchors.fill: parent
								verticalAlignment: Text.AlignVCenter
								text: passwordBox.text == "" ? root.context.showFailure ? "Incorrect Password" : "Enter Password" : ""
								color: root.context.showFailure ? "#ffffff" : "#bbffffff"
								anchors.leftMargin: 10
								font.weight: 500
							}
						}
						color: "#fff";

						implicitWidth: 200
						implicitHeight: 35
						padding: 10

						focus: true
						enabled: !root.context.unlockInProgress
						echoMode: TextInput.Password
						inputMethodHints: Qt.ImhSensitiveData

						onTextChanged: root.context.currentText = this.text;

						onAccepted: root.context.tryUnlock();

						Connections {
							target: root.context

							function onCurrentTextChanged() {
								passwordBox.text = root.context.currentText;
							}

							function onShowFailureChanged() {
								if (root.context.showFailure) {
									wiggleAnim.start();
								}
							}
						}
					}
				}
			}

			Label {
				Layout.alignment: Qt.AlignHCenter
				text: Config.lockScreen.usageInfo
				color: "#bbffffff"
				font.pointSize: 10
				font.weight: Font.Normal
				Layout.topMargin: inputArea.freeSpace ? -50 : 10
				Behavior on Layout.topMargin {
					NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 }
				}
			}
		}
	}
	
	Item {
		anchors {
			top: parent.top
			horizontalCenter: parent.horizontalCenter
			topMargin: Config.notch.islandMode ? Config.notch.margin : 0
		}

		implicitWidth: Config.notch.minWidth
		implicitHeight: Config.notch.height

		visible: Config.notch.enable

		NotchVisible {}
	}
	Item {
		anchors.fill: parent

		visible: Config.screenEdges.enable
		ScreenCornersVisible {}
	}
}
