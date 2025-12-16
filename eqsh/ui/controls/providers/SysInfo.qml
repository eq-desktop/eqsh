pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: utils
    property string cpuGHz: ""
    property string cpuMaxGHz: ""
    property string cpuCores: ""
    property string cpuName: ""
    property string gpuName: ""
    property string gpuVRam: ""
    property string memory: ""
    property string memoryMHz: ""
    property string memoryDDR: ""

    Process {
        running: true
        command: [ "lscpu", "-eMAXMHZ" ]
        stdout: StdioCollector {
            onStreamFinished: {
                // get first line
                let text = this.text
                let lines = text.split("\n")
                let cpuMHz = lines[1].split(",")[0].trim()
                let cpuGHz = (cpuMHz / 1000).toFixed(1)
                utils.cpuMaxGHz = cpuGHz+" GHz"
            }
        }
    }

    Process {
        running: true
        command: [ "lscpu", "-eCORE" ]
        stdout: StdioCollector {
            onStreamFinished: {
                let text = this.text
                let lines = text.split("\n")
                // remove first line
                lines.shift()
                // for each line get the number and store it
                let cpuCores = []
                let seen = new Set()
                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i]
                    let number = line.split(",")[0].trim()
                    if (number == "") {
                        continue
                    }
                    if (!seen.has(number)) {
                        seen.add(number)
                        cpuCores.push(number)
                    }
                }
                switch (cpuCores.length) {
                    case 0:
                        utils.cpuCores = "N/A"
                        break
                    case 1:
                        utils.cpuCores = "Single-Core"
                        break
                    case 2:
                        utils.cpuCores = "Dual-Core"
                        break
                    case 4:
                        utils.cpuCores = "Quad-Core"
                        break
                    case 6:
                        utils.cpuCores = "Hexa-Core"
                        break
                    case 8:
                        utils.cpuCores = "Octa-Core"
                        break
                    case 10:
                        utils.cpuCores = "Deca-Core"
                        break
                    case 12:
                        utils.cpuCores = "Dodeca-Core"
                        break
                    default:
                        utils.cpuCores = "Dual-Core"
                        break
                }
            }
        }
    }

    Process {
        running: true
        command: [ "lscpu", "-eMODELNAME" ]
        stdout: StdioCollector {
            onStreamFinished: {
                // get first line
                let text = this.text
                let lines = text.split("\n")
                let cpuName = lines[1].split("@")[0].trim()
                let cpuGhz = lines[1].split("@")[1].trim()

                // remove (R) and (TM) from name
                cpuName = cpuName.replace("(R)", "").replace("(TM)", "")
                // remove CPU at the end
                if (cpuName.endsWith("CPU")) {
                    cpuName = cpuName.substring(0, cpuName.length - 3)
                }

                utils.cpuName = cpuName
                utils.cpuGHz = cpuGhz
            }
        }
    }

    Process {
        running: true
        command: [ "sh", "-c", "lspci | grep -iE 'VGA|3D|video'"]
        stdout: StdioCollector {
            onStreamFinished: {
                // get first line
                let text = this.text
                let line = text.split("\n")[0]
                let parts = line.split(":")
                let part = parts[2].substring(0, parts[2].length - 9).trim()
                utils.gpuName = part
            }
        }
    }

    Process {
        running: true
        command: [ "cat", "/proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: {
                let text = this.text
                let lines = text.split("\n")
                // get the line that starts with MemTotal
                let memTotalLine = lines.find(line => line.startsWith("MemTotal:"))
                let memTotal = memTotalLine.split(":")[1].trim().split(" ")[0]
                let memTotalMB = Math.ceil((memTotal / 1024 / 1024))
                utils.memory = memTotalMB + " GB"
            }
        }
    }

    Process {
        running: false // fixme: NOT WORKING because of sudo
        command: [ "sudo", "dmidecode", "--type", "17"]
        stdout: StdioCollector {
            onStreamFinished: {
                let text = this.text
                let lines = text.split("\n")
                // get the line that starts with MemTotal
                let memMhzLine = lines.find(line => line.indexOf("Speed:") !== -1).trim()
                let memTypeLine = lines.find(line => line.indexOf("Type:") !== -1).trim()
                let memMhz = memMhzLine.split(":")[1].trim()
                let memType = memTypeLine.split(":")[1].trim()
                memMhz = memMhz.replace("MT/s", "").trim()
                utils.memoryMHz = memMhz + " MHz"
                utils.memoryDDR = memType
            }
        }
    }
}
