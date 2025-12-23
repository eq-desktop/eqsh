// https://github.com/caelestia-dots/shell/blob/main/services/Network.qml
// Thanks to Soramanew for creating this

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    /* ===== Public API ===== */

    readonly property list<AccessPoint> networks: []
    readonly property list<AccessPoint> networksKnown: []
    readonly property AccessPoint active: networks.find(n => n.active) ?? null
    property bool wifiEnabled: true
    readonly property bool scanning: rescanProc.running

    reloadableId: "network"

    function enableWifi(enabled: bool): void {
        enableWifiProc.exec(["nmcli", "radio", "wifi", enabled ? "on" : "off"])
    }

    function toggleWifi(): void {
        enableWifiProc.exec(["nmcli", "radio", "wifi", wifiEnabled ? "off" : "on"])
    }

    function rescanWifi(): void {
        rescanProc.running = true
    }

    function connectToNetwork(ssid: string, password: string): void {
        // password handled by NM if profile exists
        connectProc.exec(["nmcli", "conn", "up", ssid])
    }

    function disconnectFromNetwork(): void {
        if (active)
            disconnectProc.exec(["nmcli", "connection", "down", active.ssid])
    }

    function getWifiStatus(): void {
        wifiStatusProc.running = true
    }

    /* ===== Startup trigger ===== */

    Process {
        running: true
        command: ["nmcli", "m"]
        stdout: SplitParser {
            onRead: {
                getNetworks.running = true
                getKnownNetworks.running = true
            }
        }
    }

    /* ===== Wi-Fi status ===== */

    Process {
        id: wifiStatusProc
        running: true
        command: ["nmcli", "radio", "wifi"]
        environment: ({ LANG: "C", LC_ALL: "C" })
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = text.trim() === "enabled"
            }
        }
    }

    Process {
        id: enableWifiProc
        onExited: {
            root.getWifiStatus()
            getNetworks.running = true
            getKnownNetworks.running = true
        }
    }

    /* ===== Scan ===== */

    Process {
        id: rescanProc
        command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
        onExited: getNetworks.running = true
    }

    /* ===== Connect / Disconnect ===== */

    Process {
        id: connectProc
        stdout: SplitParser {
            onRead: {
                getNetworks.running = true
                getKnownNetworks.running = true
            }
        }
        stderr: StdioCollector {
            onStreamFinished: console.warn("Network connection error:", text)
        }
    }

    Process {
        id: disconnectProc
        stdout: SplitParser {
            onRead: {
                getNetworks.running = true
                getKnownNetworks.running = true
            }
        }
    }

    /* ===== Visible Wi-Fi networks ===== */

    Process {
        id: getNetworks
        running: true
        command: ["nmcli", "-g", "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY", "d", "w"]
        environment: ({ LANG: "C", LC_ALL: "C" })

        stdout: StdioCollector {
            onStreamFinished: {
                const PLACEHOLDER = "STRINGWHICHHOPEFULLYWONTBEUSED"
                const rep = /\\:/g
                const rep2 = new RegExp(PLACEHOLDER, "g")

                const allNetworks = text.trim().split("\n").map(n => {
                    const net = n.replace(rep, PLACEHOLDER).split(":")
                    return {
                        active: net[0] === "yes",
                        strength: parseInt(net[1]),
                        frequency: parseInt(net[2]),
                        ssid: net[3],
                        bssid: net[4]?.replace(rep2, ":") ?? "",
                        security: net[5] || ""
                    }
                }).filter(n => n.ssid)

                // Group by SSID
                const map = new Map()
                for (const n of allNetworks) {
                    const e = map.get(n.ssid)
                    if (!e || (n.active && !e.active) || (!e.active && n.strength > e.strength))
                        map.set(n.ssid, n)
                }

                const next = Array.from(map.values())
                const current = root.networks

                // Remove stale
                for (const c of current.filter(r =>
                    !next.find(n => n.ssid === r.ssid && n.bssid === r.bssid && n.frequency === r.frequency)
                )) {
                    current.splice(current.indexOf(c), 1).forEach(o => o.destroy())
                }

                // Add / update
                for (const n of next) {
                    const m = current.find(r =>
                        r.ssid === n.ssid && r.bssid === n.bssid && r.frequency === n.frequency
                    )
                    if (m) {
                        m.lastIpcObject = n
                    } else {
                        current.push(apComp.createObject(root, { lastIpcObject: n }))
                    }
                }
            }
        }

        onExited: {
            getKnownNetworks.running = true
        }
    }

    /* ===== Known (saved) Wi-Fi networks ===== */

    Process {
        id: getKnownNetworks
        running: false
        command: ["nmcli", "-g", "NAME,TYPE", "connection", "show"]
        environment: ({ LANG: "C", LC_ALL: "C" })

        stdout: StdioCollector {
            onStreamFinished: {
                const known = text.trim().split("\n")
                    .map(l => l.split(":"))
                    .filter(p => p.length >= 2 && (p[1]).includes("wireless"))
                    .map(p => p[0])
                    .filter(Boolean)

                // get AccessPoint from networks by ssid from known and put into networksKnown
                const rKnown = root.networksKnown
                rKnown.splice(0, rKnown.length, ...root.networks.filter(n => known.includes(n.ssid)))
            }
        }
    }

    /* ===== Types ===== */

    component AccessPoint: QtObject {
        required property var lastIpcObject
        readonly property string ssid: lastIpcObject.ssid
        readonly property string bssid: lastIpcObject.bssid
        readonly property int strength: lastIpcObject.strength
        readonly property int frequency: lastIpcObject.frequency
        readonly property bool active: lastIpcObject.active
        readonly property string security: lastIpcObject.security
        readonly property bool isSecure: security.length > 0
        readonly property bool isKnown: root.networksKnown.includes(ssid)
    }

    Component {
        id: apComp
        AccessPoint {}
    }
}
