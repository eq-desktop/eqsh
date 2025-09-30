import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.VectorImage
import qs.config
import qs
import qs.ui.controls.auxiliary


Scope {
  id: root

  property string customAppName: ""

  property bool visible: false
  property real opacity: 0
  property string acceptButton: ""
  property string declineButton: ""
  property string title: ""
  property string description: ""
  property string iconPath: ""

  property string commandOnDecline: "notify-send 'Decline'"
  property string commandOnAccept: "notify-send 'Accept'"

  property var dialogs: customStyling ? styleDialogs : Config.dialogs

  property bool customStyling: false
  property Dialogs styleDialogs: Dialogs {}
  component Dialogs: QtObject {
		property int    width: Config.dialogs.width
		property int    height: Config.dialogs.height
		property bool   useShadow: Config.dialogs.useShadow
		property bool   customColor: Config.dialogs.customColor
		property string textColor: Config.dialogs.textColor
		property string backgroundColor: Config.dialogs.backgroundColor
		property string declineButtonColor: Config.dialogs.declineButtonColor
		property string declineButtonTextColor: Config.dialogs.declineButtonTextColor
		property string acceptButtonColor: Config.dialogs.acceptButtonColor
		property string acceptButtonTextColor: Config.dialogs.acceptButtonTextColor
  }
  onCustomAppNameChanged: {
    Runtime.customAppName = customAppName;
  }
  PanelWindow {
    WlrLayershell.layer: WlrLayer.Overlay
    id: panelWindow
    implicitWidth: root.dialogs.width + 50
    implicitHeight: root.dialogs.height + 50
    exclusiveZone: -1
    visible: root.visible
    color: "transparent"
		WlrLayershell.namespace: "eqsh-noblur"

    mask: Region {
      x: 25; y: 25
      width: root.dialogs.width; height: root.dialogs.height
    }

    RectangularShadow {
      spread: 0
      blur: 30
      color: "#000000"
      anchors.fill: rect
      radius: rect.radius
      visible: root.dialogs.useShadow
    }

    Rectangle {
      id: rect
      anchors.centerIn: parent
      color: root.dialogs.customColor ? root.dialogs.backgroundColor : (Config.general.darkMode ? "#232323" : "#dadada")
      radius: 15
      opacity: root.opacity

      implicitHeight: root.dialogs.height
      implicitWidth: root.dialogs.width

      PropertyAnimation {
        id: fadeOutAnim
        target: rect
        property: "opacity"
        to: 0
        duration: 150
        onStopped: {
          root.opacity = 0;
          root.visible = false;
          root.customStyling = false;
        }
      }

      Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
      }

      Loader {
        anchors {
          top: parent.top
          topMargin: 20
          horizontalCenter: parent.horizontalCenter
        }
        property Component png: Image {
          source: Qt.resolvedUrl(iconPath)
          width: 70
          height: 70
          mipmap: true
        }
        property Component svg: VectorImage {
          source: Qt.resolvedUrl(iconPath)
          width: 100
          height: 100
          preferredRendererType: VectorImage.CurveRenderer
        }
        sourceComponent: iconPath.split(".")[-1] != "svg" ? png : svg
      }

      Text {
        id: titleText
        anchors {
          centerIn: parent
        }
        width: root.dialogs.width-10
        text: root.title
        font.pixelSize: 14
        color: root.dialogs.customColor ? root.dialogs.textColor : (Config.general.darkMode ? "#fff" : "#222")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
      }
      Text {
        anchors {
          top: titleText.bottom
          topMargin: 10
          horizontalCenter: parent.horizontalCenter
        }
        width: root.dialogs.width-20
        font.pixelSize: 12
        text: root.description
        color: root.dialogs.customColor ? root.dialogs.textColor : (Config.general.darkMode ? "#fff" : "#222")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
      }
      Button {
        implicitHeight: 30
        implicitWidth: Math.round(root.dialogs.width / 2) - 15
        onClicked: {
          root.customAppName = "";
          Quickshell.execDetached(["sh", "-c", root.commandOnDecline]);
          fadeOutAnim.start();
        }
        background: Rectangle {
          id: bg
          color: root.dialogs.customColor ? root.dialogs.declineButtonColor : (Config.general.darkMode ? "#444" : "#bbb")
          anchors.fill: parent
          radius: 10
          Text {
            anchors.fill: parent
            text: root.declineButton
            color: root.dialogs.customColor ? root.dialogs.declineButtonTextColor : (Config.general.darkMode ? "#fff" : "#222")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
          }
        }
        hoverEnabled: true
        onHoveredChanged: {
          if (hovered) {
            bg.color = root.dialogs.customColor ? Qt.darker(root.dialogs.declineButtonColor, 0.9) : (Config.general.darkMode ? "#555" : "#ccc");
          } else {
            bg.color = root.dialogs.customColor ? root.dialogs.declineButtonColor : (Config.general.darkMode ? "#444" : "#bbb");
          }
        }
        anchors {
          bottom: parent.bottom
          left: parent.left
          leftMargin: 10
          bottomMargin: 10
        }
      }
      Button {
        implicitHeight: 30
        implicitWidth: Math.round(root.dialogs.width / 2) - 15
        onClicked: {
          root.customAppName = "";
          Quickshell.execDetached(["sh", "-c", root.commandOnAccept]);
          fadeOutAnim.start();
        }
        background: Rectangle {
          id: bgAc
          color: root.dialogs.customColor ? root.dialogs.acceptButtonColor : (Config.general.darkMode ? "#2369ff" : "#2369ff")
          anchors.fill: parent
          radius: 10
          Text {
            anchors.fill: parent
            text: root.acceptButton
            color: root.dialogs.customColor ? root.dialogs.acceptButtonTextColor : (Config.general.darkMode ? "#fff" : "#fff")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
          }
        }
        hoverEnabled: true
        onHoveredChanged: {
          if (hovered) {
            bgAc.color = root.dialogs.customColor ? Qt.darker(root.dialogs.acceptButtonColor, 0.9) : (Config.general.darkMode ? "#4882ff" : "#4882ff");;
          } else {
            bgAc.color = root.dialogs.customColor ? root.dialogs.acceptButtonColor : (Config.general.darkMode ? "#2369ff" : "#2369ff");
          }
        }
        anchors {
          bottom: parent.bottom
          right: parent.right
          rightMargin: 10
          bottomMargin: 10
        }
      }
    }
  }
  IpcHandler {
    target: "systemDialogs"

    function newDialog(appName: string, icon_path: string, title: string, description: string, accept: string, decline: string, commandAccept: string, commandDecline: string, customStyle: string): void {
      console.info("new System Dialog.");
      if (customStyle != "") {
        // Split the customStyle string by semi-colons to get each "prop:value" pair
        var styles = customStyle.split(";");
        root.customStyling = true;

        // Iterate over each prop:value pair and assign to the corresponding style property
        for (var i = 0; i < styles.length; i++) {
          var pair = styles[i].split(":");
          var prop = pair[0].trim();
          var value = pair[1].trim();

          // Check which property to assign the value to based on the prop
          switch (prop) {
            case "width":
              styleDialogs.width = parseInt(value);
              break;
            case "height":
              styleDialogs.height = parseInt(value);
              break;
            case "useShadow":
            case "shadow":
            case "box-shadow":
              styleDialogs.useShadow = value === "true"; // Convert to boolean
              break;
            case "customColor":
              styleDialogs.customColor = value === "true"; // Convert to boolean
              break;
            case "color":
              styleDialogs.textColor = value;
              break;
            case "background-color":
            case "backgroundColor":
              styleDialogs.backgroundColor = value;
              break;
            case ".decline-button@background-color":
            case "declineButtonColor":
              styleDialogs.declineButtonColor = value;
              break;
            case ".decline-button@color":
            case "declineButtonTextColor":
              styleDialogs.declineButtonTextColor = value;
              break;
            case ".accept-button@background-color":
            case "acceptButtonColor":
              styleDialogs.acceptButtonColor = value;
              break;
            case ".accept-button@color":
            case "acceptButtonTextColor":
              styleDialogs.acceptButtonTextColor = value;
              break;
            default:
              console.warn("Unknown property: " + prop);
              break;
          }
        }
      }
      root.iconPath = icon_path;
      root.customAppName = appName;
      root.title = title;
      root.declineButton = decline;
      root.acceptButton = accept;
      root.description = description;
      root.visible = true;
      root.opacity = 1
      root.commandOnAccept = commandAccept;
      root.commandOnDecline = commandDecline;
    }
  }
}

