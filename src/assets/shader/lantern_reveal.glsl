#pragma language glsl3

uniform bool isLanternActive;
uniform bool inRange;

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position) {
    vec4 pos = transform_projection * vertex_position;
    return pos;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    if (isLanternActive && inRange) {
        discard;
    }
    vec4 texcolor = Texel(tex, texture_coords);
    return texcolor;
}
#endif
