#pragma language glsl3

uniform float VERTICAL_FREQ;
uniform float VERTICAL_SPEED;
uniform float VERTICAL_AMPLITUDE;
uniform vec4 FOAM_COLOR;

uniform bool isLanternActive;
uniform bool inRange;

uniform float time;
uniform vec2 cameraCanvasDimensions;
uniform vec2 tilePosition;
uniform vec4 quadViewport;

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

    vec2 texDimensions = textureSize(tex, 0);
    vec2 quadOffset = quadViewport.xy;
    vec2 quadDimensions = quadViewport.zw;
    vec2 normalizedTextureCoords = (floor(texture_coords * texDimensions) + vec2(0.5, 0.5) - quadOffset) / quadDimensions;

    vec2 tileCoords = (tilePosition / cameraCanvasDimensions);

    float waveHeight = sin(tileCoords.y * VERTICAL_FREQ + time * VERTICAL_SPEED) * VERTICAL_AMPLITUDE;

    float coordsPerYPixel = 1.0 / quadDimensions.y;
    float leftLineVal = 0.5 * normalizedTextureCoords.x + .65 + waveHeight;
    leftLineVal = floor(leftLineVal / coordsPerYPixel) * coordsPerYPixel + coordsPerYPixel / 2;
    float rightLineVal = -0.5 * normalizedTextureCoords.x + 1.15 + waveHeight;
    rightLineVal = floor(rightLineVal / coordsPerYPixel) * coordsPerYPixel + coordsPerYPixel / 2;
    if (normalizedTextureCoords.y > leftLineVal || normalizedTextureCoords.y > rightLineVal) {
        discard;
    } else if (normalizedTextureCoords.y == leftLineVal || normalizedTextureCoords.y == rightLineVal) {
        return FOAM_COLOR;
    }

    vec4 texcolor = Texel(tex, texture_coords);
    return texcolor;
}
#endif
