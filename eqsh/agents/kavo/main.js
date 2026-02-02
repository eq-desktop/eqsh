let UUID = 0;

function newPart({
    name = "",
    kind = "object",
    type = "KavoObject",
    children = [],
    path = "",
    id = null,
    args = [],
    value = null,
    properties = {}
} = {}) {
    if (!id) id = UUID++;
    return { name, kind, type, id, arguments: args, path, value, properties, children };
}

function stripComments(src) {
    return src
        .replace(/\/\/.*$/gm, "")
        .replace(/\/\*[\s\S]*?\*\//g, "");
}

function normalizeIndent(block) {
    const lines = block.split("\n");

    // Remove leading/trailing empty lines
    while (lines.length && lines[0].trim() === "") lines.shift();
    while (lines.length && lines[lines.length - 1].trim() === "") lines.pop();

    // Find smallest indentation (ignore empty lines)
    let minIndent = Infinity;

    for (const line of lines) {
        if (!line.trim()) continue;
        const match = line.match(/^(\s+)/);
        if (match) {
            minIndent = Math.min(minIndent, match[1].length);
        } else {
            minIndent = 0;
            break;
        }
    }

    if (!isFinite(minIndent)) minIndent = 0;

    // Remove that indent
    return lines
        .map(line => line.startsWith(" ".repeat(minIndent)) ? line.slice(minIndent) : line)
        .join("\n");
}

function scanBlock(lines, startIndex) {
    let state = { inString: false, escape: false, depth: 1 };
    let body = [];
    let i = startIndex;

    for (; i < lines.length; i++) {
        const line = lines[i];
        for (let c of line) {
            if (state.escape) { state.escape = false; continue; }
            if (c === "\\") { state.escape = true; continue; }
            if (c === '"') { state.inString = !state.inString; continue; }
            if (!state.inString) {
                if (c === "{") state.depth++;
                if (c === "}") state.depth--;
            }
        }

        if (state.depth === 0) break;
        body.push(line);
    }

    return { body: body.join("\n"), endIndex: i };
}

function parseValue(raw) {
    raw = raw.trim();
    if (/^".*"$/.test(raw)) return { type: "string", value: raw.slice(1, -1) };
    if (!isNaN(raw)) return { type: "number", value: Number(raw) };
    if (raw === "true" || raw === "false") return { type: "boolean", value: raw === "true" };
    return { type: "string", value: raw };
}

/* ------------------------------- PARSER ------------------------------- */

function parse(data, parent = null) {
    data = stripComments(data);
    const lines = data.split("\n");
    const root = parent || newPart({ name: "root", path: "root" });

    for (let i = 0; i < lines.length; i++) {
        let line = lines[i].trim();
        if (!line) continue;

        if (line.startsWith("@import ")) {
            // detect inline mode if needed
            const inlineMode = line.startsWith("@import nonfinal ");
            const filePath = line.split(/import(?: nonfinal)?\s+/)[1].replace(/["']/g, "").trim();

            let newNode = newPart({
                name: "import:Unkown",
                kind: "import",
                path: `${root.path}.${"import:Unkown"}`,
                type: "KavoImport",
                value: filePath
            });
            newNode.name = "import:" + newNode.id;
            newNode.path = `${root.path}.${newNode.name}`;

            root.children.push(newNode);

            continue;
        }

        /* ---------- FUNCTION ---------- */
        if (/^[\w]+\(.*\)\s*\{?$/.test(line)) {
            const name = line.split("(")[0].trim();
            const args = line.match(/\((.*?)\)/)[1]
                .split(",")
                .map(a => a.trim())
                .filter(Boolean);

            const node = newPart({ name, kind: "function", path: `${root.path}.${name}`, type: "KavoFunction", args });

            if (!line.includes("{")) i++;
            const { body, endIndex } = scanBlock(lines, i + 1);
            node.children.push(normalizeIndent(body));
            root.children.push(node);
            i = endIndex;
            continue;
        }

        /* ---------- SECTION ---------- */
        if (line.includes("{")) {
            const name = line.split(" ")[0];
            const propString = line
                .slice(name.length)
                .replace(/[{}]/g, "")   // remove BOTH braces
                .trim();
            const node = newPart({ name, kind: "section", path: `${root.path}.${name}`, type: "KavoSection" });

            if (propString) {
                node.properties = parseInlineProps(propString);
            }

            const { body, endIndex } = scanBlock(lines, i + 1);
            parse(body, node);
            root.children.push(node);
            i = endIndex;
            continue;
        }

        /* ---------- PROPERTY ---------- */
        if (line.includes(":")) {
            const [k, v] = line.split(/:(.+)/);
            const { type, value } = parseValue(v);
            root.children.push(newPart({
                name: k.trim(),
                kind: "property",
                path: `${root.path}.${k.trim()}`,
                type,
                value
            }));
            continue;
        }

        throw new Error(`Unknown syntax: ${line}`);
    }

    return root;
}

/* -------------------- INLINE SECTION PROPERTY PARSER -------------------- */

function parseInlineProps(str) {
    const props = {};
    let i = 0;

    function skipSpaces() {
        while (i < str.length && /\s/.test(str[i])) i++;
    }
    function readKeyOrFlag() {
        skipSpaces();

        if (str[i] === '"') {
            i++; // skip opening quote
            let start = i;
            while (i < str.length && str[i] !== '"') i++;
            const val = str.slice(start, i);
            i++; // closing quote
            return val;
        }

        let start = i;
        while (i < str.length && !/[\s:]/.test(str[i])) i++;
        return str.slice(start, i);
    }

    function readWord() {
        let start = i;
        while (i < str.length && !/[\s:]/.test(str[i])) i++;
        return str.slice(start, i);
    }

    function readValue() {
        skipSpaces();
        if (str[i] === '"') {
            i++;
            let start = i;
            while (i < str.length && str[i] !== '"') i++;
            let val = str.slice(start, i);
            i++; // closing quote
            return val;
        }
        let start = i;
        while (i < str.length && !/\s/.test(str[i])) i++;
        return str.slice(start, i);
    }

    while (i < str.length) {
        skipSpaces();
        if (i >= str.length) break;

        let key = readKeyOrFlag();
        skipSpaces();

        if (str[i] === ":") {
            i++;
            let raw = readValue();

            if (!isNaN(raw)) props[key] = Number(raw);
            else if (raw === "true" || raw === "false") props[key] = raw === "true";
            else props[key] = raw;
        } else {
            props[key] = true;
        }
    }

    return props;
}