import QtQuick
import Quickshell
import qs
import Quickshell.Services.Polkit

Scope {
    id: polkitScope

    Connections {
        target: agent.flow

        function onAuthenticationFailed() {
            agent.fail()
        }
    }

    PolkitAgent {
        id: agent

        property var fail
        property var success
        onIsActiveChanged: {
            if (!agent.isActive && agent.success != null) {
                agent.success()
            }
        }
        onAuthenticationRequestStarted: () => {
            console.log("Auth request started")
            Runtime.run("modal", {
                appName: "Aureli",
                title: Translation.tr("Authentication Required"),
                description: agent.flow.message,
                iconPath: Quickshell.iconPath(agent.flow.iconName),
                actions: [
                    [
                        {
                            id: "password",
                            type: "input",
                            variable: "password",
                            inputType: "password",
                            callback: (self, variables, inputT) => {
                                agent.flow.submit(variables["password"])
                                inputT.text = ""
                                inputT.placeholderText = Translation.tr("Authenticating...")
                                agent.fail = () => {
                                    inputT.wiggle()
                                    inputT.placeholderText = Translation.tr("Incorrect Password")
                                }
                                agent.success = () => {
                                    self.close()
                                }
                            }
                        },
                        {
                            id: "authenticateButton",
                            type: "button",
                            fillWidth: false,
                            width: 40,
                            iconPath: Quickshell.iconPath("lock-open-symbolic"),
                            label: "",
                            callbackRedirect: "password",
                            primary: true
                        }
                    ],
                    [
                        {
                            type: "button",
                            label: Translation.tr("Deny"),
                            callback: (self, variables) => {
                                if (agent.flow == null) {
                                    self.close()
                                    return
                                }
                                agent.flow.cancelAuthenticationRequest()
                                self.close()
                            },
                            primary: false
                        }
                    ]
                ],//`row:"password.input"="callback:password", row:"Deny"="callback:deny"`,
                iconPath: "",
                useIcon: false
            })
        }
    }
}