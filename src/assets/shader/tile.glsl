#pragma language glsl3

uniform bool isLanternActive;
uniform bool inRange;

uniform float time;
uniform vec2 cameraCanvasDimensions;
uniform vec2 tilePosition;
uniform vec4 quadViewport;

const float VERTICAL_FREQ = 13;
const float VERTICAL_SPEED = -1;
const float VERTICAL_AMPLITUDE = .1;

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position) {
    vec4 pos = transform_projection * vertex_position;
    return pos;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec2 texDimensions = textureSize(tex, 0);
    vec2 quadOffset = quadViewport.xy;
    vec2 quadDimensions = quadViewport.zw;
    vec2 normalizedTextureCoords = (floor(texture_coords * texDimensions) + vec2(0.5, 0.5) - quadOffset) / quadDimensions;

    vec2 tileCoords = (tilePosition / cameraCanvasDimensions);

    float waveValue = sin(tileCoords.y * VERTICAL_FREQ + time * VERTICAL_SPEED) * VERTICAL_AMPLITUDE;

    if ((normalizedTextureCoords.y > 0.5 * normalizedTextureCoords.x + .65 + waveValue) ||
            (normalizedTextureCoords.y > -0.5 * normalizedTextureCoords.x + 1.15 + waveValue)) {
        discard;
    }

    if (isLanternActive && inRange) {
        discard;
    }

    vec4 texcolor = Texel(tex, texture_coords);
    return texcolor;
}
#endif
