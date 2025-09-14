#version 440
layout(location = 0) in vec4 qt_Vertex;
layout(location = 1) in vec2 qt_MultiTexCoord0;
layout(location = 0) out vec2 fragCoord;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 resolution;
};
void main() {
    // make it easier to port from Shadertoy
    fragCoord = qt_MultiTexCoord0 * resolution * vec2(1.0, -1.0) + resolution * vec2(0.0, 1.0);
    gl_Position = qt_Matrix * qt_Vertex;
}