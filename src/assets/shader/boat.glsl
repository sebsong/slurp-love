#pragma language glsl3

uniform float VERTICAL_FREQ;
uniform float VERTICAL_SPEED;
uniform float VERTICAL_AMPLITUDE;

uniform vec2 cameraCanvasDimensions;
uniform vec2 cameraPosition;
uniform float time;

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
