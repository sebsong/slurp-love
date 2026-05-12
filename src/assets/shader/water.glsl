#pragma language glsl3

uniform float seed;

const int COLOR_PALETTE_SIZE = 8;
uniform vec4 colorPalette[COLOR_PALETTE_SIZE];

const float GRID_WIDTH = 1.0 / 16;
const float GRID_HEIGHT = 1.0 / 18;

uniform vec2 canvasDimensions;
uniform Image canvasImage;

float random (vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233)) * seed)*43758.5453123);
}

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position ) {
	vec4 pos = transform_projection * vertex_position;
	return pos;
}
#endif

#ifdef PIXEL
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
{
	vec2 gridOrigin = vec2(
		GRID_WIDTH * floor(texture_coords.x / GRID_WIDTH),
		GRID_HEIGHT * floor(texture_coords.y / GRID_HEIGHT)
	);
	vec2 gridCoords = texture_coords - gridOrigin;
	gridCoords.x /= GRID_WIDTH;
	gridCoords.y /= GRID_HEIGHT;

	vec2 gridFeaturePoint = vec2(random(gridOrigin.xy), random(gridOrigin.yx));

	vec2 closestGridFeaturePoint;

	if (distance(gridCoords, gridFeaturePoint) < 0.02) {
		return colorPalette[5];
	} else if (gridCoords.x < 0.01 || gridCoords.y < 0.01) {
		return colorPalette[6];
	}

	vec4 waterTexColor = Texel(tex, texture_coords);
	return waterTexColor;
}
#endif
