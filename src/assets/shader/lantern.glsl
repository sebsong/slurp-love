#pragma language glsl3

const int COLOR_PALETTE_SIZE = 8;

uniform vec4 colorPalette[COLOR_PALETTE_SIZE];
uniform int colorMapping[COLOR_PALETTE_SIZE];
uniform Image lanternLightImage;

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position ) {
	vec4 pos = transform_projection * vertex_position;
	return pos;
}
#endif

#ifdef PIXEL
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
	vec4 lanternTexColor = Texel(lanternLightImage, texture_coords);
    vec4 texColor = Texel(tex, texture_coords);

	if (lanternTexColor.a != 0) {
		int colorIdx = 0;
		for (int i = 0; i < COLOR_PALETTE_SIZE; i++) {
			if (texColor == colorPalette[i]) {
				colorIdx = i;
				break;
			}
		}
		return colorPalette[colorMapping[colorIdx]];
	}
	return texColor;
}
#endif
