pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root
	readonly property Notch       notch: Notch {}
	readonly property Bar         bar: Bar {}
	readonly property ScreenEdges screenEdges: ScreenEdges {}
	readonly property LockScreen  lockScreen: LockScreen {}
	readonly property Misc        misc: Misc {}
	readonly property Wallpaper   wallpaper: Wallpaper {}
	readonly property Notifications notifications: Notifications {}
	readonly property Dialogs dialogs: Dialogs {}
	readonly property General general: General {}

	component General: QtObject {
		property bool darkMode: true
	}

	component Notifications: QtObject {
		property color  backgroundColor: "#ff111111"
	}

	component Dialogs: QtObject {
		property bool   enable: true
		property int    width: 250
		property int    height: 250
		property bool   useShadow: true
		property bool   customColor: true
		property string textColor: "#fff"
		property string backgroundColor: "#232323"
		property string declineButtonColor: "#333"
		property string declineButtonTextColor: "#fff"
		property string acceptButtonColor: "#2369ff"
		property string acceptButtonTextColor: "#fff"
	}

	component Notch: QtObject {
		property bool   enable: true
		property bool   islandMode: false // Dynamic Island
		property color  backgroundColor: "#000"
		property color  color: "#ffffff"
		property int    radius: 20
		property int    height: 35
		property int    minWidth: 200
		property int    maxWidth: 400
		property bool   onlyVisual: false
		property int    hideDuration: 10
		property bool   fluidEdge: true // Cutout corners
		property real   fluidEdgeStrength: 0.4 // can be 0-1
		property string signature: "enviction@nixos" // A custom string that displays when Notch is not being used. Leave empty to disable
		property color  signatureColor: "#fff"
		property bool   autohide: false
	}

	component Bar: QtObject {
		property bool   enable: true
		property int    height: 35
		property color  color: "#01000000"
		property color  fullscreenColor: "#000"
		property bool   hideOnLock: true
		property int    hideDuration: 10
		property string defaultAppName: "eqSh" // When no toplevel is focused it will show this text. Ideas: "eqSh" | "Hyprland" | "YOURUSERNAME"
		property string dateFormat: "ddd dd MMM HH:mm"
		property bool   autohide: false

		// Asthetic
		property bool glintButtons: true
	}

	component ScreenEdges: QtObject {
		property bool enable: true
		property int radius: 15
		property string color: "black"
	}

	component LockScreen: QtObject {
		property bool   enable: true
		property int    fadeDuration: 700
		property bool   xRay: false
		property bool   xRayBlur: false
		property bool   blur: true
		property real   blurStrength: 1
		property bool   liquidBlur: true
		property bool   liquidBlurMax: false
		property int    liquidDuration: 7000
		property bool   useCustomWallpaper: false
		property string customWallpaperPath: "/home/enviction/Pictures/wallpaper/mac/Donut.png"
		property bool   enableShader: false
		property string shaderName: "Raining" // Not compatible with Blur or X-Ray
		property string shaderFrag: "shaders/Raining.frag.qsb" // use `qsb --qt6 -o ./Raining.frag.qsb ./Raining.frag` if you want to convert your own shader. Same goes for Vert
		property string shaderVert: "shaders/Raining.vert.qsb"
	}

	component Misc: QtObject {
		property bool activateLinux: false
		property bool betaVersion: false
	}

	component Wallpaper: QtObject {
		property bool   enabled: true
		property color  color: "#000000" // Only applies if path is empty
		property string path: "/home/enviction/wallpapers/collision.png"
		property bool   enableShader: false
		property string shaderName: "Raining"
		property string shaderFrag: "shaders/Raining.frag.qsb" // use `qsb --qt6 -o ./Raining.frag.qsb ./Raining.frag` if you want to convert your own shader. Same goes for Vert
		property string shaderVert: "shaders/Raining.vert.qsb"
	}
}
