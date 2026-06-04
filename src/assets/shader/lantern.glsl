#pragma language glsl3

uniform float VERTICAL_FREQ;
uniform float VERTICAL_SPEED;
uniform float VERTICAL_AMPLITUDE;
const int COLOR_PALETTE_SIZE = 8;
uniform vec4 colorPalette[COLOR_PALETTE_SIZE];
uniform int colorMapping[COLOR_PALETTE_SIZE];
uniform vec2 canvasDimensions;

uniform vec2 cameraCanvasDimensions;
uniform vec2 cameraPosition;
uniform float time;

uniform Image canvasImage;

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
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 lanternTexColor = Texel(tex, texture_coords);
    vec4 canvasTexColor = Texel(canvasImage, screen_coords / canvasDimensions); // TODO: might need tweaking when canvas size is not screen size?

    if (lanternTexColor.a != 0) {
        int colorIdx = 0;
        for (int i = 0; i < COLOR_PALETTE_SIZE; i++) {
            if (canvasTexColor == colorPalette[i]) {
                colorIdx = i;
                break;
            }
        }
        return colorPalette[colorMapping[colorIdx]];
    }

    return canvasTexColor;
}
#endif
