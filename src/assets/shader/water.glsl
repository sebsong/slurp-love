#pragma language glsl3

uniform float seed;

const int COLOR_PALETTE_SIZE = 8;
uniform vec4 colorPalette[COLOR_PALETTE_SIZE];

const float NUM_COLUMNS = 16;
const float NUM_ROWS = 18;
const float GRID_WIDTH = 1 / NUM_COLUMNS;
const float GRID_HEIGHT = 1 / NUM_ROWS;

uniform vec2 canvasDimensions;
uniform Image canvasImage;

float random (vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233)) * seed)*43758.5453123);
}

vec2 getGridFeaturePoint(vec2 gridIndexes) {
	return vec2(
		(gridIndexes.x + random(gridIndexes.xy)) * GRID_WIDTH, 
		(gridIndexes.y + random(gridIndexes.yx)) * GRID_HEIGHT 
	);
}

#ifdef VERTEX
vec4 position( mat4 transform_projection, vec4 vertex_position ) {
	vec4 pos = transform_projection * vertex_position;
	return pos;
}
#endif

#ifdef PIXEL
vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords ) {
	vec2 gridIndexes = vec2(
		floor(texture_coords.x / GRID_WIDTH),
		floor(texture_coords.y / GRID_HEIGHT)
	);

	vec2 closestGridFeaturePoint = getGridFeaturePoint(gridIndexes);
	float closestDistance = distance(texture_coords, closestGridFeaturePoint);
	// TODO: debug, seems like we aren't properly searching feature points across grids
	for (int i = max(int(gridIndexes.x) - 1, 0); i < min(int(gridIndexes.x) + 1, NUM_COLUMNS); i++) {
		for (int j = max(int(gridIndexes.y) - 1, 0); j < min(int(gridIndexes.y) + 1, NUM_ROWS); j++) {
			if (i == gridIndexes.x && j == gridIndexes.y) {
				continue;
			}

			vec2 gridFeaturePoint = getGridFeaturePoint(vec2(i, j));
			float dist = distance(texture_coords, gridFeaturePoint);
			if (dist < closestDistance) {
				closestGridFeaturePoint = gridFeaturePoint;
				closestDistance = dist;
			}
		}
	}


	if (closestDistance > 0.01) {
		return colorPalette[2];
	} else if (closestDistance > 0.005) {
		return colorPalette[3];
	}

	vec4 waterTexColor = Texel(tex, texture_coords);
	return waterTexColor;
}
#endif
