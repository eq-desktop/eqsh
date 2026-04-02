pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs

Singleton {
    id: root
    property list<var> history: []
    readonly property var preparedHistory: history.map(a => ({
        name: Fuzzy.prepare(a.data),
        entry: a
    }))
    function fuzzyQuery(search: string): var {
        if (search.trim() === "") {
            return preparedHistory;
        }
        const fuzzyRes = Fuzzy.go(search, preparedHistory, {
            all: true,
            key: "name"
        })
        console.info(fuzzyRes.map(res => res.obj.entry))
        return fuzzyRes.map(res => res.obj.entry)
    }

    function init() {}

    function copy(index) {
        const entry = root.history[index]
        Quickshell.clipboardText = entry.data
    }

    function paste(entry) {
        Quickshell.execDetached(["bash", "-c", `printf '${String(entry).replace(/'/g, "'\\''")}' | ${root.cliphistBinary} decode | wl-copy && wl-paste`]);
    }

    function clear() {
        root.history = []
    }

    function exist(hash) {
        return root.history.some(entry => entry.hash === hash)
    }

    Component {
        id: entryInternal
        QtObject {
            required property int index
            required property string hash
            required property date date
            required property string type
            required property size dimensions
            required property string data
            required property string b64
            required property string path
        }
    }

    Process {
        id: readProc
        running: true
        command: [
            "bash",
            "-c",
            "wl-paste --watch bash -c '\
                type=$(wl-paste --list-types | head -n 1);\
                ts=$(date -Iseconds);\
                if [[ \"$type\" == image/* ]]; then\
                    tmpfile=$(mktemp);\
                    wl-paste --type \"$type\" > \"$tmpfile\";\
                    dims=$(identify -format \"%wx%h\" \"$tmpfile\" 2>/dev/null);\
                    [ -z \"$dims\" ] && dims=\"unknown\";\
                    hash=$(sha256sum \"$tmpfile\" | awk \"{print \\$1}\");\
                    printf \"%s %s Image %s %s %s\\n\" \"$hash\" \"$ts\" \"$dims\" \"$tmpfile\";\
                else\
                    data=$(wl-paste 2>/dev/null);\
                    [ -z \"$data\" ] && exit 0;\
                    encoded=$(printf \"%s\" \"$data\" | base64 -w 0);\
                    hash=$(printf \"%s\" \"$encoded\" | sha256sum | awk \"{print \\$1}\");\
                    printf \"%s %s Text %s\\n\" \"$hash\" \"$ts\" \"$encoded\";\
                fi\
            '"
        ]

        stdout: SplitParser {
            onRead: (line) => {
                const parts = line.split(" ").filter(part => part.trim() !== "")
                let entry
                let hash = parts[0]
                let ts = parts[1]
                let type = parts[2]
                let dims = ""
                let payload = ""
                console.info(parts)

                if (type === "Image") {
                    dims = parts[3]
                    payload = parts[4] // this is now the file path
                } else {
                    payload = parts[3] // base64 text stays the same
                }
                // check hash
                if (root.history.some(entry => entry.hash === hash)) {
                    Logger.d("ClipboardService", "Duplicate clipboard entry: " + hash)
                    // update date
                    const existingEntry = root.history.find(entry => entry.hash === hash)
                    if (existingEntry) {
                        existingEntry.date = new Date(ts)
                    }
                    return
                }
                console.info("New clipboard entry:", hash, ts, type, dims)

                // convert to types
                entry = entryInternal.createObject(root, {
                    index: root.history.length,
                    hash: hash,
                    date: new Date(ts),
                    type: type,
                    dimensions: dims ? Qt.size(parseInt(dims.split("x")[0]), parseInt(dims.split("x")[1])) : Qt.size(0, 0),
                    path: type === "Image" ? payload : "",
                    b64: type === "Text" ? payload : "",
                    data: type === "Text" ? Qt.atob(payload) : ""
                })
                root.history.push(entry)
            }
        }

        onExited: (exitCode, exitStatus) => {
            Logger.d("ClipboardService", "Exited: " + exitCode)
        }
    }
}