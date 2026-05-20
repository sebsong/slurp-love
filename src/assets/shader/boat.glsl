#pragma language glsl3

uniform float seed;
uniform float time;
uniform vec2 cameraCanvasDimensions;
vec2 pixelDimensions = vec2(1.0, 1.0) / cameraCanvasDimensions;
uniform vec2 cameraPosition;

const float VERTICAL_FREQ = 13;
const float VERTICAL_SPEED = -1;
const float VERTICAL_AMPLITUDE = .01;

float random(vec2 st) {
    return fract(
        sin(dot(st.xy, vec2(12.9898, 78.233)) * seed) * 43758.5453123
    );
}

#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position) {
    vec2 cameraCoords = (cameraPosition / cameraCanvasDimensions);
    vec2 textureCoords = cameraCoords + 0.5;
    vec4 pos = transform_projection * vertex_position;
    pos.y += sin(textureCoords.y * VERTICAL_FREQ + time * VERTICAL_SPEED) * VERTICAL_AMPLITUDE;
    return pos;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec4 boatTexColor = Texel(tex, texture_coords);
    return boatTexColor;
}
#endif
