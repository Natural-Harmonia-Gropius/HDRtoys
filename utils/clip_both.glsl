//!HOOK OUTPUT
//!BIND HOOKED
//!DESC clip code value (black, white)

vec4 color = HOOKED_tex(HOOKED_pos);
vec4 hook() {
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    return color;
}
