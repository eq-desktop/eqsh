#version 310 es
precision highp float;

layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform Params {
    vec2 iResolution;
    float iTime;
    vec3 glowColor;
    float glowIntensity;
    float glowSpeed;
    float glowAngWidth;
    float glowEdgeBand;
    float radiusX;
    float radiusY;
    float shapeExp;
};

const vec3 GLOW_COLOR = vec3(1.0, 1.0, 1.0);
const float GLOW_INTENSITY = 0.9; // Highlight intensity
const float GLOW_ANG_WIDTH = 1.8; // Angular half-width (radians)
const float GLOW_EDGE_BAND = 0.03; // Edge band width (d domain)
const float GLOW_THETA_UR = 0.78539816339; // π/4
const float GLOW_THETA_LL = 3.92699071699; // 5π/4

void main()
{
    vec2 fragCoord = gl_FragCoord.xy;
    vec2 uv = fragCoord / iResolution;
    vec2 center = iResolution * 0.5 / iResolution;
    vec2 R_uv = vec2(100.0, 100.0) / iResolution; // Radius in pixels

    // Distance metric
    vec2 dUv = uv - center;
    float p = 4.0;
    float d = pow(abs(dUv.x) / max(R_uv.x, 1e-6), p)
            + pow(abs(dUv.y) / max(R_uv.y, 1e-6), p);

    // Normalized position (unit L^p ball)
    vec2 n = vec2(
        dUv.x / max(R_uv.x, 1e-6),
        dUv.y / max(R_uv.y, 1e-6)
    );

    // Angle [0, 2π)
    float theta = atan(n.y, n.x);
    if (theta < 0.0) theta += 6.28318530718;

    float phase = theta + 160.3;

    // Angular distance from target diagonals
    float dAng1 = abs(atan(sin(phase - GLOW_THETA_UR), cos(phase - GLOW_THETA_UR)));
    float dAng2 = abs(atan(sin(phase - GLOW_THETA_LL), cos(phase - GLOW_THETA_LL)));

    // Smooth angular falloff
    float angMask1 = smoothstep(GLOW_ANG_WIDTH, 0.0, dAng1);
    float angMask2 = smoothstep(GLOW_ANG_WIDTH, 0.0, dAng2);
    float angMask = clamp(angMask1 + angMask2, 0.0, 1.0);

    // Edge mask (glow near d≈1)
    float edgeBand = 1.0 - smoothstep(GLOW_EDGE_BAND, GLOW_EDGE_BAND * 2.0, abs(1.0 - d));

    // Combined highlight mask
    float glowMask = angMask * edgeBand;

    // Output glowing diagonal edge
    fragColor = vec4(GLOW_COLOR * (glowMask * GLOW_INTENSITY), 1.0);
}
