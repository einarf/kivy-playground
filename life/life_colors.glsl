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

bool cell(vec4 fragment) {
    return length(fragment.xyz) > 0.1;
}

void main (void){
    vec2 uv = gl_FragCoord.xy / vec2(canvas_size);
    vec2 step = 1.0 / vec2(canvas_size);

    vec4 v1 = texture2D(texture1, uv + vec2(-step.x, -step.y));
    vec4 v2 = texture2D(texture1, uv + vec2(0,       -step.y));
    vec4 v3 = texture2D(texture1, uv + vec2(step.x,  -step.y));

    vec4 v4 = texture2D(texture1, uv + vec2(-step.x, 0));
    vec4 v5 = texture2D(texture1, uv);
    vec4 v6 = texture2D(texture1, uv + vec2(step.x,  0));

    vec4 v7 = texture2D(texture1, uv + vec2(-step.x, step.y));
    vec4 v8 = texture2D(texture1, uv + vec2(0,       step.y));
    vec4 v9 = texture2D(texture1, uv + vec2(step.x,  step.y));

    bool living = cell(v5);
    int neighbours = 0;

    if (cell(v1)) neighbours++;
    if (cell(v2)) neighbours++;
    if (cell(v3)) neighbours++;

    if (cell(v4)) neighbours++;
    if (cell(v6)) neighbours++;

    if (cell(v7)) neighbours++;
    if (cell(v8)) neighbours++;
    if (cell(v9)) neighbours++;

    vec4 sum = (v1 + v2 + v3 + v4 + v6 + v7 + v8 + v9) / neighbours;

    if (living) {
        if (neighbours == 2 || neighbours == 3) {
            gl_FragColor = vec4(sum.rgb - vec3(1.0/255.0), 1.0);
        } else {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        }
    } else {
        if (neighbours == 3) {
            gl_FragColor = vec4(normalize(sum.rgb), 1.0);
        } else {
            gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        }
    }
}
