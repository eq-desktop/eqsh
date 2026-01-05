import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.UPower
import qs
import qs.config
import qs.ui.controls.windows
import qs.ui.controls.auxiliary
import qs.ui.controls.primitives
import qs.ui.controls.providers
import qs.ui.controls.advanced

import "root:/agents/ai.js" as AIAgent

Scope {
    id: root
    property var agent: AIAgent
    property var statusbar: null

    property string location: "--"
    property string temperature: "--"
    property string description: "--"
    property string hlVal: "--"

    Process {
        id: weatherProc
        command: ["sh", "-c", `curl -s wttr.in/${Config.widgets.location}?format=j1 | jq '{location: .nearest_area[0].areaName[0].value, temperature: .current_condition[0].temp_${Config.widgets.tempUnit}, feelsLikeTemp: .current_condition[0].FeelsLike${Config.widgets.tempUnit}, description: .current_condition[0].weatherDesc[0].value, highTemp: .weather[0].maxtemp${Config.widgets.tempUnit}, lowTemp: .weather[0].mintemp${Config.widgets.tempUnit}}'`]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const text = this.text;
                const json = JSON.parse(text);
                root.location = Config.widgets.useLocationInUI ? Config.widgets.location : json.location;
                root.temperature = json.temperature;
                root.description = json.description;
                root.hlVal = "H: " + json.highTemp + "°" + Config.widgets.tempUnit + ", L: " + json.lowTemp + "°" + Config.widgets.tempUnit;
            }
        }
        stderr: StdioCollector {
            onStreamFinished: if (text != "") Logger.e("AI", "weather fetch error:", text);
        }
    }

    FileView {
        id: sigridPrompt
        path: Config.sigrid.systemPromptLocation
        blockLoading: true
    }

    function toggle() {
        Runtime.aiOpen = !Runtime.aiOpen;
    }
    IpcHandler {
        target: "sigrid"
        function toggle() {
            root.toggle();
        }
    }
    CustomShortcut {
        name: "sigrid"
        description: "Toggle Sigrid"
        onPressed: {
            root.toggle();
        }
    }
    FollowingPanelWindow {
        id: panelWindow
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "eqsh:lock-blur"
        anchors {
            top: true
            right: true
            bottom: true
        }
        focusable: true
        exclusiveZone: -1
        color: "transparent"
        implicitWidth: 400
        margins {
            top: Config.bar.height
        }
        mask: Region {
            item: Runtime.aiOpen ? contentItem : null
        }
        visible: true
        property string state: "ask" // ask, answer, error
        property bool showing: Runtime.aiOpen
        property bool visibleC: false
        property list<var> answers: []
        onShowingChanged: {
            if (showing) {
                showAIAnim.start()
                hideAIAnim.stop()
                grab.active = true
            } else {
                hideAIAnim.start()
                showAIAnim.stop()
                grab.active = false
            }
        }

        PropertyAnimation {
            id: showAIAnim
            target: contentItem
            properties: "anchors.topMargin"
            from: -10
            to: 10
            duration: 500
            easing.type: Easing.OutBack
            easing.overshoot: 0.5
            onStarted: {
                panelWindow.visibleC = true
                contentItem.opacity = 1
                contentItem.scale = 1
            }
        }

        PropertyAnimation {
            id: hideAIAnim
            target: contentItem
            properties: "anchors.topMargin"
            from: 10
            to: -10
            duration: 500
            easing.type: Easing.OutBack
            easing.overshoot: 2
            onStarted: {
                contentItem.opacity = 0
                contentItem.scale = 0.9
            }
            onFinished: {
                panelWindow.visibleC = false
            }
        }

        HyprlandFocusGrab {
            id: grab
            windows: [ panelWindow, statusbar ]
            onCleared: {
                Runtime.aiOpen = false
            }
        }

        Item {
            id: contentItem
            anchors {
                top: parent.top
                right: parent.right
                rightMargin: 10
                topMargin: -10
                bottom: parent.bottom
            }
            scale: 0.9
            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
            onScaleChanged: {
                panelWindow.mask.changed();
            }
            opacity: 0
            visible: panelWindow.visibleC
            width: 300
            BoxGlass {
                id: input
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                    margins: 10
                }
                z: 3
                width: 300
                height: 40
                property real siconScale: 1
                property real xOffset: 0
                property bool error: false
                property bool loading: false
                transform: Translate { x: input.xOffset }
                TextField {
                    id: inputText
                    anchors.fill: parent
                    focus: Runtime.aiOpen
                    color: "#fff"
                    selectionColor: '#50ffffff'
                    selectedTextColor: '#a0ffffff'
                    leftPadding: 38
                    CFI {
                        id: sicon
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        size: 34
                        scale: input.siconScale
                        sourceSize: Qt.size(128, 128)
                        opacity: 1
                        colorized: false
                        icon: "ai.png"
                    }
                    background: CFText {
                        anchors.fill: parent
                        anchors.leftMargin: 38
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        color: input.error ? "#ff5f5f" : '#fff'
                        font.weight: 500
                        opacity: inputText.text == "" ? 1 : 0
                        text: input.loading ? Translation.tr("Sigrid is thinking…") : input.error ? Translation.tr("Error: Please try again later…") : Translation.tr("Ask Sigrid…")
                    }
                    renderType: Text.NativeRendering
                    font.family: Fonts.sFProDisplayRegular.family
                    font.pixelSize: 16
                    property var additional: (`
                    Name of user: ${Config.account.name}
                    deviceName: ${Config.account.deviceName}
                    darkMode: ${Config.general.darkMode}
                    language: ${Config.general.language}
                    apps in dock: ${Config.dock.apps.join(", ")}
                    Current time: ${Time.time}
                    Location: ${Config.widgets.location}
                    Temperature: ${Config.widgets.temperature}
                    Temperature high/low: ${Config.widgets.hlVal}
                    Battery percentage: ${(UPower.displayDevice.isLaptopBattery ? UPower.displayDevice.percentage : 1)*100}
                    Battery powered: ${UPower.onBattery}
                    Eqsh Version: ${Config.version} / ${Config.versionPretty}
                    `)
                    onAccepted: {
                        Logger.d("AI", "Request AI answer to: " + inputText.text)
                        acceptAnim.start()
                        loadingAnim2.start()
                        input.error = false
                        input.loading = true
                        panelWindow.answers.push(["user", inputText.text])
                        agent.call(inputText.text, Config.sigrid.key, Config.sigrid.model, {systemPrompt: sigridPrompt.text(), previousMessages: panelWindow.answers.map(function(a) { return {role: a[0], content: a[1]} })}, function(success, response) {
                            input.loading = false
                            loadingAnim2.stop()
                            input.siconScale = 1
                            Runtime.aiOpen = true
                            if (success) {
                                panelWindow.state = "answer"
                                // check if it can be parsed as json
                                try {
                                    let result = JSON.parse(response.candidates[0].content.parts[0].text)
                                    if (result) {
                                        switch (result.action) {
                                            case "run_command":
                                                Logger.d("AI", "Request to run command: " + result.command);
                                                result.command = result.command.replace(/"/g, '\\"').replace(/'/g, "\\'")
                                                panelWindow.answers.push(["sigrid", "<font color='#ff5f5f'>" + "Sigrid Action:" + "</font> " + result.command])
                                                Runtime.run("modal", {
                                                    appName: "Sigrid",
                                                    title: Translation.tr("Let Sigrid Run A Command?"),
                                                    description: result.command,
                                                    actions: [
                                                        [
                                                            {
                                                                type: "button",
                                                                label: Translation.tr("Okay"),
                                                                primary: true,
                                                                command: result.command
                                                            }
                                                        ],
                                                        [
                                                            {
                                                                type: "button",
                                                                label: Translation.tr("Cancel"),
                                                                primary: false
                                                            }
                                                        ]
                                                    ],
                                                    iconPath: "",
                                                    useIcon: false
                                                })
                                                break;
                                            case "lock_screen":
                                                Logger.d("AI", "Locking screen per Sigrid request")
                                                panelWindow.answers.push(["sigrid", "<font color='#ff5f5f'>" + "Sigrid Action:" + "</font> " + "Lock Screen"])
                                                Runtime.run("lockscreen")
                                            case "open_settings":
                                                Logger.d("AI", "Opening Settings per Sigrid request")
                                                panelWindow.answers.push(["sigrid", "<font color='#ff5f5f'>" + "Sigrid Action:" + "</font> " + "Open Settings"])
                                                Runtime.settingsOpen = true
                                                break;
                                            default:
                                                Logger.e("AI", "Unknown action: " + result.action)
                                        }

                                    }
                                } catch (e) {
                                    Logger.d("AI", "Response: " + response.candidates[0].content.parts[0].text)
                                    panelWindow.answers.push(["sigrid", response.candidates[0].content.parts[0].text])
                                }
                            } else {
                                Logger.e("AI", "Error getting AI response")
                                panelWindow.state = "error"
                                wiggleAnim.start()
                                input.error = true
                            }
                        }, additional, Logger)
                        inputText.text = ""
                    }
                }
                SequentialAnimation {
                    id: wiggleAnim
                    running: false
                    loops: 1
                    PropertyAnimation { target: input; property: "xOffset"; to: input.x - 10; duration: 100; easing.type: Easing.InOutQuad }
                    PropertyAnimation { target: input; property: "xOffset"; to: input.x + 10; duration: 100; easing.type: Easing.InOutQuad }
                    PropertyAnimation { target: input; property: "xOffset"; to: input.x - 7; duration: 100; easing.type: Easing.InOutQuad }
                    PropertyAnimation { target: input; property: "xOffset"; to: input.x + 7; duration: 100; easing.type: Easing.InOutQuad }
                    PropertyAnimation { target: input; property: "xOffset"; to: input.x; duration: 100; easing.type: Easing.InOutQuad }
                }
                SequentialAnimation {
                    id: acceptAnim
                    running: false
                    PropertyAnimation {
                        target: input
                        property: "scale"
                        to: 1.02
                        duration: 75
                        easing.type: Easing.OutBack
                        easing.overshoot: 2
                    }
                    PropertyAnimation {
                        target: input
                        property: "scale"
                        to: 1
                        duration: 75
                        easing.type: Easing.OutBack
                        easing.overshoot: 2
                    }
                }
                SequentialAnimation {
                    id: loadingAnim2
                    running: false
                    loops: -1
                    PropertyAnimation {
                        target: input
                        property: "siconScale"
                        to: 1.1
                        duration: 500
                        easing.type: Easing.OutBack
                        easing.overshoot: 2
                    }
                    PropertyAnimation {
                        target: input
                        property: "siconScale"
                        to: 1
                        duration: 1000
                        easing.type: Easing.OutBack
                        easing.overshoot: 2
                    }
                }
            }
            ListView {
                id: answers
                anchors {
                    top: input.bottom
                    topMargin: 10
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
                width: 300
                spacing: 10
                model: ScriptModel {
                    values: panelWindow.answers
                }
                add: Transition {
                    NumberAnimation { properties: "scale"; from: 0; to: 1; duration: 300; easing.type: Easing.OutBack; easing.overshoot: 2 }
                    NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: 300; easing.type: Easing.OutBack; easing.overshoot: 2 }
                }
                remove: Transition {
                    NumberAnimation { properties: "scale"; from: 1; to: 0; duration: 300; easing.type: Easing.OutBack; easing.overshoot: 2 }
                    NumberAnimation { properties: "opacity"; from: 1; to: 0; duration: 300; easing.type: Easing.OutBack; easing.overshoot: 2 }
                }
                header: Item {
                    height: 40
                    width: 300
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            panelWindow.answers.splice(0, panelWindow.answers.length)
                        }
                        BoxGlass {
                            id: header
                            color: '#10ffffff'
                            light: '#50ffffff'
                            z: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: 10
                            width: clearBtnText.implicitWidth + 20
                            height: 30
                            scale: 1
                            opacity: 1
                            Text {
                                id: clearBtnText
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                color: "#fff"
                                text: Translation.tr("Clear")
                                font.family: Fonts.sFProDisplayBlack.family
                            }
                        }
                    }
                }
                headerPositioning: ListView.PullBackHeader
                delegate: BoxGlass {
                    id: output
                    required property var modelData
                    required property var index
                    color: '#20ffffff'
                    light: '#50ffffff'
                    rimStrength: 0.2
                    lightDir: Qt.point(1, -0.05)
                    z: 1
                    width: 300
                    radius: 20
                    property string text: modelData[0] == "user" ? "<font color=\"#aaa\">You: </font>" + modelData[1] : modelData[1]
                    opacity: 1
                    height: content.height + 20
                    scale: 1

                    MouseArea {
                        id: mousearea
                        anchors.fill: parent
                        hoverEnabled: true
                        ScrollView {
                            id: content
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 10
                            }
                            contentWidth: 280
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                            height: Math.min(500, textO.implicitHeight)
                            TextEdit {
                                id: textO
                                renderType: Text.NativeRendering
                                font.family: Fonts.sFProDisplayBlack.family
                                text: output.text
                                color: "#fff"
                                selectionColor: "#555"
                                wrapMode: Text.Wrap
                                readOnly: true
                                width: 280
                                textFormat: TextEdit.MarkdownText
                            }
                        }
                    }

                    BoxGlass {
                        anchors {
                            top: parent.top
                            right: parent.right
                            margins: 10.5
                        }
                        width: 15
                        height: 15
                        radius: 7.5
                        color: "#20ffffff"
                        scale: mousearea.containsMouse ? 1 : 0
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
                        CFVI {
                            anchors.centerIn: parent
                            size: 10
                            opacity: 1
                            icon: "x.svg"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                panelWindow.answers.splice(output.index, 1)
                            }
                        }
                    }
                }
            }
        }
    }
}