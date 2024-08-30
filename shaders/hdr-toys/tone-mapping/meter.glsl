//!HOOK OUTPUT
//!BIND HOOKED
//!SAVE METER
//!COMPONENTS 1
//!DESC metering (luminance map)

const vec3 coeff = vec3(0.2627002120112671, 0.6779980715188708, 0.05930171646986196);

vec4 hook() {
    vec4 color = HOOKED_tex(HOOKED_pos);
    float luminance = dot(color.rgb, coeff);
    return vec4(luminance);
}

//!BUFFER MINMAX
//!VAR uint minVal
//!VAR uint maxVal
//!VAR uint avgVal
//!STORAGE

//!HOOK OUTPUT
//!BIND MINMAX
//!SAVE VOID
//!WIDTH 1
//!HEIGHT 1
//!COMPUTE 1 1
//!DESC metering (minmax, initial)

void hook() {
    minVal = uint(4095);
    maxVal = uint(0);
    avgVal = uint(0);
}

//!HOOK OUTPUT
//!BIND METER
//!SAVE BLUR
//!WIDTH 1024
//!HEIGHT 1024
//!DESC metering (minmax, 1024)
vec4 hook() { return METER_tex(METER_pos); }

//!HOOK OUTPUT
//!BIND BLUR
//!SAVE BLUR
//!DESC metering (spatial stabilization, blur, horizonal)

const vec4 offset = vec4(0.0, 1.411764705882353, 3.2941176470588234, 5.176470588235294);
const vec4 weight = vec4(0.1964825501511404, 0.2969069646728344, 0.09447039785044732, 0.010381362401148057);
const vec2 dir    = vec2(1.0, 0.0);

vec4 hook(){
    uint i = 0;
    vec4 c = BLUR_texOff(offset[i]) * weight[i];

    for (i = 1; i < 4; i++) {
        c += BLUR_texOff( dir * offset[i]) * weight[i];
        c += BLUR_texOff(-dir * offset[i]) * weight[i];
    }

    return c;
}

//!HOOK OUTPUT
//!BIND BLUR
//!SAVE BLUR
//!DESC metering (spatial stabilization, blur, vertical)

const vec4 offset = vec4(0.0, 1.411764705882353, 3.2941176470588234, 5.176470588235294);
const vec4 weight = vec4(0.1964825501511404, 0.2969069646728344, 0.09447039785044732, 0.010381362401148057);
const vec2 dir    = vec2(0.0, 1.0);

vec4 hook(){
    uint i = 0;
    vec4 c = BLUR_texOff(offset[i]) * weight[i];

    for (i = 1; i < 4; i++) {
        c += BLUR_texOff( dir * offset[i]) * weight[i];
        c += BLUR_texOff(-dir * offset[i]) * weight[i];
    }

    return c;
}

//!HOOK OUTPUT
//!BIND BLUR
//!BIND MINMAX
//!SAVE VOID
//!COMPUTE 16 16
//!DESC minmax

shared uint localMin;
shared uint localMax;

uint f(float x) {
    return uint(x * 4095.0 + 0.5);
}

void hook() {
    ivec2 gid = ivec2(gl_GlobalInvocationID.xy);
    // ivec2 texSize = textureSize(BLUR_raw, 0);

    // if (gid.x >= texSize.x || gid.y >= texSize.y) {
    //     return;
    // }

    vec4 color = texelFetch(BLUR_raw, gid, 0);
    uint value = f(color.x);

    // if (value == uint(0)) {
    //     return;
    // }

    if (gl_LocalInvocationIndex == 0) {
        localMin = uint(4095);
        localMax = uint(0);
    }
    barrier();

    atomicMin(localMin, value);
    atomicMax(localMax, value);
    barrier();

    if (gl_LocalInvocationIndex == 0) {
        atomicMin(minVal, localMin);
        atomicMax(maxVal, localMax);
    }
}

//!HOOK OUTPUT
//!BIND BLUR
//!BIND MINMAX
//!SAVE VOID
//!COMPUTE 16 16
//!DESC average

shared uint localSum;

uint f(float x) {
    return uint(x * 4095.0 + 0.5);
}

float fInv(uint x) {
    return float(x) / 4095.0;
}

void hook() {
    ivec2 gid = ivec2(gl_GlobalInvocationID.xy);
    vec4 color = texelFetch(BLUR_raw, gid, 0);
    uint value = f(color.x);

    ivec2 texSize = textureSize(BLUR_raw, 0);
    float area = float(texSize.x * texSize.y);

    if (gl_LocalInvocationIndex == 0) {
        localSum = uint(0);
    }
    barrier();

    atomicAdd(localSum, value);
    barrier();

    if (gl_LocalInvocationIndex == 0) {
        float localAvg = fInv(localSum) / area;
        atomicAdd(avgVal, f(localAvg));
    }
}

//!HOOK OUTPUT
//!BIND METER
//!SAVE AVG
//!WIDTH 1024
//!HEIGHT 1024
//!DESC metering (average, 1024)
vec4 hook() { return METER_tex(METER_pos); }

//!HOOK OUTPUT
//!BIND AVG
//!SAVE AVG
//!WIDTH AVG.w 2 /
//!HEIGHT AVG.h 2 /
//!DESC metering (average, 512)
vec4 hook() { return AVG_tex(AVG_pos); }

