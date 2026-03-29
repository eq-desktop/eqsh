// This is an implementation of Apple's Liquid Glass effect for iOS 26.
// https://developer.apple.com/videos/play/wwdc2025/219/

#version 450

// Constants
#define PI 3.141592653589323
#define EPS_PIX 2. // 2 pixels for AA

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 0) uniform sampler2D source;
layout(binding = 1) uniform sampler2D blurSource;
layout(binding = 2) uniform sampler2D bloomSource;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 iResolution;

    float glassRefractionDim; // Refraction area size
    float glassRefractionMag; // Refraction vector magnitude
    float glassRefractionAberration; // Refraction aberration coeff
    vec3  glassRefractionIOR;// IOR values for red, green, blue

    float glassEdgeDim; // Edge area size
    vec4  glassTintColor; // Tint color
    int   blurAmount; // Blur

    vec2  rimLightDir; // Rim light angle
    vec4  rimLightColor; // Rim light color

    float reflectionOffsetMin;
    float reflectionOffsetMag;

    float fieldSmoothing; // Smoothing of nearby shapes
    vec2 shapePos;
    vec2 shapeSize;
    float shapeRadius;
    float shapeRot;
    int shapeType;
};

//#define glassRefractionDim 0.06
//#define glassRefractionMag 0.1
//#define glassRefractionAberration .5
//#define glassRefractionIOR vec3(1.51, 1.52, 1.53)        
//#define glassEdgeDim 0.003
//#define glassTintColor vec4(0)
//#define blurAmount 15
//#define RIM_LIGHT_VEC normalize(vec2(-1., 1.))
//#define RIM_LIGHT_COLOR vec4(vec3(1.),.35)
//#define REFL_OFFSET_MIN 0.075
//#define REFL_OFFSET_MAG 0.005
//#define FIELD_SMOOTHING 0.005

// Source: https://iquilezles.org/articles/distgradfunctions2d/
// https://www.shadertoy.com/view/WltSDj
vec3 sdgCircle( in vec2 p, in float r ) 
{
    float l = length(p);
    return vec3( l-r, p/l );
}
// https://www.shadertoy.com/view/wlcXD2
vec3 sdgBoxAdv( in vec2 p, in vec2 b, vec4 ra )
{
    ra.xy   = (p.x>0.0)?ra.xy : ra.zw;
    float r = (p.y>0.0)?ra.x  : ra.y;
    vec2 w = abs(p)-(b-r);
    vec2 s = vec2(p.x<0.0?-1:1,p.y<0.0?-1:1);
    float g = max(w.x,w.y);
	vec2  q = max(w,0.0);
    float l = length(q);
    return vec3(   (g>0.0)?l-r: g-r,
                s*((g>0.0)?q/l : ((w.x>w.y)?vec2(1,0):vec2(0,1))));
}
// https://www.shadertoy.com/view/wlcXD2
vec3 sdgBox( in vec2 p, in vec2 b, in float r ) { return sdgBoxAdv(p, b, vec4(r)); }
vec3 sdgTriangle( in vec2 p, in float r)
{
    const float k = sqrt(3.0);
    p.x = abs(p.x) - r;
    p.y = p.y + r/k;

    if (p.x + k*p.y > 0.0)
        p = vec2(p.x - k*p.y, -k*p.x - p.y) * 0.5;
    p.x -= clamp(p.x, -2.0*r, 0.0);
    float d = -length(p) * sign(p.y);
    vec2 g = normalize(p) * sign(p.y);
    return vec3(d, g);
}
// https://www.shadertoy.com/view/tdGBDt
// .x = f(p)
// .yz = ∇f(p) = {∂f(p)/∂x, ∂f(p)/∂y} with ‖∇f(p)‖<1
vec3 sdgSMin( in vec3 a, in vec3 b, in float k )
{
    k *= 4.0;
    float h = max( k-abs(a.x-b.x), 0.0 )/(2.0*k);
    return vec3( min(a.x,b.x)-h*h*k,
                 mix(a.yz,b.yz,(a.x<b.x)?h:1.0-h) );
}
// https://www.shadertoy.com/view/tdGBDt
// .x = f(p)
// .yz = ∇f(p) = {∂f(p)/∂x, ∂f(p)/∂y} with ‖∇f(p)‖=1 iff ‖∇a(p)‖=‖∇b(p)‖=1
vec3 sdgMin( in vec3 a, in vec3 b ) { return (a.x<b.x) ? a : b; }
float lerp(float minV, float maxV, float v) { return clamp((v - minV) / (maxV - minV), 0., 1.); }
vec2 screenToLocalPx(vec2 fragCoord)
{
    // origin = screen center, units = pixels
    return fragCoord;
}
vec2 rot(vec2 p, float a){
    float s = sin(a), c = cos(a);
    return mat2(c,-s,s,c)*p;
}

