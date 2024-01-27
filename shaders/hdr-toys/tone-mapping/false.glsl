// Heatmap

//!PARAM enabled
//!TYPE int
//!MINIMUM 0
//!MAXIMUM 1
1

//!PARAM L_sdr
//!TYPE float
//!MINIMUM 0
//!MAXIMUM 1000
203.0

//!PARAM CONTRAST_sdr
//!TYPE float
//!MINIMUM 0
//!MAXIMUM 1000000
1000.0

//!HOOK OUTPUT
//!BIND HOOKED
//!WHEN enabled
//!DESC tone mapping (false color)

const vec3 RGB_to_Y = vec3(0.2627002120112671, 0.6779980715188708, 0.05930171646986196);

vec4 hook() {
    vec4 color = HOOKED_texOff(0);

    float L = dot(color.rgb, RGB_to_Y);

    float l0 =     1.0 / CONTRAST_sdr;
    float l1 =     1.0;
    float l2 =  1000.0 / L_sdr;
    float l3 =  2000.0 / L_sdr;
    float l4 =  4000.0 / L_sdr;
    float l5 = 10000.0 / L_sdr;

    float a = 0.0;
    if (L > l5) {
        color.rgb = vec3(1.0, 0.0, 0.6);
    } else if (L > l4) {
        a = (L - l4) / (l5 - l4);
        a = max(a - 0.1, 0.0) / 0.9 + 0.1;
        color.rgb = vec3(1.0, 1.0, a);
    } else if (L > l3) {
        a = (L - l3) / (l4 - l3);
        a = max(a - 0.1, 0.0) / 0.9 + 0.1;
        color.rgb = vec3(a, 0.0, 0.0);
    } else if (L > l2) {
        a = (L - l2) / (l3 - l2);
        a = max(a - 0.1, 0.0) / 0.9 + 0.1;
        color.rgb = vec3(0.0, a, 0.0);
    } else if (L > l1) {
        a = (L - l1) / (l2 - l1);
        a = max(a - 0.1, 0.0) / 0.9 + 0.1;
        color.rgb = vec3(0.0, 0.0, a);
    } else if (L < l0) {
        color.rgb = vec3(0.0, 0.0, 0.0);
    } else {
        color.rgb = vec3(L, L, L);
    }

    return color;
}
