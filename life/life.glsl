---VERTEX SHADER-------------------------------------------------------
#ifdef GL_ES
    precision highp float;
#endif

attribute vec2 v_pos;

void main (void) {
    gl_Position = vec4(v_pos, 0.0, 1.0);
}

---FRAGMENT SHADER-----------------------------------------------------
#ifdef GL_ES
    precision highp float;
#endif

uniform ivec2 canvas_size;
uniform sampler2D texture1;

bool cell(vec2 pos) {
    return texture2D(texture1, pos).r > 0.5;
}

void main (void){
    vec2 uv = gl_FragCoord.xy / vec2(canvas_size);
    vec2 step = 1.0 / vec2(canvas_size);

    bool living = cell(uv);
    int neighbours = 0;

    if (cell(uv + vec2(-step.x, -step.y))) neighbours++;
    if (cell(uv + vec2(0,       -step.y))) neighbours++;
    if (cell(uv + vec2(step.x,  -step.y))) neighbours++;

    if (cell(uv + vec2(-step.x, 0))) neighbours++;
    if (cell(uv + vec2(step.x,  0))) neighbours++;

    if (cell(uv + vec2(-step.x, step.y))) neighbours++;
    if (cell(uv + vec2(0,       step.y))) neighbours++;
    if (cell(uv + vec2(step.x,  step.y))) neighbours++;

    if (living) {
        if (neighbours == 2 || neighbours == 3) {
            gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
        } else {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        }
    } else {
        if (neighbours == 3) {
            gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
        } else {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        }
    }
}
