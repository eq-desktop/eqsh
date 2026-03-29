#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 iResolution;
    vec2 direction;   // (1,0)=horizontal  (0,1)=vertical
    float radius;     // blur radius in pixels (e.g. 8–40)
};

#define PI 3.14159265359

float gaussian(float x, float sigma)
{
    return exp(-(x*x) / (2.0*sigma*sigma));
}

void main()
{
    vec2 uv = qt_TexCoord0;
    vec2 texel = 1.0 / iResolution;

    float sigma = radius * 0.5;      // softness control
    int r = int(radius);

    vec4 sum = vec4(0.0);
    float weightSum = 0.0;

    for (int i = -r; i <= r; ++i)
    {
        float w = gaussian(float(i), sigma);
        vec2 offset = direction * texel * float(i);

        sum += texture(source, uv + offset) * w;
        weightSum += w;
    }

    fragColor = sum / weightSum;
}