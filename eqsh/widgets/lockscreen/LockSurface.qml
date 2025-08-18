import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell
import qs.components.misc
import qs.config
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
		visible: !Config.lockScreen.xRay && Config.lockScreen.blur
		autoPaddingEnabled: false
		blur: 1
		blurMax: 64 * Config.lockScreen.blurStrength
		blurMultiplier: 1
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
	}

	ScreencopyView {
		id: screencopy
		anchors.fill: parent
		visible: Config.lockScreen.xRay
		paintCursor: false
		captureSource: Quickshell.screens[0]
	}

	MultiEffect {
		id: screencopyBlur
		anchors.fill: screencopy
		source: screencopy
		visible: Config.lockScreen.xRayBlur && Config.lockScreen.xRay
		autoPaddingEnabled: false
		blurEnabled: true
		blur: 1
		blurMax: 64 * Config.lockScreen.blurStrength
		blurMultiplier: 1
	}

	ShaderEffect {
		id: shader
		visible: Config.lockScreen.enableShader
		anchors.fill: parent
		property vector2d sourceResolution: Qt.vector2d(width, height)
		property vector2d resolution: Qt.vector2d(width, height)
		property real time: 0
		property variant source: Config.lockScreen.xRay ? screencopy : backgroundImage
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
		visible: !Config.lockScreen.xRay
		fillMode: Image.PreserveAspectCrop
		opacity: 0
		anchors.fill: parent
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
		color: "#aaffffff"
		font.pointSize: 80

		Timer {
			running: true
			repeat: true
			interval: 1000

			onTriggered: clock.date = new Date();
		}

		text: {
			const hours = this.date.getHours().toString().padStart(2, '0');
			const minutes = this.date.getMinutes().toString().padStart(2, '0');
			return `${hours}:${minutes}`;
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
		color: "#aaffffff"
		font.pointSize: 16

		Timer {
			running: true
			repeat: true
			interval: 60000

			onTriggered: clock.date = new Date();
		}

		text: {
			return Qt.formatDateTime(clock.date, "ddd MMM dd");
		}
	}

	ColumnLayout {

		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			bottomMargin: 25
		}

		RowLayout {
			Box {
				id: passwordBoxContainer
				width: 400
				height: 35
				borderColor: "#55ffffff"
				color: "transparent"
				TextField {
					id: passwordBox

					background: Rectangle {
						color: "transparent";
					}
					color: "#fff";

					implicitWidth: 400
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
					}
				}
			}

			Box {
				width: 35
				height: 35
				color: "transparent"
				Button {
					text: "\u2192"
					padding: 10
					background: Rectangle {
						color: "transparent";
					}
					palette.button: "white";
					palette.buttonText: "white";

					font.pointSize: 14

					implicitWidth: 35;
					implicitHeight: 35;

					focusPolicy: Qt.NoFocus

					enabled: !root.context.unlockInProgress && root.context.currentText !== "";
					onClicked: root.context.tryUnlock();
				}
			}
		}

		Label {
			visible: root.context.showFailure
			text: "Incorrect password"
		}
	}
	Item {
		anchors {
			top: parent.top
			horizontalCenter: parent.horizontalCenter
			topMargin: Config.notch.islandMode ? 5 : 0
		}

		implicitWidth: 200
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
