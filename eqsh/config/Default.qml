import Quickshell
import QtQuick
import qs.core.foundation
import Quickshell.Io

Item {
    id: root
	property Notch          notch: adapter.notch
	property Bar            bar: adapter.bar
	property ScreenEdges    screenEdges: adapter.screenEdges
	property LockScreen     lockScreen: adapter.lockScreen
	property Misc           misc: adapter.misc
	property Wallpaper      wallpaper: adapter.wallpaper
	property Notifications  notifications: adapter.notifications
	property Dialogs        dialogs: adapter.dialogs
	property General        general: adapter.general
	property Appearance     appearance: adapter.appearance
	property Launchpad      launchpad: adapter.launchpad
	property Widgets        widgets: adapter.widgets
	property Osd            osd: adapter.osd
	property Account        account: adapter.account
	property string         homeDirectory: SPPathResolver.home
	property Dock		    dock: adapter.dock
	property bool           loaded: fileViewer.loaded

	FileView {
		id: fileViewer
        path: Qt.resolvedUrl(Directories.runtimeDir + "/config.json")
		blockLoading: true
        watchChanges: true
        onFileChanged: reload()
		onAdapterUpdated: writeAdapter()
		JsonAdapter {
			id: adapter
			property Notch          notch: Notch {}
			property Bar            bar: Bar {}
			property ScreenEdges    screenEdges: ScreenEdges {}
			property LockScreen     lockScreen: LockScreen {}
			property Misc           misc: Misc {}
			property Wallpaper      wallpaper: Wallpaper {}
			property Notifications  notifications: Notifications {}
			property Dialogs        dialogs: Dialogs {}
			property General        general: General {}
			property Appearance     appearance: Appearance {}
			property Launchpad      launchpad: Launchpad {}
			property Widgets        widgets: Widgets {}
			property Osd            osd: Osd {}
			property Account        account: Account {}
			property Dock		    dock: Dock {}
		}
	}

	readonly property string version: "Pre-Release 0.0.85-alpha"

	component Account: JsonObject {
		property string activationKey: "060-XXX-YYY-ZZZ-000"
		property string name: "First Lastname"
		property bool   firstTimeRunning: true
		property string avatarPath: root.homeDirectory+"/.face" // Path to avatar image
	}

	component General: JsonObject {
		property bool   darkMode: true
		property bool   reduceMotion: false
		property string language: "en_US" // Available languages: "en", "de", "es", "it", "ja"
	}

	component Appearance: JsonObject {
		property int   iconColorType: 1 // 1=Original | 2=Monochrome | 3=Tinted | 4=Glass
		property int   glassMode: 3 // 0=slight, 1=strong, 2=fun, 3=strongest
		property bool  dynamicAccentColor: true
		property color accentColor: "#2369ff"
	}

	component Notifications: JsonObject {
		property color  backgroundColor: "#ff111111"
	}

	component Dialogs: JsonObject {
		property bool   enable: true
		property int    width: 250
		property int    height: 250
		property bool   useShadow: true
		property bool   customColor: false
		property string textColor: "#fff"
		property string backgroundColor: "#232323"
		property string declineButtonColor: "#333"
		property string declineButtonTextColor: "#fff"
		property string acceptButtonColor: "#2369ff"
		property string acceptButtonTextColor: "#fff"
	}

	component Dock: JsonObject {
		property bool   enable: true
		property bool   showAnimation: true
		property bool   autohide: false
		property int    autohideDelay: 2000
		property int    scale: 1
		property string position: "bottom" // bottom | left | right
		property list<string> apps: [
			"org.gnome.Nautilus",
			"eq:launchpad",
			"eq:settings",
			"kitty",
			"org.mozilla.firefox",
			"code",
			"org.gnome.DiskUtility"
		]
	}

	component Notch: JsonObject {
		property bool   enable: true
		property bool   islandMode: false // Dynamic Island
		property color  backgroundColor: "#000"
		property color  color: "#ffffff"
		property int    radius: 30
		property int    height: 25
		property int    margin: 2
		property int    minWidth: 200
		property int    maxWidth: 400
		property bool   onlyVisual: false
		property int    hideDuration: 1000
		property bool   fluidEdge: true // Cutout corners
		property real   fluidEdgeStrength: 0.6 // can be 0-1
		property string signature: "" // A custom string that displays when Notch is not being used. Leave empty to disable
		property color  signatureColor: "#fff"
		property bool   autohide: false
		/* == HIGH SECURITY RISK == */
		property bool   interactiveLockscreen: false // If true, the notch will be interactive on the lockscreen. This is a huge security risk
	}

	component Launchpad: JsonObject {
		property bool   enable: true
		property int    fadeDuration: 500
		property real   zoom: 1.05
	}

	component Bar: JsonObject {
		property bool   monochromeTray: true
		property bool   enable: true
		property int    height: 30
		property bool   animateButton: false
		property int    buttonColorMode: 1 // 0=color | 1=accentcolor | 2=transparent
		property string buttonColor: "#22ff0000" // Only applies if buttonColorMode is 0
		property color  color: "#01000000"
		property bool   useBlur: false
		property color  fullscreenColor: "#000"
		property bool   hideOnLock: true
		property int    hideDuration: 10
		property string batteryFormat: "%p%"
		property string batteryFormatChargin: "*%p%"
  		property string batteryMode: "pill" // pill, percentage, number, number-pill, percentage-pill, bubble
		property string defaultAppName: "Equora" // When no toplevel is focused it will show this text. Ideas: "Equora" | "eqSh" | "Hyprland" | "YOURUSERNAME"
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
		property bool   autohideGlobalMenu: false
		property int    autohideGlobalMenuMode: 1 // 0=drag | 1=hover
	}

	component ScreenEdges: JsonObject {
		property bool enable: true
		property int radius: 20
		property string color: "black"
	}

	component Osd: JsonObject {
		property bool   enable: true
		property string color: "#40000000"
		property int    animation: 1 // bubble=3 | fade=2 | scale=1
		property int    duration: 200
	}

	component LockScreen: JsonObject {
		property bool         enable: true
		property int          fadeDuration: 500
		property bool         useFocusedScreen: true // If false, it will use the screen defined in `mainScreen`
		property string       mainScreen: "eDP-1" // if empty, it will use the interactive screen
		property list<string> interactiveScreens: ["eDP-1", "DP-1"]
		property string       dateFormat: "dddd, MMMM dd"
		property string       timeFormat: "HH:mm"
		property bool         showName: true
		property bool         showAvatar: true
		property int          avatarSize: 50
		property string       userNote: "" // A small note above the avatar
		property string       usageInfo: "Touch ID or Enter Password" // A small note below the textfield
		property real         blur: 0
		property real         blurStrength: 1
		property bool         liquidBlur: false
		property bool         liquidBlurMax: false
		property int          liquidDuration: 7000
		property real         clockZoom: 1
		property int          clockZoomDuration: 300
		property string       dimColor: "#000000"
		property real         dimOpacity: 0.1
		property real         zoom: 1
		property int          zoomDuration: 0
		property bool         useCustomWallpaper: false
		property string       customWallpaperPath: root.homeDirectory+"/.local/share/equora/wallpapers/Sequoia-Sunrise.png"
		property bool         enableShader: false
		property string       shaderName: "Raining" // Not compatible with Blur or X-Ray
		property string       shaderFrag: Quickshell.shellDir + "/media/shaders/Raining.frag.qsb" // use `qsb --qt6 -o ./Raining.frag.qsb ./Raining.frag` if you want to convert your own shader. Same goes for Vert
		property string       shaderVert: Quickshell.shellDir + "/media/shaders/Raining.vert.qsb"
	}

	component Misc: JsonObject {
		property bool showVersion: false
	}

	component Wallpaper: JsonObject {
		property bool   enable: true
		property color  color: "#000000" // Only applies if path is empty
		property string path: root.homeDirectory+"/.local/share/equora/wallpapers/Tahoe-city.jpeg"
		property bool   enableShader: false
		property string shaderName: "Raining"
		property string shaderFrag: Quickshell.shellDir + "/media/shaders/Raining.frag.qsb" // use `qsb --qt6 -o ./Raining.frag.qsb ./Raining.frag` if you want to convert your own shader. Same goes for Vert
		property string shaderVert: Quickshell.shellDir + "/media/shaders/Raining.vert.qsb"
	}

	component Widgets: JsonObject {
		property bool   enable: true
		property int    radius: 20
		property int    cellsX: 16
		property int    cellsY: 10
		property string location: "Berlin"
		property bool   useLocationInUI: true
		property string tempUnit: "C"
	}

	component ControlCenter: JsonObject {
	}
}