#define SAMPLES blurAmount   // original kernel width in full-res pixels
#define LOD     0             // mip level to use
#define SLOD    1<<LOD        // = 4
#define SIGMA   float(SAMPLES)*0.25

/* 1-D Gaussian weight for an integer tap offset */
float gWeight(int i)
{
    float d = float(i*SLOD);
    float n = exp(-0.5* (d*d) / (SIGMA*SIGMA));
    return n / (2.0*PI*SIGMA*SIGMA);   // full normalisation (OK for 1-D)
}
vec4 gaussBlur(sampler2D src, vec2 uv, vec2 delta) {
    int   middle = SAMPLES / (2*SLOD);
    vec4  sum  = vec4(0.0);
    float acc  = 0.0;

    for(int i=-middle; i<=middle; ++i)
    {
        float w = gWeight(i);
        sum += texture(src, uv + delta*float(i)) * w;
        acc += w;
    }

    return sum / acc; // renormalise for unaccounted energy (sigma > 4 or < 4)
}
vec3 blendScreen(vec3 a, vec3 b) { return 1. - (1. - a) * (1. - b); }
vec3 blendLighten(vec3 a, vec3 b) { return max(a, b); }

vec3 field(vec2 fragCoord)
{
    vec2 p = screenToLocalPx(fragCoord);

    vec2 centerPos = shapePos + shapeSize;

    // shapePos is now in pixels from screen center
    vec2 lp = rot(p - centerPos, -radians(shapeRot));

    vec3 d;
    if (shapeType == 0)
        d = sdgCircle(lp, shapeSize.x);              // radius in px
    else if (shapeType == 1)
        d = sdgBox(lp, shapeSize, shapeRadius);     // size + radius in px

    return d;
}

void refractionLayer(
    inout vec3 col,
    float EPS,
    float d,
    vec2 norm,
    vec2 UV
){
    float boundary = lerp(-glassRefractionDim, EPS, d);
    boundary = mix(boundary, 0., smoothstep(0., EPS, d));

    float cosBoundary = 1.0 - cos(boundary * PI / 2.0);
    float interior = smoothstep(EPS, 0., d);

    vec3 ior = mix(vec3(glassRefractionIOR.g), glassRefractionIOR, glassRefractionAberration);
    vec2 pxToUV = 1.0 / iResolution;

    vec2 offset = -norm * glassRefractionMag * pxToUV;

    vec3 ratios = pow(vec3(cosBoundary), ior);

    vec3 baseColor = texture(source, UV).rgb;

    float r = texture(blurSource, UV + offset * ratios.r).r;
    float g = texture(blurSource, UV + offset * ratios.g).g;
    float b = texture(blurSource, UV + offset * ratios.b).b;

    vec3 blurWarped = vec3(r,g,b);
    col = mix(baseColor, blurWarped, interior);
}
void tintLayer(
    inout vec3 col,
    float EPS,
    float d,
    vec2 norm,
    vec2 UV
){
    float interior = smoothstep(EPS, 0., d);
    col = mix(col, glassTintColor.rgb, glassTintColor.a * interior);

    float a = interior;
    float b = lerp(-glassEdgeDim, 0., d);
    float edge = min(a, b);

    float cosEdge = 1. - cos(edge * PI / 2.);

    float rimLightIntensity = abs(dot(normalize(norm), rimLightDir));
    vec3 rimLight = rimLightColor.rgb * rimLightColor.a * rimLightIntensity;

    vec2 pxToUV = 1.0 / iResolution;
    vec2 reflectionOffset =
        (reflectionOffsetMin + reflectionOffsetMag * cosEdge)
        * norm * pxToUV;

    vec3 reflectionColor = clamp(texture(bloomSource, UV + reflectionOffset).rgb, 0., 1.);
    reflectionColor = mix(reflectionColor, glassTintColor.rgb, glassTintColor.a);

    vec3 mergedEdgeColor = blendScreen(rimLight, reflectionColor);
    vec3 edgeColor = blendLighten(col, mergedEdgeColor);

    col = mix(col, edgeColor, cosEdge);
}

void main()
{
    vec2 fragCoord = qt_TexCoord0 * iResolution;
    vec2 UV = fragCoord / iResolution;   // ONLY for textures
    float EPS = EPS_PIX;

    vec2 p = screenToLocalPx(fragCoord);

    vec3 f = field(fragCoord);
    float d = f.x;
    vec2 norm = normalize(f.yz);   // in px space

    vec3 col = vec3(0.0);

    refractionLayer(col, EPS, d, norm, UV);
    tintLayer(col, EPS, d, norm, UV);

    fragColor = vec4(col, 1.0);
}