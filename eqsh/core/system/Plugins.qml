pragma Singleton
pragma ComponentBehavior: Bound

import qs
import qs.config
import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import "root:/agents/kavo/main.js" as BePlugin
import "root:/agents/kavo/kvoNode.js" as KvoNode

Singleton {
    id: plugins

    property var loadedPlugins: []
    property var widgetRegistry: ({})
    property bool loaded: false

    function init() {
        Logger.i("Plugins", "Initializing plugin manager");
    }

    function reloadPlugins() {
        Logger.i("Plugins", "Reloading plugins");
        loadedPlugins = []
        widgetRegistry = ({})
        loaded = false
        pluginInstantiator.model = []
        pluginInstantiator.model = pluginModel
    }

    function loadPlugin(pluginPath, files, index) {
        if (files == null) {
            Logger.e("Plugins", "Plugin files not found:", pluginPath)
            return
        }
        if (!(pluginPath+"/plugin.kvo" in files)) {
            Logger.e("Plugins", "Plugin file not found:", pluginPath+"/plugin.kvo")
            return
        }
        let pluginKavo = files[pluginPath+"/plugin.kvo"];
        let parsed = BePlugin.parse(pluginKavo)
        let kavo = new KvoNode.KvoNode(parsed);
        // load plugin
        let plugin = kavo.nav("plugin");
        let id = Object.keys(plugin.properties)[0];
        let meta = plugin.f("meta");
        // load file imports
        let imports = plugin.fK("import");
        for (let i = 0; i < imports.length; i++) {
            let importNode = imports[i];
            let importPath = importNode.value;
            if (importPath.startsWith("/")) {}
            else if (importPath.startsWith("./")) {
                // remove ./ from path
                importPath = importPath.substring(2);
                // append plugin path
                importPath = pluginPath + "/" + importPath;
            }
            else {
                // append plugin path
                importPath = pluginPath + "/" + importPath;
            }
            Logger.d("Plugins", "For", id, "importing", importPath);
            // Load file
            if (!(importPath in files)) {
                Logger.e("Plugins", "Unable to import file:", importPath, "Plugin:", id);
                return
            }
            let importNavPath = importNode.pathParent();
            let importKavo = files[importPath];
            let importParsed = BePlugin.parse(importKavo)
            for (let i = 0; i < importParsed.children.length; i++) {
                let child = importParsed.children[i];
                kavo.nav(importNavPath).addChild(child);
            }
            // remove import node
            kavo.nav(importNavPath).removeChild(importNode.id);
        }
        Logger.i("Plugins", "Loading plugin:", meta.f("name").value);
        Logger.d("Plugins", "Plugin Loaded from:", pluginPath, "ID:", id);
        let pluginWidgets = plugin.fA("widget")
        for (let i = 0; i < pluginWidgets.length; i++) {
            let widget = pluginWidgets[i];
            let widgetMeta = widget.f("meta");
            let widgetId = widgetMeta.f("id").value;
            Logger.d("Plugins", "Plugin: " + id + " Loading widget:", widgetMeta.f("name").value, "ID:", id + ":" + widgetId);
            plugins.widgetRegistry[id + ":" + widgetId] = widget
        }

        Logger.d("Plugins", "Finished loading plugin:", id);
        Logger.d("Plugins", "Layout: ", kavo.print());

        // finish
        let finishedPlugin = {
            path: pluginPath,
            kavo: kavo
        }
        loadedPlugins.push(finishedPlugin);
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
        id: pluginInstantiator
        model: pluginModel
        delegate: QtObject {
            id: pluginItem
            required property string fileURL
            required property int index
            property int filesLoaded: 0
            property bool filesDone: false
            property var files: ({})
            property var pluginContentModel: FolderListModel {
                folder: Qt.resolvedUrl(pluginItem.fileURL)
                showFiles: true
                showDirs: false
                property var instantiator: Instantiator {
                    id: pluginContentInstantiator
                    model: pluginContentModel
                    delegate: QtObject {
                        id: pluginContentItem
                        required property string fileURL
                        required property int index
                        property bool filesDone: pluginContentKavo.loaded
                        property var pluginContentKavo: FileView {
                            id: pluginContentKavo
                            path: fileURL
                            blockLoading: true
                        }
                        onFilesDoneChanged: {
                            if (pluginContentItem.filesDone) {
                                pluginItem.filesLoaded += 1;
                                pluginItem.files[fileURL] = pluginContentKavo.text();
                                pluginItem.filesDone = pluginItem.filesLoaded == pluginContentModel.count;
                            }
                        }
                    }
                }
            }
            onFilesDoneChanged: {
                if (filesDone) {
                    loadPlugin(fileURL, pluginItem.files, index)
                }
            }
        }
    }
}