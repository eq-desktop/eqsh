pragma Singleton
pragma ComponentBehavior: Bound

import qs
import qs.config
import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import "root:/agents/plugin.js" as BePlugin

Singleton {
    id: plugins

    property var loadedPlugins: []
    property bool loaded: false

    function init() {
        Logger.i("Plugins", "Initializing plugin manager");
    }

    function loadPlugin(pluginPath, pluginManifest, pluginMain, pluginQml, index) {
        let manifest = BePlugin.decodePluginManifest(pluginManifest.text());
        Logger.i("Plugins", "Loading plugin:", manifest.name);
        Logger.d("Plugins", "Plugin Loaded from:", pluginPath, "ID:", manifest.id);
        let plugin = {
            path: pluginPath,
            main: pluginMain.text(),
            qml: pluginQml.text(),
            manifest: manifest
        }
        loadedPlugins.push(plugin);
        if (index == pluginModel.count - 1) {
            // Last plugin loaded
            plugins.loaded = true;
        }
    }

    // Plugins
    FolderListModel {
        id: pluginModel
        folder: Qt.resolvedUrl(Directories.pluginsPath)
        showFiles: false
        showDirs: true
    }

    Instantiator {
        model: pluginModel
        delegate: QtObject {
            id: pluginItem
            required property string fileURL
            required property int index
            property bool filesDone: pluginManifest.loaded && pluginMain.loaded && pluginQml.loaded
            property var pluginManifest: FileView {
                id: pluginManifest
                path: fileURL + "/plugin.eqp"
                blockLoading: true
            }
            property var pluginMain: FileView {
                id: pluginMain
                path: fileURL + "/Main.yml"
                blockLoading: true
            }
            property var pluginQml: FileView {
                id: pluginQml
                path: fileURL + "/content/Main.qml"
                blockLoading: true
            }
            onFilesDoneChanged: {
                if (filesDone) {
                    loadPlugin(fileURL, pluginManifest, pluginMain, pluginQml, index)
                }
            }
        }
    }
}