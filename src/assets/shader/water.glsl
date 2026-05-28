#pragma language glsl3

const int COLOR_PALETTE_SIZE = 8;
uniform vec4 colorPalette[COLOR_PALETTE_SIZE];
uniform float seed;
uniform float time;
uniform vec2 cameraCanvasDimensions;
vec2 pixelDimensions = vec2(1.0, 1.0) / cameraCanvasDimensions;
uniform vec2 cameraPosition;
uniform vec2 boatPosition;
const int NUM_TRAIL_POSITIONS = 16;
uniform vec2 boatTrailPositions[NUM_TRAIL_POSITIONS];

const float NUM_COLUMNS = 16;
const float NUM_ROWS = 32;
const float GRID_WIDTH = 1 / NUM_COLUMNS;
const float GRID_HEIGHT = 1 / NUM_ROWS;

int COLUMN_SEARCH_DIST = 1;
int ROW_SEARCH_DIST = 8;

const float PRIMARY_BORDER_SIZE = 0.002;
const float SECONDARY_BORDER_SIZE = 0.005;

const float DEBUG_POINT_SIZE = 0.002;
const float DEBUG_GRID_LINE_SIZE = 0.003;

const float HORIZONTAL_FREQ = 5;
const float VERTICAL_FREQ = 13;
const float HORIZONTAL_SPEED = -0.25;
const float VERTICAL_SPEED = -1;
const float HORIZONTAL_AMPLITUDE = .1;
const float VERTICAL_AMPLITUDE = .1;
const float FILL_MULTIPLIER = 0.02;

float random(vec2 st) {
    return fract(
        sin(dot(st.xy, vec2(12.9898, 78.233)) * seed) * 43758.5453123
    );
}

vec2 getGridFeaturePoint(vec2 gridIndexes) {
    return vec2(
        (gridIndexes.x +
            0.25 + random(gridIndexes.xy) / 2 +
            cos(gridIndexes.x * HORIZONTAL_FREQ + time * HORIZONTAL_SPEED) * HORIZONTAL_AMPLITUDE
        ) * GRID_WIDTH,
        (gridIndexes.y +
            0.25 + random(gridIndexes.yx) / 2 +
            sin(gridIndexes.y * VERTICAL_FREQ + time * VERTICAL_SPEED) * VERTICAL_AMPLITUDE
        ) * GRID_HEIGHT
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
    vec2 boatCoords = (boatPosition / cameraCanvasDimensions) + 0.5;
    vec2 boatTrailCoords[NUM_TRAIL_POSITIONS];
    for (int i = 0; i < NUM_TRAIL_POSITIONS; i++) {
        boatTrailCoords[i] = (boatTrailPositions[i] / cameraCanvasDimensions) + 0.5;
    }
    vec2 cameraCoords = (cameraPosition / cameraCanvasDimensions);
    texture_coords += cameraCoords;
    texture_coords = floor(texture_coords / pixelDimensions) * pixelDimensions;

    for (int i = 0; i < NUM_TRAIL_POSITIONS; i++) {
        vec2 trailCoords = boatTrailCoords[i];
        float distanceToBoat = distance(trailCoords, boatCoords);
        if (distance(texture_coords, trailCoords) < 0.005 * distanceToBoat * 50 + 0.01) {
            return colorPalette[2];
        } else if (distance(texture_coords, trailCoords) < 0.007 * distanceToBoat * 50 + 0.01) {
            return colorPalette[2];
        }
    }

    vec2 gridIndexes = vec2(
            floor(texture_coords.x / GRID_WIDTH),
            floor(texture_coords.y / GRID_HEIGHT)
        );

    float closestDistance = 1;
    float secondClosestDistance = 1;

    int columnStart = int(gridIndexes.x - COLUMN_SEARCH_DIST);
    int columnEnd = int(gridIndexes.x + COLUMN_SEARCH_DIST);
    int rowStart = int(gridIndexes.y - ROW_SEARCH_DIST);
    int rowEnd = int(gridIndexes.y + ROW_SEARCH_DIST);
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
    // if (closestDistance < DEBUG_POINT_SIZE) {
    //     return colorPalette[3];
    // }
    // if ((texture_coords.x - gridIndexes.x * GRID_WIDTH < DEBUG_GRID_LINE_SIZE / 4) ||
    //         (texture_coords.y - gridIndexes.y * GRID_HEIGHT < DEBUG_GRID_LINE_SIZE)) {
    //     return colorPalette[3];
    // }

    float distDiff = (secondClosestDistance - closestDistance) +
            (cos(texture_coords.x * HORIZONTAL_FREQ + time * HORIZONTAL_SPEED) * HORIZONTAL_AMPLITUDE +
                sin(texture_coords.y * VERTICAL_FREQ + time * VERTICAL_SPEED) * VERTICAL_AMPLITUDE
            ) * FILL_MULTIPLIER;
    if (distDiff < PRIMARY_BORDER_SIZE) {
        return colorPalette[2];
    } else if (distDiff < SECONDARY_BORDER_SIZE) {
        return colorPalette[1];
    }

    //TODO: boat wake, maybe pass a list of prev location points? disrupt
    // if (distance(texture_coords, boatCoords) < 0.03) {
    //     return colorPalette[3];
    // }

    return colorPalette[0];

    // vec4 waterTexColor = Texel(tex, texture_coords);
    // return mix(waterTexColor, colorPalette[4], normalizedDist);
}
#endif
