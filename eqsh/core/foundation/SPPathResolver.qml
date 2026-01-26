pragma Singleton

import Quickshell
import Qt.labs.platform

Singleton {
    id: root

    readonly property url home: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
    readonly property url pictures: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]

    readonly property url config: `${StandardPaths.standardLocations(StandardPaths.GenericConfigLocation)[0]}/eqsh`

    function stringify(path: url): string {
        return path.toString().replace(/%20/g, " ");
    }

    function expandTilde(path: string): string {
        return strip(path.replace("~", stringify(root.home)));
    }

    function shortenHome(path: string): string {
        return path.replace(strip(root.home), "~");
    }

    function strip(path: url): string {
        return stringify(path).replace("file://", "");
    }

    function mkdir(path: url): void {
        Quickshell.execDetached(["mkdir", "-p", strip(path)]);
    }

    function copy(from: url, to: url): void {
        Quickshell.execDetached(["cp", strip(from), strip(to)]);
    }

    function move(from: url, to: url): void {
        Quickshell.execDetached(["mv", strip(from), strip(to)]);
    }

    function rename(path: url, newName: string): void {
        path = strip(path);
        let dir = path.slice(0, path.lastIndexOf("/"));
        let oldName = path.slice(path.lastIndexOf("/") + 1);
        let newPath = `${dir}/${newName}`;
        move(path, newPath);
    }

    function getName(path: url): string {
        path = strip(path);
        return path.slice(path.lastIndexOf("/") + 1);
    }
}