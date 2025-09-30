pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: utils

    function complementary(c) {
        // convert RGB (0–1) to HSL
        var r = c.r, g = c.g, b = c.b;
        var max = Math.max(r, g, b);
        var min = Math.min(r, g, b);
        var h, s, l = (max + min) / 2;
        var d = max - min;

        if (d === 0) {
            h = 0; s = 0; // gray
        } else {
            s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
            switch (max) {
            case r: h = (g - b) / d + (g < b ? 6 : 0); break;
            case g: h = (b - r) / d + 2; break;
            case b: h = (r - g) / d + 4; break;
            }
            h /= 6;
        }

        // rotate hue by 180° (0.5 in [0,1] space)
        h = (h + 0.5) % 1.0;

        // convert back HSL → RGB
        function hue2rgb(p, q, t) {
            if (t < 0) t += 1;
            if (t > 1) t -= 1;
            if (t < 1/6) return p + (q - p) * 6 * t;
            if (t < 1/2) return q;
            if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
            return p;
        }

        var r2, g2, b2;
        if (s === 0) {
            r2 = g2 = b2 = l; // gray
        } else {
            var q = l < 0.5 ? l * (1 + s) : l + s - l * s;
            var p = 2 * l - q;
            r2 = hue2rgb(p, q, h + 1/3);
            g2 = hue2rgb(p, q, h);
            b2 = hue2rgb(p, q, h - 1/3);
        }

        return Qt.rgba(r2, g2, b2, c.a);
    }
}
