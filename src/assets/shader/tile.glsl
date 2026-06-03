#pragma language glsl3

uniform bool isLanternActive;
uniform bool inRange;

uniform float seed;
uniform float time;
uniform vec2 cameraCanvasDimensions;
vec2 pixelDimensions = vec2(1.0, 1.0) / cameraCanvasDimensions;
uniform vec2 cameraPosition;
uniform vec2 tilePosition;

const float VERTICAL_FREQ = 13;
const float VERTICAL_SPEED = -1;
const float VERTICAL_AMPLITUDE = .3;

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position) {
    vec4 pos = transform_projection * vertex_position;
    return pos;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec2 cameraCoords = (cameraPosition / cameraCanvasDimensions);
    vec2 tileCoords = (tilePosition / cameraCanvasDimensions);
    vec2 textureCoords = cameraCoords + 0.5;

    float waveValue = sin(tileCoords.y * VERTICAL_FREQ + time * VERTICAL_SPEED) * VERTICAL_AMPLITUDE;

    texture_coords = floor(texture_coords / pixelDimensions) * pixelDimensions;

    // TODO: figure these formulas out, also why is the texture_coords.x go from 0 - 0.2 instead of 0 to 1? something about sprite batches?
    // TODO: pixel quantize this properly
    float textureValue = 2 * texture_coords.x - texture_coords.y + 2;
    float otherTextureValue = -2 * (texture_coords.x - .25) - texture_coords.y + 2;
    if ((textureValue <= (1 - waveValue))) {
        discard;
    }

    if (otherTextureValue <= (1 - waveValue)) {
        discard;
    }

    // if (texture_coords.y > 1 + waveValue) {
    // discard;
    // }

    if (isLanternActive && inRange) {
        discard;
    }

    vec4 texcolor = Texel(tex, texture_coords);
    return texcolor;
}
#endif
