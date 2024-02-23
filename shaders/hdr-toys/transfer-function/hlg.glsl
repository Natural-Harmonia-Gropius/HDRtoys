// https://www.arib.or.jp/kikaku/kikaku_hoso/std-b67.html
// https://www.itu.int/rec/R-REC-BT.2100

//!PARAM L_sdr
//!TYPE float
//!MINIMUM 0
//!MAXIMUM 1000
203.0

//!HOOK OUTPUT
//!BIND HOOKED
//!DESC transfer function (hlg)

const vec3 RGB_to_Y = vec3(0.2627002120112671, 0.6779980715188708, 0.05930171646986196);

const float Lw   = 1000.0;
const float Lb   = 0.0;

// extended model: gamma = 1.2 * pow(1.111, log2(Lw / 1000.0));
const float gamma = 1.2 + 0.42 * log(Lw / 1000.0) / log(10.0);
const float alpha = Lw;
const float beta  = sqrt(3.0 * pow((Lb / Lw), 1.0 / gamma));

const float a = 0.17883277;
const float b = 1.0 - 4.0 * a;
const float c = 0.5 - a * log(4.0 * a);

float hlg_oetf(float x) {
    return x <= 1.0 / 12.0 ? sqrt(3.0 * x) : a * log(12.0 * x - b) + c;
}

vec3 hlg_oetf(vec3 color) {
    return vec3(
        hlg_oetf(color.r),
        hlg_oetf(color.g),
        hlg_oetf(color.b)
    );
}

// pow(0, -n) == ?
vec3 hlg_ootf_inv(vec3 color) {
    float Y = dot(color, RGB_to_Y);
    return pow(Y / alpha, (1.0 - gamma) / gamma) * (color / alpha);
}

vec3 hlg_eotf_inv(vec3 color) {
    return hlg_oetf(hlg_ootf_inv(color));
}

vec4 hook() {
    vec4 color = HOOKED_texOff(0);

    color.rgb = hlg_eotf_inv(color.rgb * L_sdr);

    return color;
}
