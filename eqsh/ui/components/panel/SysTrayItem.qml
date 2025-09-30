
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.config
import Qt.labs.folderlistmodel

MouseArea {
    id: root

    property var bar: root.QsWindow.window
    required property SystemTrayItem item
    property bool targetMenuOpen: false
    property int trayItemWidth: 24

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    implicitHeight: 24
    implicitWidth: trayItemWidth
    onClicked: (event) => {
        switch (event.button) {
        case Qt.LeftButton:
            item.activate();
            break;
        case Qt.RightButton:
            if (item.hasMenu) menu.showAt(root, width / 2, height);
            break;
        }
        event.accepted = true;
    }

    TrayMenu {
        id: menu
        anchorItem: trayIcon
        menu: root.item.menu
    }

    function setupIcon(icon_path) {
        if (icon_path.indexOf("=") !== -1) {
            icon_path = icon_path.split("=")[1];
        }

        let isImage =
            icon_path.endsWith(".png") ||
            icon_path.endsWith(".svg") ||
            icon_path.endsWith(".ico") ||
            icon_path.endsWith(".jpg") ||
            icon_path.endsWith(".jpeg");

        if (!isImage && !icon_path.startsWith("image://")) {
            findImageRecursiveAsync(icon_path, function(found) {
                trayIcon.source = "file://" + found;
            });
        }

        return icon_path;
    }

    function findImageRecursiveAsync(basePath, callback) {
        const exts = [".png", ".svg", ".ico", ".jpg", ".jpeg"];
        let folderUrl = "file://" + basePath;

        let dir = Qt.createQmlObject(
            'import Qt.labs.folderlistmodel; FolderListModel { folder: "' + folderUrl + '"; nameFilters: ["*.*"]; showDirs: true; }',
            root
        );

        dir.onStatusChanged.connect(function() {
            if (dir.status === FolderListModel.Ready) {
                for (let i = 0; i < dir.count; i++) {
                    let filePath = dir.get(i, "filePath");
                    if (dir.isFolder(i)) {
                        findImageRecursiveAsync(filePath, callback); // search deeper
                    } else {
                        let lower = filePath.toLowerCase();
                        if (exts.some(ext => lower.endsWith(ext))) {
                            callback(filePath); // stop as soon as we find one
                            return;
                        }
                    }
                }
            }
        });
    }

    IconImage {
        id: trayIcon
        implicitHeight: 24
        implicitWidth: 24
        implicitSize: 24
        source: setupIcon(root.item.icon)
        anchors.fill: parent
        layer.enabled: Config.bar.monochromeTray
        layer.effect: MultiEffect {
            colorization: 1
            colorizationColor: "#fff"
        }
    }
}