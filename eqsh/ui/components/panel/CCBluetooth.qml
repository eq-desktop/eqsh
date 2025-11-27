import Quickshell
import Quickshell.Bluetooth
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs
import qs.ui.controls.primitives
import qs.ui.controls.providers
import qs.ui.controls.advanced


Item {
    id: root
    property var adapter: Bluetooth.defaultAdapter
    property var enabled: adapter ? adapter.enabled : false
    property var devices: {
        var filteredDevices = adapter ? adapter.devices.values.filter(function(device) {
            return device.name !== "";
        }) : [];
        filteredDevices.sort(function(a, b) {
            return a.connected === b.connected ? 0 : a.connected ? -1 : 1;
        });
        return filteredDevices;
    }
    Item {
        id: content
        anchors.fill: parent
        CFText {
            text: "Bluetooth"
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
            id: btSwitch
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.top: parent.top
            anchors.topMargin: 15
            checked: root.enabled
            onCheckedChanged: {
                if (adapter) {
                    adapter.enabled = checked
                }
            }
        }
        ListView {
            id: listView
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top: parent.top
            anchors.topMargin: 60
            height: 150
            model: devices
            spacing: 0
            delegate: Item {
                required property var modelData
                id: btDeviceItem
                width: listView.width
                height: 35
                property bool hovered: false
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
                        if (modelData.connected) {
                            modelData.disconnect()
                        } else {
                            modelData.connect()
                        }
                    }
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: -10
                    height: 30
                    radius: 10
                    color: hovered ? "#10ffffff" : "transparent"
                    RowLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        spacing: 10
                        Rectangle {
                            width: 25
                            height: 25
                            radius: 100
                            color: modelData.connected ? "#fff" : "#20ffffff"
                            CFVI {
                                property string btIcon: "bluetooth/bluetooth.svg"
                                icon: btIcon
                                color: modelData.connected ? AccentColor.color : "#ffffff"
                                size: 25
                            }
                        }
                        CFText {
                            text: modelData.name
                            font.pixelSize: 14
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
            anchors.topMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#10ffffff"
        }

        CFText {
            text: "Bluetooth Settings..."
            font.pixelSize: 14
            font.weight: 500
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.top: separatorBottom.bottom
            anchors.topMargin: 10
            color: "#ffffff"
        }
    }
}