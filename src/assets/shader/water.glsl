#pragma language glsl3

uniform float seed;

const int COLOR_PALETTE_SIZE = 8;
uniform vec4 colorPalette[COLOR_PALETTE_SIZE];

const float NUM_COLUMNS = 16;
const float NUM_ROWS = 18;
const float GRID_WIDTH = 1 / NUM_COLUMNS;
const float GRID_HEIGHT = 1 / NUM_ROWS;

const float OUTER_RING_DIST = 0.035;
const float INNER_RING_DIST = 0.02;

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
	int columnStart = int(max(gridIndexes.x - 1, 0));
	int columnEnd = int(min(gridIndexes.x + 1, NUM_COLUMNS - 1));
	int rowStart = int(max(gridIndexes.y - 1, 0));
	int rowEnd = int(min(gridIndexes.y + 1, NUM_ROWS - 1));
	for (int i = columnStart; i <= columnEnd; i++) {
		for (int j = rowStart; j <= rowEnd; j++) {
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


	if (closestDistance > OUTER_RING_DIST) {
		return colorPalette[4];
	} else if (closestDistance > INNER_RING_DIST) {
		return colorPalette[2];
	}

	vec4 waterTexColor = Texel(tex, texture_coords);
	return waterTexColor;
}
#endif
