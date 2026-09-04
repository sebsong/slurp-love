#pragma language glsl3

uniform float VERTICAL_FREQ;
uniform float VERTICAL_SPEED;
uniform float VERTICAL_AMPLITUDE;
uniform float VERTICAL_AMPLITUDE_FLOAT;
uniform vec4 FOAM_COLOR;
uniform vec2 LANTERN_RADII;

uniform float time;
uniform vec2 cameraCanvasDimensions;
uniform vec2 cameraPosition;
uniform bool isLanternActive;
uniform vec2 lanternPosition;

varying vec2 uv;
varying vec2 uvNormalized;
varying vec4 quadViewport;
varying float isFloating;
varying vec2 tilePosition;

#ifdef VERTEX
attribute vec4 v_uv;
attribute vec2 v_position;
attribute vec4 v_quadViewport;
attribute float v_isFloating;
attribute float v_inRange;

vec4 position(mat4 transform_projection, vec4 vertex_position) {
    uv = mix(v_uv.xy, v_uv.zw, VertexTexCoord.xy);
    uvNormalized = VertexTexCoord.xy;
    quadViewport = v_quadViewport;
    isFloating = v_isFloating;
    tilePosition = v_position;

    vertex_position.xy += tilePosition;
    vec4 pos = transform_projection * vertex_position;
    if (isFloating > 0) {
        vec2 cameraCoords = (cameraPosition / cameraCanvasDimensions);
        vec2 tileCoords = (tilePosition / cameraCanvasDimensions);
        pos.y += sin(tileCoords.y * VERTICAL_FREQ + time * VERTICAL_SPEED) * VERTICAL_AMPLITUDE_FLOAT;
    }
    return pos;
}
#endif

#ifdef PIXEL
bool inRange() {
    vec2 positionDiff = tilePosition - lanternPosition;
    return (pow((positionDiff.x / LANTERN_RADII.x), 2) + pow((positionDiff.y / LANTERN_RADII.y), 2)) <= 1;
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    texture_coords = uv;
    if (isFloating > 0 && isLanternActive && inRange()) {
        discard;
    }

    vec4 texcolor = Texel(tex, texture_coords);
    if (isFloating > 0) {
        return texcolor;
    }

    vec2 texDimensions = textureSize(tex, 0);
    vec2 quadOffset = quadViewport.xy;
    vec2 quadDimensions = quadViewport.zw;
    vec2 normalizedTextureCoords = (floor(texture_coords * texDimensions) + vec2(0.5, 0.5) - quadOffset) / quadDimensions;
    vec2 coordsPerPixel = 1.0 / quadDimensions;
    // TODO: can we use the normalized uv
    // vec2 uvNormalized = floor(uvNormalized / coordsPerPixel) * coordsPerPixel;

    vec2 tileCoords = (tilePosition / cameraCanvasDimensions);

    float waveHeight = sin(tileCoords.y * VERTICAL_FREQ + time * VERTICAL_SPEED) * VERTICAL_AMPLITUDE;

    float leftLineVal = 0.5 * normalizedTextureCoords.x + .65 + waveHeight;
    leftLineVal = floor(leftLineVal / coordsPerPixel.y) * coordsPerPixel.y + coordsPerPixel.y / 2;
    float rightLineVal = -0.5 * normalizedTextureCoords.x + 1.15 + waveHeight;
    rightLineVal = floor(rightLineVal / coordsPerPixel.y) * coordsPerPixel.y + coordsPerPixel.y / 2;
    if (normalizedTextureCoords.y > leftLineVal || normalizedTextureCoords.y > rightLineVal) {
        discard;
    } else if (normalizedTextureCoords.y == leftLineVal || normalizedTextureCoords.y == rightLineVal) {
        return FOAM_COLOR;
    }

    return texcolor;
}
#endif
