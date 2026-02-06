#pragma language glsl3

uniform float progress;

vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
	if (texture_coords.y < 1.0 - progress) {
		discard;
	}

    vec4 texcolor = Texel(tex, texture_coords);
    return texcolor * color;
}
