//UNITY_SHADER_NO_UPGRADE
#ifndef SIMPLEXNOISE3_INCLUDED
#define SIMPLEXNOISE3_INCLUDED

float4 vec4_float(float x, float y, float z, float w) { return float4(x, y, z, w); }
float4 vec4_float(float x) { return float4(x, x, x, x); }
float4 vec4_float(float2 x, float2 y) { return float4(float2(x.x, x.y), float2(y.x, y.y)); }
float4 vec4_float(float3 x, float y) { return float4(float3(x.x, x.y, x.z), y); }


float3 vec3_float(float x, float y, float z) { return float3(x, y, z); }
float3 vec3_float(float x) { return float3(x, x, x); }
float3 vec3_float(float2 x, float y) { return float3(float2(x.x, x.y), y); }

float2 vec2_float(float x, float y) { return float2(x, y); }
float2 vec2_float(float x) { return float2(x, x); }

float vec_float(float x) { return float(x); }

float3 fmod289_float(float3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 fmod289_float(float4 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 permute_float(float4 x) {
    return fmod289_float(((x * 34.0) + 1.0) * x);
}

float4 taylorInvSqrt_float(float4 r) {
    return 1.79284291400159 - 0.85373472095314 * r;
}


void snoise_float(float3 v, out float r) {
    const float2  C = vec2_float(1.0 / 6.0, 1.0 / 3.0);
    const float4  D = vec4_float(0.0, 0.5, 1.0, 2.0);
    // First corner
    float3 i = floor(v + dot(v, C.yyy));
    float3 x0 = v - i + dot(i, C.xxx);

    // Other corners
    float3 g = step(x0.yzx, x0.xyz);
    float3 l = 1.0 - g;
    float3 i1 = min(g.xyz, l.zxy);
    float3 i2 = max(g.xyz, l.zxy);

    //   x0 = x0 - 0.0 + 0.0 * C.xxx;
    //   x1 = x0 - i1  + 1.0 * C.xxx;
    //   x2 = x0 - i2  + 2.0 * C.xxx;
    //   x3 = x0 - 1.0 + 3.0 * C.xxx;
    float3 x1 = x0 - i1 + C.xxx;
    float3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
    float3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

    // Permutations
    i = fmod289_float(i);
    float4 p = permute_float(permute_float(permute_float(
        i.z + vec4_float(0.0, i1.z, i2.z, 1.0))
        + i.y + vec4_float(0.0, i1.y, i2.y, 1.0))
        + i.x + vec4_float(0.0, i1.x, i2.x, 1.0));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    float n_ = 0.142857142857; // 1.0/7.0
    float3  ns = n_ * D.wyz - D.xzx;

    float4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  fmod(p,7*7)

    float4 x_ = floor(j * ns.z);
    float4 y_ = floor(j - 7.0 * x_);    // fmod(j,N)

    float4 x = x_ * ns.x + ns.yyyy;
    float4 y = y_ * ns.x + ns.yyyy;
    float4 h = 1.0 - abs(x) - abs(y);

    float4 b0 = vec4_float(x.xy, y.xy);
    float4 b1 = vec4_float(x.zw, y.zw);

    //float4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
    //float4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
    float4 s0 = floor(b0) * 2.0 + 1.0;
    float4 s1 = floor(b1) * 2.0 + 1.0;
    float4 sh = -step(h, vec4_float(0.0));

    float4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
    float4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

    float3 p0 = vec3_float(a0.xy, h.x);
    float3 p1 = vec3_float(a0.zw, h.y);
    float3 p2 = vec3_float(a1.xy, h.z);
    float3 p3 = vec3_float(a1.zw, h.w);

    //Normalise gradients
    float4 norm = taylorInvSqrt_float(vec4_float(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    // Mix final noise value
    float4 m = max(0.6 - vec4_float(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
    m = m * m;
    r = 42.0 * dot(m * m, vec4_float(dot(p0, x0), dot(p1, x1),
        dot(p2, x2), dot(p3, x3)));
}

#endif