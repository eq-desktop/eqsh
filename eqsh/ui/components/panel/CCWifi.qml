import Quickshell
import Quickshell.Bluetooth
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs
import qs.core.system
import qs.ui.controls.primitives
import qs.ui.controls.providers
import qs.ui.controls.advanced


Item {
    id: root

    required property color glassColor
    required property color glassRimColor
    required property real  glassRimStrength
    required property real  glassRimStrengthStrong
    required property point glassLightDirStrong
    required property color textColor
    property bool wifiEnabled: NetworkManager.wifiEnabled
    property bool otherNetworksShown: false
    property var networks: NetworkManager.networks
    property var networksKnown: NetworkManager.networksKnown
    implicitHeight: listView.height + 175 + (otherNetworksShown ? listViewUnknown.height : 0)
    Item {
        id: content
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        CFText {
            id: title
            text: Translation.tr("Wi-Fi")
            font.weight: 700
            font.pixelSize: 16
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 20
            color: "#ffffff"
        }
        Rectangle {
            id: separator
            width: parent.width - 40
            height: 1
            anchors.top: parent.top
            anchors.topMargin: 50
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#20ffffff"
        }
        CFSwitch {
            id: wfSwitch
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: title.verticalCenter
            checked: root.wifiEnabled
            switchHeight: Math.round(22*1.3)
            switchWidth: Math.round(54*1.3)
            height: Math.round(22*1.3)
            width: Math.round(54*1.3)
            z: 100
            onCheckedChanged: {
                if (checked) {
                    NetworkManager.enableWifi(true)
                } else {
                    NetworkManager.enableWifi(false)
                }
            }
        }
        CFText {
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 60
            text: Translation.tr("Known Networks")
            font.pixelSize: 14
            font.weight: 500
            color: "#a0ffffff"
        }
        ClippingRectangle {
            id: listView
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 85
            height: listViewContent.contentHeight
            color: "transparent"
            radius: 0
            ListView {
                id: listViewContent
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                model: networksKnown ?? []
                spacing: 0
                delegate: Item {
                    required property var modelData
                    required property int index
                    id: wfNetworkItem
                    width: listViewContent.width
                    property bool hovered: false
                    height: 35
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
                            if ((modelData?.active || false)) {
                                NetworkManager.disconnectFromNetwork()
                            } else {
                                NetworkManager.connectToNetwork((modelData?.ssid || ""), "")
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
                            anchors.leftMargin: 5
                            spacing: 10
                            Rectangle {
                                width: 30
                                height: 30
                                radius: 100
                                color: (modelData?.active || false) ? AccentColor.color : "#20ffffff"
                                CFVI {
                                    anchors.centerIn: parent
                                    property string wfIcon: "wifi/nm-signal-100-symbolic.svg"
                                    icon: wfIcon
                                    transform: Translate {
                                        x: 1
                                        y: -2
                                    }
                                    color: (modelData?.active || false) ? AccentColor.textColor : "#ffffff"
                                    size: 25
                                }
                            }
                            CFText {
                                text: (modelData?.ssid || Translation.tr("Unknown Network"))
                                font.pixelSize: 14
                                color: "#ffffff"
                            }
                        }
                        CFVI {
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.top: parent.top
                            anchors.topMargin: 5
                            icon: "lock.svg"
                            color: "#ffffff"
                            size: 15
                        }
                    }
                }
            }
        }

        Rectangle {
            id: separatorBottom
            width: parent.width - 40
            height: 1
            anchors.top: listView.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#10ffffff"
        }

        Item {
            id: othernetworks
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top: separatorBottom.bottom
            anchors.topMargin: 10
            height: root.otherNetworksShown ? (listViewUnknown.height)-20 : 18
            CFText {
                id: othernetworksText
                text: Translation.tr("Other Networks")
                font.pixelSize: 14
                font.weight: 500
                color: "#a0ffffff"
            }

            CFVI {
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.verticalCenter: othernetworksText.verticalCenter
                icon: "chevron-right.svg"
                color: "#ffffff"
                size: 20
            }
            MouseArea {
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                height: othernetworksText.height
                onClicked: {
                    root.otherNetworksShown = !root.otherNetworksShown
                }
            }
            ClippingRectangle {
                id: listViewUnknown
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 25
                height: root.otherNetworksShown ? listViewUnknownContent.contentHeight : 0
                color: "transparent"
                radius: 0
                property int passwordInterface: -1
                ListView {
                    id: listViewUnknownContent
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    model: root.networks ?? []
                    spacing: 0
                    delegate: Item {
                        required property var modelData
                        required property int index
                        id: wfNetworkItemUnknown
                        width: listViewUnknownContent.width
                        property bool hovered: false
                        property bool hasPasswordInterface: index == listViewUnknown.passwordInterface
                        height: hasPasswordInterface ? 65 : 35
                        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1 } }
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
                                if ((modelData?.active || false)) {
                                    NetworkManager.disconnectFromNetwork()
                                } else {
                                    listViewUnknown.passwordInterface = index
                                    //NetworkManager.connectToNetwork(modelData.ssid, "")
                                }
                            }
                        }
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: -10
                            height: wfNetworkItemUnknown.height-5
                            radius: 10
                            color: hovered ? "#10ffffff" : "transparent"
                            RowLayout {
                                anchors.top: parent.top
                                anchors.topMargin: 0
                                anchors.left: parent.left
                                anchors.leftMargin: 5
                                spacing: 10
                                Rectangle {
                                    width: 30
                                    height: 30
                                    radius: 100
                                    color: (modelData?.active || false) ? AccentColor.color : "#20ffffff"
                                    CFVI {
                                        anchors.centerIn: parent
                                        property string wfIcon: "wifi/nm-signal-100-symbolic.svg"
                                        icon: wfIcon
                                        transform: Translate {
                                            x: 1
                                            y: -2
                                        }
                                        color: (modelData?.active || false) ? AccentColor.textColor : "#ffffff"
                                        size: 25
                                    }
                                }
                                CFText {
                                    text: (modelData?.ssid || Translation.tr("Unknown Network"))
                                    font.pixelSize: 14
                                    color: "#ffffff"
                                }
                            }
                            CFVI {
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                anchors.top: parent.top
                                anchors.topMargin: 5
                                icon: "lock.svg"
                                color: "#ffffff"
                                size: 15
                            }
                            CFTextField {
                                id: wfPasswordUnknown
                                anchors.left: parent.left
                                anchors.leftMargin: 5
                                anchors.right: parent.right
                                anchors.rightMargin: 100
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 5
                                height: 20

                                selectionColor: '#50ffffff'
                                selectedTextColor: '#a0ffffff'

                                focus: true
                                echoMode: TextInput.Password
                                inputMethodHints: Qt.ImhSensitiveData
                                font.pixelSize: 10
                                color: "#ffffff"
                                backgroundColor: "#a0333333"
                                opacity: wfNetworkItemUnknown.hasPasswordInterface ? 1 : 0
                                visible: opacity != 0
                                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                                onAccepted: {
                                    NetworkManager.connectToNetwork((modelData?.ssid || ""), wfPasswordUnknown.text)
                                    wfPasswordUnknown.text = ""
                                    listViewUnknown.passwordInterface = -1
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
                                color: AccentColor.color

                                opacity: wfNetworkItemUnknown.hasPasswordInterface ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                                onClicked: {
                                    NetworkManager.connectToNetwork((modelData?.ssid || ""), wfPasswordUnknown.text)
                                    wfPasswordUnknown.text = ""
                                    listViewUnknown.passwordInterface = -1
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: separatorBottom2
            width: parent.width - 40
            height: 1
            anchors.top: othernetworks.bottom
            anchors.topMargin: root.otherNetworksShown ? 50 : 10
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#10ffffff"
        }

        CFButton {
            text: Translation.tr("Wi-Fi Settings...")
            font.pixelSize: 14
            font.weight: 500
            background: null
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.top: separatorBottom2.bottom
            anchors.topMargin: 10
            color: "#ffffff"
        }
    }
}