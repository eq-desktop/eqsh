function rtrim(str) {
    return str.replace(/\s+$/, '');
}

function decodePluginManifest(text) {
    const result = {};
    const lines = text.split('\n');

    let currentKey = null;

    for (let rawLine of lines) {
        const line = rtrim(rawLine);
        if (!line) continue;

        // indented list item
        if (/^\s+/.test(rawLine) && currentKey) {
            result[currentKey].push(line.trim());
            continue;
        }

        const [key, ...rest] = line.split(':');
        const value = rest.join(':').trim();

        if (value === '') {
            // start of indented list
            currentKey = key;
            result[key] = [];
        } else {
            currentKey = null;

            // comma-separated values → array
            if (value.includes(',')) {
                result[key] = value.split(',').map(v => v.trim());
            } else {
                result[key] = value;
            }
        }
    }

    return result;
}
