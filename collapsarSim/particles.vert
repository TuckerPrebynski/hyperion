#define PROCESSING_POINT_SHADER

uniform mat4 projection;
uniform mat4 modelview;

uniform vec4 viewport;
uniform int perspective;
uniform float weight;

attribute vec4 vertex;
attribute vec4 color;
attribute vec2 offset;

varying vec2 texCoord;
varying vec4 vCol;

void main() {
    vec4 pos = modelview * vertex;
    vec4 clip = projection * pos;

    if (perspective == 1) {
        gl_Position = clip + projection * vec4(offset, 0, 0);
    } else {
        gl_Position = clip;
        gl_Position.xy += offset.xy;
    }

    // Normalize offset to -1..1 range for glow falloff in frag shader
    // Processing sends offset in half-pixel units, so divide by half the weight
    texCoord = offset / (weight * 0.5);

    vCol = color;
}