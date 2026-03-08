#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D rampTex;

varying vec2 texCoord;
varying vec4 vCol;

void main() {
    float dist = dot(texCoord, texCoord);

    if (dist > 1.0) discard;

    // Soft glow falloff
    float alpha = 1.0 - dist;
    alpha *= alpha;

    // Sample color ramp using temperature (packed in red channel)
    vec3 col = texture2D(rampTex, vec2(vCol.r, 0.5)).rgb;

    gl_FragColor = vec4(col, vCol.a * alpha);
}