//!HOOK OUTPUT
//!BIND AVG
//!SAVE AVG
//!WIDTH AVG.w 2 /
//!HEIGHT AVG.h 2 /
//!DESC metering (average, 256)
vec4 hook() { return AVG_tex(AVG_pos); }

//!HOOK OUTPUT
//!BIND AVG
//!SAVE AVG
//!WIDTH AVG.w 2 /
//!HEIGHT AVG.h 2 /
//!DESC metering (average, 128)
vec4 hook() { return AVG_tex(AVG_pos); }

//!HOOK OUTPUT
//!BIND AVG
//!SAVE AVG
//!WIDTH AVG.w 2 /
//!HEIGHT AVG.h 2 /
//!DESC metering (average, 64)
vec4 hook() { return AVG_tex(AVG_pos); }

//!HOOK OUTPUT
//!BIND AVG
//!SAVE AVG
//!WIDTH AVG.w 2 /
//!HEIGHT AVG.h 2 /
//!DESC metering (average, 32)
vec4 hook() { return AVG_tex(AVG_pos); }

//!HOOK OUTPUT
//!BIND AVG
//!SAVE AVG
//!WIDTH AVG.w 2 /
//!HEIGHT AVG.h 2 /
//!DESC metering (average, 16)
vec4 hook() { return AVG_tex(AVG_pos); }

//!HOOK OUTPUT
//!BIND AVG
//!SAVE AVG
//!WIDTH AVG.w 2 /
//!HEIGHT AVG.h 2 /
//!DESC metering (average, 8)
vec4 hook() { return AVG_tex(AVG_pos); }

//!HOOK OUTPUT
//!BIND AVG
//!SAVE AVG
//!WIDTH AVG.w 2 /
//!HEIGHT AVG.h 2 /
//!DESC metering (average, 4)
vec4 hook() { return AVG_tex(AVG_pos); }

//!HOOK OUTPUT
//!BIND AVG
//!SAVE AVG
//!WIDTH AVG.w 2 /
//!HEIGHT AVG.h 2 /
//!DESC metering (average, 2)
vec4 hook() { return AVG_tex(AVG_pos); }

//!HOOK OUTPUT
//!BIND AVG
//!SAVE AVG
//!WIDTH AVG.w 2 /
//!HEIGHT AVG.h 2 /
//!DESC metering (average, 1)
vec4 hook() { return AVG_tex(AVG_pos); }

//!HOOK OUTPUT
//!BIND HOOKED
//!BIND MINMAX
//!BIND AVG
//!DESC avg

const float pq_m1 = 0.1593017578125;
const float pq_m2 = 78.84375;
const float pq_c1 = 0.8359375;
const float pq_c2 = 18.8515625;
const float pq_c3 = 18.6875;

const float pq_C  = 10000.0;

float Y_to_ST2084(float C) {
    float L = C / pq_C;
    float Lm = pow(L, pq_m1);
    float N = (pq_c1 + pq_c2 * Lm) / (1.0 + pq_c3 * Lm);
    N = pow(N, pq_m2);
    return N;
}

float fInv(uint x) {
    return float(x) / 4095.0;
}

bool almostEqual(float a, float b, float epsilon) {
    return abs(a - b) < epsilon;
}

vec4 hook() {
    vec4 color = HOOKED_tex(HOOKED_pos);
    float height = 1.0 - HOOKED_pos.y;
    float epsilon = 0.001;

    float minValf = fInv(minVal);
    float minValPQ = Y_to_ST2084(minValf * 203.0);
    if (almostEqual(minValPQ, height, epsilon)) {
        color.rgb = vec3(0.0, 0.0, 1.0);
    }

    float maxValf = fInv(maxVal);
    float maxValPQ = Y_to_ST2084(maxValf * 203.0);
    if (almostEqual(maxValPQ, height, epsilon)) {
        color.rgb = vec3(1.0, 0.0, 0.0);
    }

    float avgValf = fInv(avgVal);
    float avgValPQ = Y_to_ST2084(avgValf * 203.0);
    if (almostEqual(avgValPQ, height, epsilon)) {
        color.rgb = vec3(1.0, 0.0, 1.0);
    }

    float averageY = AVG_tex(vec2(0.0)).x;
    float averagePQ = Y_to_ST2084(averageY * 203.0);
    if (almostEqual(averagePQ, height, epsilon)) {
        color.rgb = vec3(0.0, 1.0, 0.0);
    }

    float outputWhite = Y_to_ST2084(203.0);
    float outputBlack = Y_to_ST2084(203.0 / 1000.0);
    float middleGray = (outputWhite - outputBlack) / 2.0 + outputBlack;
    if (almostEqual(outputWhite, height, epsilon)) {
        color.rgb = vec3(1.0, 1.0, 0.0);
    }
    if (almostEqual(outputBlack, height, epsilon)) {
        color.rgb = vec3(0.0, 1.0, 1.0);
    }
    if (almostEqual(middleGray, height, epsilon)) {
        color.rgb = vec3(0.5, 0.5, 0.5);
    }

    color.rgb *= middleGray / averagePQ;

    return color;
}
