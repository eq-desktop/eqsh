import QtQuick
import QtQuick.Controls
import qs.config
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Shapes
import QtQuick.VectorImage
import Quickshell
import qs
import qs.ui.components.settings.pages
import qs.ui.components.panel
import qs.core.system
import qs.ui.controls.auxiliary
import qs.ui.controls.advanced
import qs.ui.controls.providers
import qs.ui.controls.primitives
import Quickshell.Io
import Quickshell.Widgets

ScrollView {
    Column {
        id: col
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        spacing: 10

        Item {
            height: 1
            width: parent.width
        }

        Item {
            width: parent.width-20
            transform: Translate { x: 10 }

            height: NetworkManager.active ? NetworkManager.active.isSecure ? 115 : 125 : 115
            RectangularShadow {
                anchors.fill: parent
                color: "#20000000"
                radius: 20
                blur: 10
                spread: 5
            }
            Rectangle {
                anchors.fill: parent
                color: Config.general.darkMode ? "#222" : "#ffffff"
                radius: 20

                CFVI {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 15
                    id: wifiIcon
                    size: 30
                    icon: "settings/wifi.svg"
                    colorized: false
                }
                CFText {
                    anchors.left: wifiIcon.right
                    anchors.leftMargin: 10
                    anchors.verticalCenter: wifiIcon.verticalCenter
                    text: Translation.tr("Wi-Fi")
                    font.pixelSize: 16
                    Layout.alignment: Qt.AlignTop
                }

                CFSwitch {
                    anchors.right: parent.right
                    anchors.rightMargin: 15
                    anchors.verticalCenter: wifiIcon.verticalCenter
                    checked: NetworkManager.wifiEnabled
                    onCheckedChanged: {
                        if (checked) {
                            NetworkManager.enableWifi(true)
                        } else {
                            NetworkManager.enableWifi(false)
                        }
                    }
                }
                Rectangle {
                    id: wifiSeperator
                    height: 1
                    width: parent.width-30
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    anchors.top: wifiIcon.bottom
                    anchors.topMargin: 10
                    color: "#50555555"
                }
                CFText {
                    id: wifiConnectedName
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    anchors.top: wifiSeperator.bottom
                    anchors.topMargin: 10
                    font.pixelSize: 16
                    text: NetworkManager.active ? NetworkManager.active.ssid : Translation.tr("No network")
                }
                CFVI {
                    icon: "lock.svg"
                    anchors {
                        verticalCenter: wifiConnectedName.verticalCenter
                        right: wifiStrengthIcon.left
                        rightMargin: 7.5
                    }
                    visible: NetworkManager.active
                    color: Config.general.darkMode ? "#ffffff" : "#000000"
                }
                Wifi {
                    id: wifiStrengthIcon
                    anchors {
                        verticalCenter: wifiConnectedName.verticalCenter
                        right: wifiDetailsButton.left
                        rightMargin: 7.5
                        centerIn: undefined
                    }
                    iconSize: 25
                    width: 25
                    height: 25
                    visible: NetworkManager.active
                    color: Config.general.darkMode ? "#ffffff" : "#000000"
                }
                CFButton {
                    id: wifiDetailsButton
                    anchors {
                        verticalCenter: wifiConnectedName.verticalCenter
                        right: parent.right
                        rightMargin: 15
                        centerIn: undefined
                    }
                    height: 25
                    width: 80
                    rimStrength: 2.5
                    lightDir: Qt.point(-1, -1)
                    radius: 15
                    primary: false
                    color: Config.general.darkMode ? "#333" : "#aaa"
                    hoverColor: Config.general.darkMode ? "#555" : "#bbb"
                    light: "#40ffffff"
                    text: Translation.tr("Details…")
                    visible: NetworkManager.active
                }
                Rectangle {
                    id: wifiConnectedIndicator
                    anchors {
                        top: wifiConnectedName.bottom
                        topMargin: 5
                        left: wifiConnectedName.left
                    }
                    width: 8
                    height: 8
                    radius: 4
                    color: NetworkManager.active ? '#50ff50' : "#ff5050"
                }
                CFText {
                    anchors.left: wifiConnectedIndicator.right
                    anchors.leftMargin: 6
                    anchors.verticalCenter: wifiConnectedIndicator.verticalCenter
                    font.pixelSize: 12
                    height: 12
                    gray: true
                    text: NetworkManager.active ? Translation.tr("Connected") : Translation.tr("Not Connected")
                }
                Rectangle {
                    id: wifiSecurityIndicator
                    anchors {
                        top: wifiConnectedIndicator.bottom
                        topMargin: 5
                        left: wifiConnectedIndicator.left
                    }
                    width: 8
                    height: 8
                    radius: 4
                    color: '#fff650'
                    visible: NetworkManager.active ? !NetworkManager.active.isSecure : false
                }
                CFText {
                    anchors.left: wifiSecurityIndicator.right
                    anchors.leftMargin: 6
                    anchors.verticalCenter: wifiSecurityIndicator.verticalCenter
                    font.pixelSize: 12
                    height: 12
                    gray: true
                    text: "Weak Security"
                    visible: NetworkManager.active ? !NetworkManager.active.isSecure : false
                }
            }  
        }

        Item {
            implicitHeight: listViewContent.contentHeight+61
            width: parent.width-20
            transform: Translate { x: 10 }

            RectangularShadow {
                anchors.fill: parent
                color: "#20000000"
                radius: 20
                blur: 20
                spread: 5
            }
            Rectangle {
                anchors.fill: parent
                radius: 20
                color: Config.general.darkMode ? "#222" : "#ffffff"

                CFText {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 15
                    text: Translation.tr("Known Networks")
                    font.pixelSize: 16
                    Layout.alignment: Qt.AlignTop
                }
                ListView {
                    id: listViewContent
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    anchors.topMargin: 46
                    model: NetworkManager.networksKnown || []
                    spacing: 0
                    delegate: Item {
                        required property var modelData
                        required property int index
                        id: wfNetworkItem
                        width: listViewContent.width
                        property bool hovered: false
                        height: 35
                        Rectangle {
                            width: parent.width-10
                            height: 1
                            color: "#50555555"
                            anchors {
                                bottom: parent.bottom
                                horizontalCenter: parent.horizontalCenter
                            }
                            visible: (wfNetworkItem.index < NetworkManager.networksKnown.length-1)
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                parent.hovered = true
                            }
                            onExited: {
                                parent.hovered = false
                            }
                            onClicked: {
                                if (modelData.active) {
                                    NetworkManager.disconnectFromNetwork()
                                } else {
                                    NetworkManager.connectToNetwork(modelData.ssid, "")
                                }
                            }
                        }
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: -10
                            height: wfNetworkItem.height-5
                            radius: 10
                            color: hovered ? "#10ffffff" : "transparent"
                            RowLayout {
                                anchors.top: parent.top
                                anchors.topMargin: 0
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                spacing: 5
                                Item {
                                    width: 30
                                    height: 30
                                    CFVI {
                                        anchors.centerIn: parent
                                        property string wfIcon: "check.svg"
                                        icon: wfIcon
                                        color: Config.general.darkMode ? "#ffffff" : "#000000"
                                        size: 20
                                        opacity: (modelData?.active || false) ? 1 : 0
                                    }
                                }
                                CFText {
                                    text: (modelData?.ssid || Translation.tr("Unknown Network"))
                                    font.pixelSize: 14
                                    color: Config.general.darkMode ? "#ffffff" : "#000000"
                                }
                            }
                            CFVI {
                                icon: "lock.svg"
                                anchors {
                                    verticalCenter: wifiStrengthIconKnown.verticalCenter
                                    right: wifiStrengthIconKnown.left
                                    rightMargin: 7.5
                                }
                                size: 15
                                color: Config.general.darkMode ? "#ffffff" : "#000000"
                            }
                            Wifi {
                                id: wifiStrengthIconKnown
                                anchors {
                                    verticalCenter: wifiDetailsButtonKnown.verticalCenter
                                    right: wifiDetailsButtonKnown.left
                                    rightMargin: 7.5
                                    centerIn: undefined
                                }
                                networkStrength: (modelData?.strength || 0)
                                iconSize: 25
                                width: 25
                                height: 25
                                color: Config.general.darkMode ? "#ffffff" : "#000000"
                            }
                            CFButton {
                                id: wifiDetailsButtonKnown
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                anchors.top: parent.top
                                anchors.topMargin: 2.5
                                anchors.centerIn: undefined
                                height: 25
                                width: 25
                                rimStrength: 2.5
                                lightDir: Qt.point(-1, -1)
                                radius: 15
                                primary: false
                                color: Config.general.darkMode ? "#333" : "#aaa"
                                hoverColor: Config.general.darkMode ? "#555" : "#bbb"
                                light: "#40ffffff"
                                text: "…"
                            }
                        }
                    }
                }
            }
        }
        Item {
            implicitHeight: listViewContentNetworks.contentHeight+61
            width: parent.width-20
            transform: Translate { x: 10 }

            RectangularShadow {
                anchors.fill: parent
                color: "#20000000"
                radius: 20
                blur: 20
                spread: 5
            }
            Rectangle {
                anchors.fill: parent
                radius: 20
                color: Config.general.darkMode ? "#222" : "#ffffff"

                CFText {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 15
                    text: Translation.tr("Other Networks")
                    font.pixelSize: 16
                    Layout.alignment: Qt.AlignTop
                }
                ListView {
                    id: listViewContentNetworks
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    anchors.topMargin: 46
                    property int passwordInterface: -1
                    model: NetworkManager.networks.filter(n => !NetworkManager.networksKnown.some(nk => nk.ssid === n.ssid)) || []
                    spacing: 0
                    delegate: Item {
                        required property var modelData
                        required property int index
                        id: wfNetworkItem
                        width: listViewContentNetworks.width
                        property bool hovered: false
                        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                        property bool hasPasswordInterface: listViewContentNetworks.passwordInterface === index
                        height: listViewContentNetworks.passwordInterface === index ? 70 : 35

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: {
                                parent.hovered = true
                            }
                            onExited: {
                                parent.hovered = false
                            }
                            onClicked: {
                                listViewContentNetworks.passwordInterface = index
                            }
                        }
                        CFTextField {
                            id: wfPasswordUnknown
                            anchors.left: parent.left
                            anchors.leftMargin: 5
                            anchors.right: parent.right
                            anchors.rightMargin: 100
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 15
                            height: 20

                            selectionColor: '#50ffffff'
                            selectedTextColor: '#a0ffffff'

                            focus: true
                            echoMode: TextInput.Password
                            inputMethodHints: Qt.ImhSensitiveData
                            font.pixelSize: 10
                            glassRimStrength: 0.1
                            glassLightDir: Qt.point(1, -0.01)
                            color: "#ffffff"
                            backgroundColor: "#a0333333"
                            opacity: wfNetworkItem.hasPasswordInterface ? 1 : 0
                            visible: opacity != 0
                            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                            onAccepted: {
                                NetworkManager.connectToNetwork((modelData?.ssid || ""), wfPasswordUnknown.text)
                                wfPasswordUnknown.text = ""
                                listViewContentNetworks.passwordInterface = -1
                            }
                        }
                        CFButton {
                            id: wfPasswordEnterUnknown
                            anchors.left: wfPasswordUnknown.right
                            anchors.leftMargin: 5
                            anchors.right: parent.right
                            anchors.rightMargin: 5
                            anchors.verticalCenter: wfPasswordUnknown.verticalCenter
                            height: 20

                            text: Translation.tr("Connect")
                            primary: true

                            opacity: wfNetworkItem.hasPasswordInterface ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                            onClicked: {
                                NetworkManager.connectToNetwork((modelData?.ssid || ""), wfPasswordUnknown.text)
                                wfPasswordUnknown.text = ""
                                listViewContentNetworks.passwordInterface = -1
                            }
                        }
                        Rectangle {
                            width: parent.width-10
                            height: 1
                            color: "#50555555"
                            anchors {
                                bottom: parent.bottom
                                horizontalCenter: parent.horizontalCenter
                            }
                            visible: (wfNetworkItem.index < NetworkManager.networks.filter(n => !NetworkManager.networksKnown.some(nk => nk.ssid === n.ssid)).length-1)
                        }
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: -10
                            height: wfNetworkItem.height-5
                            radius: 10
                            color: hovered ? "#10ffffff" : "transparent"
                            RowLayout {
                                anchors.top: parent.top
                                anchors.topMargin: 0
                                anchors.left: parent.left
                                anchors.leftMargin: 20
                                spacing: 5
                                Item {
                                    width: 30
                                    height: 30
                                    CFVI {
                                        anchors.centerIn: parent
                                        property string wfIcon: "check.svg"
                                        icon: wfIcon
                                        color: Config.general.darkMode ? "#ffffff" : "#000000"
                                        size: 20
                                        opacity: (modelData?.active || false) ? 1 : 0
                                    }
                                }
                                CFText {
                                    text: (modelData?.ssid || Translation.tr("Unknown Network"))
                                    font.pixelSize: 14
                                    color: Config.general.darkMode ? "#ffffff" : "#000000"
                                }
                            }
                            CFVI {
                                icon: "lock.svg"
                                anchors {
                                    verticalCenter: wifiStrengthIconKnown.verticalCenter
                                    right: wifiStrengthIconKnown.left
                                    rightMargin: 7.5
                                }
                                size: 15
                                color: Config.general.darkMode ? "#ffffff" : "#000000"
                            }
                            Wifi {
                                id: wifiStrengthIconKnown
                                anchors.right: parent.right
                                anchors.rightMargin: 20
                                anchors.top: parent.top
                                anchors.topMargin: 2.5
                                anchors.centerIn: undefined
                                networkStrength: (modelData?.strength || 0)
                                iconSize: 25
                                width: 25
                                height: 25
                                color: Config.general.darkMode ? "#ffffff" : "#000000"
                            }
                        }
                    }
                }
            }
        }

        Item {
            height: 1
            width: parent.width
        }
    }
}