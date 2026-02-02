class KvoNode {
    constructor(obj) {
        this._obj = obj;
    }

    // Access underlying object
    get raw() {
        return this._obj;
    }

    // Get children as KvoNode instances
    get children() {
        return (this._obj.children || []).map(c => new KvoNode(c));
    }

    get id() {
        return this._obj.id;
    }

    get path() {
        return this._obj.path;
    }

    get name() {
        return this._obj.name;
    }

    get kind() {
        return this._obj.kind;
    }

    get type() {
        return this._obj.type;
    }

    get args() {
        return this._obj.args;
    }

    get value() {
        return this._obj.value;
    }

    get properties() {
        return this._obj.properties;
    }

    set children(children) {
        this._obj.children = children;
    }

    set id(id) {
        this._obj.id = id;
    }

    set path(path) {
        this._obj.path = path;
    }

    set name(name) {
        this._obj.name = name;
    }

    set kind(kind) {
        this._obj.kind = kind;
    }

    set type(type) {
        this._obj.type = type;
    }

    set args(args) {
        this._obj.args = args;
    }

    set value(value) {
        this._obj.value = value;
    }

    set properties(properties) {
        this._obj.properties = properties;
    }

    pathTrimmed() {
        // remove first section from path e.g. root.sections -> sections
        return this.path.split(".").slice(1).join(".");
    }

    pathLast() {
        return this.path.split(".").pop();
    }

    pathParent() {
        return this.path.split(".").slice(1, -1).join(".");
    }

    pathChildren() {
        return this.path.split(".").slice(1);
    }

    paths() {
        return this.path.split(".");
    }

    // Find first child by name
    find(name) {
        return this.children.find(c => c.name === name) || null;
    }

    f(name) {
        return this.find(name);
    }

    // Find all children by name
    findAll(name) {
        return this.children.filter(c => c.name === name);
    }

    fA(name) {
        return this.findAll(name);
    }

    // Get property by key (returns undefined if missing)
    prop(key) {
        return this._obj.properties ? this._obj.properties[key] : undefined;
    }

    p(key) {
        return this.prop(key);
    }

    // Filter children by kind ("section", "function", "property")
    filterKind(kind) {
        return this.children.filter(c => c.kind === kind);
    }

    fK(kind) {
        return this.filterKind(kind);
    }

    // Recursively search for a node by name
    search(name) {
        if (this._obj.name === name) return this;
        for (const child of this.children) {
            const found = child.search(name);
            if (found) return found;
        }
        return null;
    }

    s(name) {
        return this.search(name);
    }

    // Pretty-print for debug
    print(indent = 0) {
        let finished = ""
        const pad = " ".repeat(indent * 2);
        finished += `${pad}${this._obj.kind}: ${this._obj.name}\n`;
        if (this._obj.kind === "function") return finished;
        for (const child of this.children) finished += child.print(indent + 1);
        return finished;
    }

    pr() {
        return this.print();
    }

    printNow(indent = 0) {
        const pad = " ".repeat(indent * 2);
        console.log(`${pad}${this._obj.kind}: ${this._obj.name}`);
        if (this._obj.kind === "function") return;
        for (const child of this.children) child.printNow(indent + 1);
    }
    prNow() {
        return this.printNow();
    }
    // Map children to a function
    mapChildren(fn) {
        return this.children.map(fn);
    }

    mC(fn) {
        return this.mapChildren(fn);
    }

    // Check if node has a child of certain name
    hasChild(name) {
        return this.children.some(c => c.name === name);
    }

    hC(name) {
        return this.hasChild(name);
    }

    /**
     * Navigate the tree by a dot-separated path
     * e.g. "sections.toggles.subSection.key"
     * Returns the KvoNode or property value
     */
    navigate(path) {
        if (!path) return this;

        const parts = path.split(".");
        let current = this;

        for (let i = 0; i < parts.length; i++) {
            const part = parts[i];

            // If it's the last part, try property first
            if (i === parts.length - 1) {
                if (current.prop(part) !== undefined) {
                    return current.prop(part); // return property value
                }
            }

            // Move into child section/function with that name
            const next = current.find(part);
            if (!next) return undefined; // not found
            current = next;
        }

        return current;
    }

    // Add child
    addChild(child) {
        if (!this._obj.children) this._obj.children = [];
        this._obj.children.push(child instanceof KvoNode ? child.raw : child);
    }

    // Remove child by id
    removeChild(id) {
        this._obj.children = this._obj.children.filter(c => c.id !== id);
    }

    n(path) {
        return this.navigate(path);
    }

    nav(path) {
        return this.navigate(path);
    }
}