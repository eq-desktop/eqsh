import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell
import qs.ui.controls.auxiliary
import qs.ui.controls.advanced
import qs.ui.controls.providers
import qs.config
import qs.ui.components.panel
import qs

Rectangle {
	id: root
	required property LockContext context
	required property var screen
	readonly property ColorGroup colors: Window.active ? palette.active : palette.inactive
	property string wallpaperImage: Config.lockScreen.useCustomWallpaper ? Config.lockScreen.customWallpaperPath : Config.wallpaper.path

	function unlock() {
		if (fadeOutAnim.running)
			return;
		fadeOutAnim.start();
		scaleAnim.start();
		scaleAnim2.start();
		scaleAnim3.start();
	}

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
	PropertyAnimation {
		id: scaleAnim
		target: contentItem
		property: "scale"
		to: Config.general.reduceMotion ? 1 : Config.lockScreen.zoom
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
		blur: 0
		blurMax: 64 * Config.lockScreen.blurStrength
		blurMultiplier: 1
		scale: 1
		Component.onCompleted: {
			backgroundImageBlur.scale = Config.general.reduceMotion ? 1 : Config.lockScreen.zoom;
			backgroundImageBlur.blur = Config.lockScreen.blur;
		}
		Behavior on scale {
			NumberAnimation { duration: Config.lockScreen.zoomDuration; easing.type: Easing.InOutQuad }
		}
		Behavior on blur {
			NumberAnimation { duration: Config.lockScreen.zoomDuration; easing.type: Easing.InOutQuad }
		}
	}

	Loader {
		active: Config.lockScreen.enableShader
		sourceComponent: ShaderEffect {
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
			vertexShader: Qt.resolvedUrl(Config.lockScreen.shaderVert)
			fragmentShader: Qt.resolvedUrl(Config.lockScreen.shaderFrag)
		}
	}

	BackgroundImage {
		id: backgroundImage
		source: wallpaperImage
		opacity: 0
		anchors.fill: parent
	}

	Rectangle {
		id: backgroundImageDim
		anchors.fill: parent
		color: Config.lockScreen.dimColor
		opacity: Config.lockScreen.dimOpacity
	}

	Item {
		id: contentItem
		anchors.fill: parent
		scale: Config.general.reduceMotion ? 1 : Config.lockScreen.zoom
		transform: Translate {
			id: trans
			y: Config.general.reduceMotion ? 0 : -50
			Behavior on y {
				NumberAnimation { duration: Config.lockScreen.clockZoomDuration*2; easing.type: Easing.InOutQuad }
			}
		}
		opacity: Config.general.reduceMotion ? 1 : 0
		readonly property bool showInteractive: {
			Config.lockScreen.useFocusedScreen ? (Hyprland.focusedMonitor.name == screen?.name) :
			Config.lockScreen.mainScreen != "" ? Config.lockScreen.mainScreen == screen.name :
			Config.lockScreen.interactiveScreens.includes(screen.name)
		}
		onShowInteractiveChanged: {
			if (showInteractive) {
				contentItem.scale = 1;
				contentItem.opacity = 1;
			} else {
				contentItem.scale = Config.general.reduceMotion ? 1 : Config.lockScreen.zoom;
				contentItem.opacity = 0;
			}
		}
		Component.onCompleted: {
			contentItem.scale = 1;
			contentItem.opacity = 1;
			trans.y = 0;
		}
		Behavior on scale {
			NumberAnimation { duration: Config.lockScreen.clockZoomDuration; easing.type: Easing.InOutQuad }
		}
		Behavior on opacity {
			NumberAnimation { duration: Config.lockScreen.clockZoomDuration; easing.type: Easing.InOutQuad }
		}

		ShaderEffectSource {
			id: clockBlurSource
			sourceItem: backgroundImage
			sourceRect: Qt.rect(clock.x, clock.y, clock.width, clock.height)
			hideSource: false
			live: true
		}

		MultiEffect {
			id: clockBlur
			anchors.centerIn: clock
			width: clock.width
			height: clock.height
			source: clockBlurSource
			blurEnabled: true
			blur: 1
			blurMax: 64
			brightness: 0.4
			blurMultiplier: 1.2
			autoPaddingEnabled: false
			maskEnabled: true
			maskSource: clock
			smooth: true
			layer.enabled: true
		}

		Label {
			id: clock

			anchors {
				horizontalCenter: parent.horizontalCenter
				top: parent.top
				topMargin: 100
			}

			renderType: Text.NativeRendering
			color: "#77ffffff"
			font.family: Fonts.sFProDisplayBlack.family
			font.pointSize: 80
			font.weight: 900
			layer.enabled: true
			layer.smooth: true

			text: {Time.getTime(Config.lockScreen.timeFormat)}
		}

		ShaderEffectSource {
			id: dateClockBlurSource
			sourceItem: backgroundImage
			sourceRect: Qt.rect(dateClock.x, dateClock.y, dateClock.width, dateClock.height)
			hideSource: false
			live: true
		}

		MultiEffect {
			id: dateClockBlur
			anchors.centerIn: dateClock
			width: dateClock.width
			height: dateClock.height
			source: dateClockBlurSource
			blurEnabled: true
			blur: 1
			blurMax: 64
			blurMultiplier: 1.2
			autoPaddingEnabled: false
			maskEnabled: true
			maskSource: dateClock
		}

		Label {
			id: dateClock

			anchors {
				horizontalCenter: parent.horizontalCenter
				top: parent.top
				topMargin: 75
			}

			renderType: Text.NativeRendering
			color: "#aaffffff"
			font.family: Fonts.sFProRounded.family
			font.pointSize: 18
			font.weight: Font.Bold

			text: {Time.getTime(Config.lockScreen.dateFormat)}
		}

		Rectangle {
			id: batteryIndicator
			anchors {
				top: parent.top
				right: parent.right
				topMargin: 20
				rightMargin: 60
			}
			Battery {}
		}

		Rectangle {
			id: wifiIndicator
			anchors {
				top: parent.top
				right: parent.right
				topMargin: 20
				rightMargin: 30
			}
			Wifi {}
		}

		ColumnLayout {
			id: inputArea
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
				bottomMargin: 20
			}

			width: parent.width

			Text {
				Layout.alignment: Qt.AlignHCenter
				text: Config.lockScreen.userNote
				color: "#fff"
				font.pointSize: 12
				font.weight: Font.Normal
				Layout.bottomMargin: 10
				layer.enabled: true
				layer.effect: MultiEffect {
					shadowEnabled: true
					shadowColor: "#000000"
				}
			}

			ClippingRectangle {
				id: avatarContainer
				width: Config.lockScreen.avatarSize
				height: Config.lockScreen.avatarSize
				radius: 50
				clip: true
				visible: Config.lockScreen.showAvatar

				Layout.alignment: Qt.AlignHCenter

				Image {
					anchors.fill: parent
					source: Config.account.avatarPath
					fillMode: Image.PreserveAspectCrop
					opacity: 0.95
				}
			}

			RowLayout {
				Layout.alignment: Qt.AlignHCenter
				Item {
					Layout.alignment: Qt.AlignHCenter
					width: 200
					height: 35
					Text {
						text: Config.account.name
						width: 200
						height: 35
						visible: Config.lockScreen.showName
						font.pointSize: 12
						verticalAlignment: Text.AlignVCenter
						horizontalAlignment: Text.AlignHCenter
						color: "#fff"
						opacity: passwordBoxContainer.opacity == 0 ? 1 : 0
						Behavior on opacity {
							NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
						}
					}
					BoxExperimental {
						id: passwordBoxContainer
						width: 200
						height: 35
						highlight: AccentColor.color
						opacity: 0
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
									text: passwordBox.text == "" ? root.context.showFailure ? Translation.tr("Incorrect Password") : Translation.tr("Enter Password") : ""
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

							onTextChanged: {
								root.context.currentText = this.text;
								passwordBoxContainer.opacity = 1;
							}

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
			}

			Text {
				Layout.alignment: Qt.AlignHCenter
				horizontalAlignment: Text.AlignHCenter
				text: Config.lockScreen.usageInfo
				color: "#55ffffff"
				width: 180
				Layout.preferredWidth: 180
				wrapMode: Text.WordWrap
				font.pointSize: 9
				font.weight: Font.Normal
				Layout.topMargin: 10
			}
		}
	}
}
