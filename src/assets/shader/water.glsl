#pragma language glsl3

uniform float seed;
uniform float time;
uniform vec2 canvasDimensions;

const int COLOR_PALETTE_SIZE = 8;
uniform vec4 colorPalette[COLOR_PALETTE_SIZE];

// const float NUM_COLUMNS = 16;
// const float NUM_ROWS = 18;
const float NUM_COLUMNS = 8;
const float NUM_ROWS = 18;
const float GRID_WIDTH = 1 / NUM_COLUMNS;
const float GRID_HEIGHT = 1 / NUM_ROWS;

const float SPEED = .2;

const float MAX_DIST = min(
        sqrt(pow(GRID_WIDTH, 2) + pow(2 * GRID_HEIGHT, 2)),
        sqrt(pow(2 * GRID_WIDTH, 2) + pow(GRID_HEIGHT, 2))
    ) * .7;
const float OUTER_RING_DIST = 0.7;
const float INNER_RING_DIST = 0.3;

float random(vec2 st) {
    time;
    return fract(
        sin(dot(st.xy, vec2(12.9898, 78.233)) * seed) * 43758.5453123
    );
    // (sin(st.x + time * SPEED / 2) +
    //     cos(st.y + time * SPEED)
    // ) / 10.0;
}

vec2 getGridFeaturePoint(vec2 gridIndexes) {
    return vec2(
        (gridIndexes.x + random(gridIndexes.xy) + cos(gridIndexes.x + time * SPEED / 8) / 5) * GRID_WIDTH,
        (gridIndexes.y + random(gridIndexes.yx) + sin(gridIndexes.y + time * SPEED / 2) / 2) * GRID_HEIGHT
    );
}

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position) {
    vec4 pos = transform_projection * vertex_position;
    return pos;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 pixelDimensions = vec2(1.0, 1.0) / canvasDimensions;
    texture_coords = floor(texture_coords / pixelDimensions) * pixelDimensions;
    vec2 gridIndexes = vec2(
            floor(texture_coords.x / GRID_WIDTH),
            floor(texture_coords.y / GRID_HEIGHT)
        );

    float closestDistance = 1;
    float secondClosestDistance = 1;

    int columnStart = int(gridIndexes.x) - 2;
    int columnEnd = int(gridIndexes.x + 2);
    int rowStart = int(gridIndexes.y - 3);
    int rowEnd = int(gridIndexes.y + 3);
    for (int i = columnStart; i <= columnEnd; i++) {
        for (int j = rowStart; j <= rowEnd; j++) {
            vec2 gridFeaturePoint = getGridFeaturePoint(vec2(i, j));
            float dist = distance(texture_coords, gridFeaturePoint);
            if (dist < closestDistance) {
                secondClosestDistance = closestDistance;
                closestDistance = dist;
            } else if (dist < secondClosestDistance) {
                secondClosestDistance = dist;
            }
        }
    }

    // DEBUG GRID AND POINTS
    // if (closestDistance < 0.005) {
    //     return colorPalette[3];
    // }
    // if (texture_coords.x - gridIndexes.x * GRID_WIDTH < 0.002 ||
    //         texture_coords.y - gridIndexes.y * GRID_HEIGHT < 0.002) {
    //     return colorPalette[3];
    // }

    float distDiff = (secondClosestDistance - closestDistance);
    // (sin(texture_coords.x * 10 + time) +
    //     cos(texture_coords.y * 50 + time)
    // ) / 500;
    if (distDiff < 0.003) {
        return colorPalette[2];
    } else if (distDiff < 0.01) {
        return colorPalette[1];
    }
    return colorPalette[0];

    // vec4 waterTexColor = Texel(tex, texture_coords);
    // return mix(waterTexColor, colorPalette[4], normalizedDist);
}
#endif
