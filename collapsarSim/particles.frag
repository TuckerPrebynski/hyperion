#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D rampTex;
varying vec4 vCol;

void main() {
    vec3 col = texture2D(rampTex, vec2(vCol.r, 0.0)).rgb;
    gl_FragColor = vec4(col, 1.0);
}