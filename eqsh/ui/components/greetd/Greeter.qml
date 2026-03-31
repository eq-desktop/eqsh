pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls

import qs
import qs.config
import qs.ui.controls.auxiliary
import qs.ui.controls.primitives
import qs.ui.controls.advanced

import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Services.Greetd

ShellRoot {
    id: root

    property string preferredUser: "enviction"
    property string preferredSession: "hyprland"

    function startAuth() {
        if (currentUser === "" || currentSession === "") return
        Greetd.createSession(currentUser)
    }

    /* ---------------- USERS ---------------- */

    Process {
        id: userProc
        running: true
        command: ["awk", "BEGIN { FS = \":\" } /\\/home/ { print $1 }", "/etc/passwd"]

        property list<string> userList: []
        property int userIndex: 0
        property string currentUser: userList[userIndex] ?? ""

        function nextUser() {
            userIndex = (userIndex + 1) % userList.length
        }

        stdout: SplitParser {
            onRead: data => {
                userProc.userList.push(data)
                userProc.userIndex = userProc.userList.indexOf(root.preferredUser)
            }
        }
    }

    /* ---------------- SESSIONS ---------------- */

    Process {
        id: sessionProc
        running: true
        command: ["sh", "-c", "ls /usr/share/wayland-sessions | sed 's/.desktop//'"]

        property list<string> sessionList: []
        property int sessionIndex: 0
        property string currentSession: sessionList[sessionIndex] ?? ""

        function nextSession() {
            sessionIndex = (sessionIndex + 1) % sessionList.length
        }

        stdout: SplitParser {
            onRead: data => {
                sessionProc.sessionList.push(data)
                sessionProc.sessionIndex = sessionProc.sessionList.indexOf(root.preferredSession)
            }
        }
    }

    property string currentUser: userProc.currentUser
    property string currentSession: sessionProc.currentSession
    property string passwordBuffer: ""

    /* ---------------- UI ---------------- */

    FloatingWindow {
        Rectangle {
            anchors.fill: parent
            color: "#111"
        }

        CFI {
            id: background
            layer.enabled: true
            anchors.fill: parent
            source: Config.wallpaper.path
            colorized: false
        }

        Blur {
            id: blur
            anchors.fill: parent
            source: background
            blur: 0
            blurMultiplier: 0
            visible: false
        }

        ShaderEffectSource {
            id: userSelectModalShader
            anchors.fill: userSelectModalProxy
            sourceRect: Qt.rect(userSelectModalProxy.x, userSelectModalProxy.y, userSelectModalProxy.width, userSelectModalProxy.height)
            sourceItem: blur
            visible: false
        }
        UILiquidProxy {
            id: userSelectModalProxy
            liquid: userSelectModal
            CFClippingRect {
                anchors.fill: parent
                radius: 25
                GlassBox {
                    radius: 25
                    anchors.fill: parent
                    anchors.leftMargin: 1
                    anchors.topMargin: 1
                    id: mediaGlass
                    glassBevel: 20
                    source: userSelectModalShader
                    height: 250
                    Behavior on glassBevel {
                        NumberAnimation { duration: 400 }
                    }
                    Behavior on glassHairlineWidthPixels {
                        NumberAnimation { duration: 400 }
                    }
                    glassBevel: 20
                    Component.onCompleted: {
                        mediaGlass.glassBevel = 20
                        mediaGlass.glassHairlineWidthPixels = 0.15
                    }
                    glassMaxRefractionDistance: 0
                    glassHairlineReflectionDistance: 0
                    glassHairlineWidthPixels: 0
                }
            }
        }

        UILiquid {
            id: userSelectModal
            width: 240
            height: 40
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
            property bool opened: false
            onClicked: userSelectModal.opened = !userSelectModal.opened
            stretching: !userSelectModal.opened
            onOpenedChanged: {
                if (!opened) {
                    userSelectModal.sizeTo(240, 40, Qt.point(5, 5))
                } else {
                    userSelectModal.sizeTo(240, (userProc.userList.length*40), Qt.point(0, -50))
                }
            }
            Item {
                id: userSelectModalInternal
                z: 99
                anchors.fill: parent
                CFText {
                    anchors.centerIn: parent
                    text: root.currentUser
                    color: "white"
                    font.bold: true
                    font.pointSize: 16
                    opacity: !userSelectModal.opened ? 1 : 0
                    visible: opacity !== 0
                    Behavior on opacity { NumberAnimation { duration: 180 } }
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 1
                        blurMax: !userSelectModal.opened ? 0 : 32
                        Behavior on blur { NumberAnimation { duration: 320 } }
                    }
                }
                ListView {
                    id: userSelectList
                    anchors.fill: parent
                    opacity: userSelectModal.opened ? 1 : 0
                    visible: opacity !== 0
                    Behavior on opacity { NumberAnimation { duration: 180 } }
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 1
                        blurMax: userSelectModal.opened ? 0 : 16
                        Behavior on blur { NumberAnimation { duration: 180 } }
                    }
                    model: userProc.userList
                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: userSelectList.width
                        height: 40
                        color: "transparent"
                        radius: 8
                        CFText {
                            anchors.centerIn: parent
                            text: modelData
                            color: "white"
                            font.bold: userProc.userIndex == index
                            font.pointSize: 16
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                userProc.userIndex = index
                                userSelectModal.opened = false
                            }
                        }
                    }
                }
            }
        }

        ShaderEffectSource {
            id: passwordBoxShader
            anchors.fill: passwordBox
            sourceRect: Qt.rect(passwordBox.x, passwordBox.y, passwordBox.width, passwordBox.height)
            sourceItem: blur
        }
        CFClippingRect {
            anchors.fill: passwordBox
            radius: 35
            GlassBox {
                id: passwordGlass
                radius: 35
                anchors.fill: parent
                anchors.leftMargin: 1
                anchors.topMargin: 1
                source: passwordBoxShader
                height: 250
                Behavior on glassBevel {
                    NumberAnimation { duration: 400 }
                }
                Behavior on glassHairlineWidthPixels {
                    NumberAnimation { duration: 400 }
                }
                glassBevel: 0
                Component.onCompleted: {
                    passwordGlass.glassBevel = 30
                    passwordGlass.glassHairlineWidthPixels = 0.15
                }
                glassMaxRefractionDistance: 0
                glassHairlineReflectionDistance: 0
                glassHairlineWidthPixels: 0
            }
        }

        Item {
            id: passwordBox
            width: 240
            height: 40
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: userSelectModal.bottom
                topMargin: 20
            }
            CFTextField {
                anchors.fill: parent
                background: null
                text: root.passwordBuffer
                focus: true
                echoMode: TextInput.Password
                color: "white"
                font.pointSize: 12
                onAccepted: {
                    root.passwordBuffer = text
                    root.startAuth()
                }
                placeholderText: "Enter Password"
                placeholderTextColor: "#40ffffff"
                leftPadding: 12
            }
        }

        CFVI {
            anchors {
                top: parent.top
                right: parent.right
                margins: 20
            }
            width: 20
            height: 20
            color: "#a0ffffff"
            icon: "notch/power.svg"
            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack; easing.overshoot: 3 } }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    parent.scale = 1.2
                }
                onExited: {
                    parent.scale = 1
                }
            }
        }

        

        ShaderEffectSource {
            id: sessionModalShader
            anchors.fill: sessionModalProxy
            sourceRect: Qt.rect(sessionModalProxy.x, sessionModalProxy.y, sessionModalProxy.width, sessionModalProxy.height)
            sourceItem: blur
            visible: false
        }
        UILiquidProxy {
            id: sessionModalProxy
            liquid: sessionModal
            CFClippingRect {
                anchors.fill: parent
                radius: 30
                GlassBox {
                    radius: 30
                    anchors.fill: parent
                    anchors.leftMargin: 1
                    anchors.topMargin: 1
                    id: sessionModalGlass
                    glassBevel: 1
                    source: sessionModalShader
                    height: 250
                    Behavior on glassBevel {
                        NumberAnimation { duration: 400 }
                    }
                    Behavior on glassHairlineWidthPixels {
                        NumberAnimation { duration: 400 }
                    }
                    glassBevel: 0
                    Component.onCompleted: {
                        sessionModalGlass.glassBevel = 10
                        sessionModalGlass.glassHairlineWidthPixels = 0.1
                    }
                    glassMaxRefractionDistance: 0
                    glassHairlineReflectionDistance: 0
                    glassHairlineWidthPixels: 0
                }
            }
        }

        UILiquid {
            id: sessionModal
            anchors {
                right: parent.right
                rightMargin: 20
                bottom: parent.bottom
                bottomMargin: 20
            }
            property bool opened: false
            property int longestItem: 150
            onOpenedChanged: {
                if (!opened) {
                    sessionModal.sizeTo(120, 40, Qt.point(5, 5))
                } else {
                    sessionModal.sizeTo(sessionModal.longestItem, (sessionProc.sessionList.length*20)+20, Qt.point(-50, -20))
                }
            }
            stretching: !opened
            width: 120
            height: 40
            Item {
                anchors.fill: parent
                CFClippingRect {
                    anchors.fill: parent
                    radius: 30
                    CFVI {
                        x: sessionText.x-5
                        y: sessionText.y+4
                        size: 15
                        color: "#a0ffffff"
                        icon: "notch/layers.svg"
                        opacity: sessionModal.opened ? 0 : 1
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            blurEnabled: true
                            blur: 1
                            blurMax: sessionModal.opened ? 16 : 0
                            Behavior on blur { NumberAnimation { duration: 180 } }
                        }
                    }
                    CFText {
                        id: sessionText
                        anchors.centerIn: parent
                        text: "    Session"
                        font.bold: true
                        color: "white"
                        font.pointSize: 14
                        opacity: sessionModal.opened ? 0 : 1
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            blurEnabled: true
                            blur: 1
                            blurMax: sessionModal.opened ? 16 : 0
                            Behavior on blur { NumberAnimation { duration: 180 } }
                        }
                    }
                    ListView {
                        id: sessionList
                        anchors.fill: parent
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10
                        model: sessionProc.sessionList
                        spacing: 8
                        clip: true
                        visible: opacity !== 0
                        opacity: sessionModal.opened ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            blurEnabled: true
                            blur: 1
                            blurMax: sessionModal.opened ? 0 : 16
                            Behavior on blur { NumberAnimation { duration: 180 } }
                        }
                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            width: parent.width
                            height: 20
                            color: "transparent"
                            radius: 10
                            Text {
                                anchors.centerIn: parent
                                function titleCase(s) {
                                    return s.toLowerCase()
                                        .split(' ')
                                        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
                                        .join(' ');
                                }
                                text: titleCase(modelData.replace(/-/g, " ").replace(/_/g, " "))
                                color: "white"
                                font.bold: sessionProc.sessionIndex == index
                                font.pointSize: 12
                                Component.onCompleted: {
                                    sessionModal.longestItem = Math.max(sessionModal.longestItem, width+40)
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                enabled: sessionModal.opened
                                onClicked: {
                                    sessionProc.sessionIndex = index
                                    sessionModal.opened = false
                                }
                            }
                        }
                    }
                }
            }
            onClicked: {
                sessionModal.opened = !sessionModal.opened
            }
        }
        //UIButton {
        //    id: sessionButton
        //    anchors {
        //        right: parent.right
        //        rightMargin: 20
        //        bottom: parent.bottom
        //        bottomMargin: 20
        //    }
        //    width: 100
        //    text: root.currentSession
        //}
    }

    /* ---------------- Greetd Handling ---------------- */

    Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired) {
            if (responseRequired) {
                Greetd.respond(root.passwordBuffer)
                root.passwordBuffer = ""
            }
        }

        function onReadyToLaunch() {
            Greetd.launch([root.currentSession])
        }
    }
}
