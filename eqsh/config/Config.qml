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
	readonly property DesktopWidgets desktopWidgets: DesktopWidgets {}

	property string homeDirectory: "/home/enviction"

	component General: QtObject {
		property bool darkMode: true
		property string activationKey: "060-XXX-YYY-ZZZ-000"
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
		property bool   islandMode: true // Dynamic Island
		property color  backgroundColor: "#000"
		property color  color: "#ffffff"
		property int    radius: 20
		property int    height: 25
		property int    margin: 2
		property int    minWidth: 200
		property int    maxWidth: 400
		property bool   onlyVisual: false
		property int    hideDuration: 10
		property bool   fluidEdge: true // Cutout corners
		property real   fluidEdgeStrength: 0.4 // can be 0-1
		property string signature: "" // A custom string that displays when Notch is not being used. Leave empty to disable
		property color  signatureColor: "#fff"
		property bool   autohide: false
	}

	component Bar: QtObject {
		property bool   enable: true
		property int    height: 30
		property color  color: "#01000000"
		property color  fullscreenColor: "#000"
		property bool   hideOnLock: true
		property int    hideDuration: 10
		property string defaultAppName: "eqSh" // When no toplevel is focused it will show this text. Ideas: "eqSh" | "Hyprland" | "YOURUSERNAME"
		// Example dateFormats:
		// DEFAULT:
		//     ddd, dd MMM HH:mm
		// USA:
		//     ddd, MMM d, h:mm a   → Tue, Sep 7, 3:45 PM
		//     M/d/yy, h:mm a       → 9/7/25, 3:45 PM
		// UK:
		//     ddd d MMM HH:mm      → Tue 7 Sep 15:45
		//     dd/MM/yyyy HH:mm     → 07/09/2025 15:45
		// GERMANY:
		//     ddd, dd.MM.yyyy HH:mm → Di, 07.09.2025 15:45
		// ISO: 
		//     yyyy-MM-dd HH:mm:ss → 2025-09-07 15:45:10
		property string dateFormat: "ddd, dd MMM HH:mm"
		property bool   autohide: false
	}

	component ScreenEdges: QtObject {
		property bool enable: true
		property int radius: 15
		property string color: "black"
	}

	component LockScreen: QtObject {
		property bool   enable: true
		property int    fadeDuration: 500
		property real   blur: 0
		property real   blurStrength: 1
		property bool   liquidBlur: false
		property bool   liquidBlurMax: false
		property int    liquidDuration: 7000
		property real   zoom: 1.05
		property int    zoomDuration: 300
		property bool   useCustomWallpaper: false
		property string customWallpaperPath: root.homeDirectory+"/eqSh/wallpaper/Sequoia-Sunrise.png"
		property bool   enableShader: false
		property string shaderName: "Raining" // Not compatible with Blur or X-Ray
		property string shaderFrag: "shaders/Raining.frag.qsb" // use `qsb --qt6 -o ./Raining.frag.qsb ./Raining.frag` if you want to convert your own shader. Same goes for Vert
		property string shaderVert: "shaders/Raining.vert.qsb"
	}

	component Misc: QtObject {
		property bool showVersion: true
	}

	component Wallpaper: QtObject {
		property bool   enabled: true
		property color  color: "#000000" // Only applies if path is empty
		property string path: root.homeDirectory+"/eqSh/wallpaper/Sequoia-Sunrise.png"
		property bool   enableShader: false
		property string shaderName: "Raining"
		property string shaderFrag: "shaders/Raining.frag.qsb" // use `qsb --qt6 -o ./Raining.frag.qsb ./Raining.frag` if you want to convert your own shader. Same goes for Vert
		property string shaderVert: "shaders/Raining.vert.qsb"
	}

	component DesktopWidgets: QtObject {
		property bool   enabled: true
		property bool   clockEnable: false
		property string clockColor: "#ffffff"
		property string clockPosition: "tr" // supports: t=top l=left r=right b=bottom v=verticalCenter h=horizontalCenter
		property int    clockMargins: 100
		property string clockFormat: "hh.mm"
	}
}
