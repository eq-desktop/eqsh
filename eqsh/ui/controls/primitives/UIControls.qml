import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.ui.controls.advanced
import qs.config

Control {
    id: root
    property real lightScale: 1.2
    property real hoverScale: lightScale
    property real _actualScale: lightScale
    property bool showBox: false
    property bool focused: false
    property var actionClose: () => {}
    property var actionMinimize: () => {}
    property var actionMaximize: () => {}
    property var buttons: [
        {color: "#FF5F57", icon: "close", action: actionClose},
        {color: "#FEBC2E", icon: "minimize", action: actionMinimize},
        {color: "#28C840", icon: "maximize", action: actionMaximize}
    ]
    property int _margins: 10
    property int _vMargins: _margins
    property int _hMargins: _margins
    property int _hMarginsB: _margins
    property int _animationSpeed: 300
    property string state: focused ? "focused" : "unfocused" // unfocused, focused, active
    property list<bool> active: [true, false, false]
    property list<bool> available: [true, true, true]
    width: ((13+_hMargins)*Array.from(root.available).filter(v => v).length)*_actualScale
    height: (13+_vMargins)*_actualScale
    anchors.margins: _margins
    onFocusedChanged: {
        root.state = root.focused ? "focused" : "unfocused"
    }
    Behavior on width { NumberAnimation { duration: root._animationSpeed; easing.type: Easing.OutBack; easing.overshoot: 0.75 } }
    Behavior on height { NumberAnimation { duration: root._animationSpeed; easing.type: Easing.OutBack; easing.overshoot: 0.75 } }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            root.state = "active"
            root._actualScale = root.hoverScale
        }
        onExited: {
            root.state = root.focused ? "focused" : "unfocused"
            root._actualScale = root.lightScale
        }
        BoxGlass {
            anchors.fill: parent
            rimStrength: 0.4
            radius: Infinity
            visible: showBox
        }
        Row {
            id: layout
            anchors {
                centerIn: parent
            }
            spacing: ((13+(_hMarginsB/2))*_actualScale)/2
            Behavior on spacing { NumberAnimation { duration: root._animationSpeed; easing.type: Easing.OutBack } }
            Repeater {
                model: root.buttons
                Rectangle {
                    id: light
                    width: 13*_actualScale
                    height: 13*_actualScale
                    Behavior on width { NumberAnimation { duration: root._animationSpeed; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
                    Behavior on height { NumberAnimation { duration: root._animationSpeed; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
                    visible: root.available[index]
                    color: ["focused", "active"].includes(root.state) ? (root.active[index] ? modelData.color : (Config.general.darkMode ? "#434240" : '#d9d9d9')) : (Config.general.darkMode ? "#4E4D4B" : '#929292')
                    radius: Infinity
                    MouseArea {
                        anchors.fill: parent
                        onClicked: modelData.action()
                        CFVI {
                            anchors.centerIn: parent
                            size: (13*_actualScale)-3
                            visible: root.state == "active" && root.active[index]
                            Behavior on size { NumberAnimation { duration: root._animationSpeed; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
                            source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/windows/" + modelData.icon + ".svg")
                            color: Qt.darker(light.color, 5)
                        }
                    }
                }
            }
        }
    }
}