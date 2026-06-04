#pragma language glsl3

uniform float seed;
uniform float time;
uniform vec2 cameraCanvasDimensions;
vec2 pixelDimensions = vec2(1.0, 1.0) / cameraCanvasDimensions;
uniform vec2 cameraPosition;
uniform vec2 boatPosition;
const int NUM_TRAIL_POSITIONS = 16;
uniform vec2 boatTrailPositions[NUM_TRAIL_POSITIONS];

uniform vec4 WATER_BASE_COLOR;
uniform vec4 WATER_FOAM_OUTER_COLOR;
uniform vec4 WATER_FOAM_INNER_COLOR;
uniform vec4 WATER_TRAIL_COLOR;

uniform float GRID_WIDTH;
uniform float GRID_HEIGHT;

uniform int COLUMN_SEARCH_DIST;
uniform int ROW_SEARCH_DIST;

uniform float WATER_FOAM_INNER_SIZE;
uniform float WATER_FOAM_OUTER_SIZE;

uniform float DEBUG_POINT_SIZE;
uniform float DEBUG_GRID_LINE_SIZE;

uniform float HORIZONTAL_FREQ;
uniform float VERTICAL_FREQ;
uniform float HORIZONTAL_SPEED;
uniform float VERTICAL_SPEED;
uniform float HORIZONTAL_AMPLITUDE;
uniform float VERTICAL_AMPLITUDE;
uniform float FILL_MULTIPLIER;

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

        vec2 directionToPrev;
        if (i == 0) {
            directionToPrev = normalize(boatCoords - trailCoords);
        } else {
            directionToPrev = normalize(boatTrailCoords[i - 1] - trailCoords);
        }
        vec2 sideVec1 = vec2(-directionToPrev.y, directionToPrev.x);
        vec2 sideVec2 = vec2(directionToPrev.y, -directionToPrev.x);
        float distanceToBoat = distance(trailCoords, boatCoords);
        float trailWidthMultiplier = .001 + .1 * distanceToBoat;

        if (distance(texture_coords, trailCoords + sideVec1 * trailWidthMultiplier) < 0.003 ||
                distance(texture_coords, trailCoords + sideVec2 * trailWidthMultiplier) < 0.003) {
            return WATER_TRAIL_COLOR;
        }

        // if (distance(texture_coords, trailCoords) < 0.02) {
        //     return colorPalette[2];
        // }

        // if (distance(texture_coords, trailCoords) < 0.0065 * distanceToBoat * 50 + 0.01) {
        //     return colorPalette[1];
        // } else if (distance(texture_coords, trailCoords) < 0.007 * distanceToBoat * 50 + 0.01) {
        //     return colorPalette[2];
        // }
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
    //     return vec4(1, 0, 0, 1);
    // }
    // if ((texture_coords.x - gridIndexes.x * GRID_WIDTH < DEBUG_GRID_LINE_SIZE / 4) ||
    //         (texture_coords.y - gridIndexes.y * GRID_HEIGHT < DEBUG_GRID_LINE_SIZE)) {
    //     return vec4(0, 1, 0, 1);
    // }

    float distDiff = (secondClosestDistance - closestDistance) +
            (cos(texture_coords.x * HORIZONTAL_FREQ + time * HORIZONTAL_SPEED) * HORIZONTAL_AMPLITUDE +
                sin(texture_coords.y * VERTICAL_FREQ + time * VERTICAL_SPEED) * VERTICAL_AMPLITUDE
            ) * FILL_MULTIPLIER;
    if (distDiff < WATER_FOAM_INNER_SIZE) {
        return WATER_FOAM_INNER_COLOR;
    } else if (distDiff < WATER_FOAM_OUTER_SIZE) {
        return WATER_FOAM_OUTER_COLOR;
    }

    return WATER_BASE_COLOR;
}
#endif
