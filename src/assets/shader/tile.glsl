#pragma language glsl3

uniform float VERTICAL_FREQ;
uniform float VERTICAL_SPEED;
uniform float VERTICAL_AMPLITUDE;
uniform float VERTICAL_AMPLITUDE_FLOAT;
uniform vec4 FOAM_COLOR;

uniform bool isLanternActive;

uniform float time;
uniform vec2 cameraCanvasDimensions;
uniform vec2 cameraPosition;

varying vec2 tileUV;
varying vec4 quadViewport;
varying float isFloating;
varying vec2 tilePosition;
varying float inRange;

#ifdef VERTEX
attribute vec4 v_uv;
attribute vec4 v_quadViewport;
attribute float v_isFloating;
attribute vec2 v_tilePosition;
attribute float v_inRange;

vec4 position(mat4 transform_projection, vec4 vertex_position) {
    tileUV = mix(v_uv.xy, v_uv.zw, VertexTexCoord.xy);
    quadViewport = v_quadViewport;
    isFloating = v_isFloating;
    tilePosition = v_tilePosition;
    inRange = v_inRange;

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
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    texture_coords = tileUV;
    if (isLanternActive && inRange > 0) {
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

    return texcolor;
}
#endif
