uniform vec2 u_resolution;
// uniform vec3 u_mouse;
uniform sampler2D u_currentTexture;
uniform int u_frameCount;
// uniform float u_mouseSize;
uniform int u_paused;
uniform float u_time;
uniform int u_t;
uniform int u_r;
uniform int u_c;
uniform bool u_moore;
uniform int u_zeros[100];
uniform int u_ones[100];

bool inOnes(int idx) {
for (int i = 0; i < 100; ++i) {
    if (idx == u_ones[i]) {
    return true;
    }
}
return false;
}

bool inZeros(int idx) {
for (int i = 0; i < 100; ++i) {
    if (idx == u_zeros[i]) {
    return true;
    }
}
return false;
}

int pow(int idx) {
int val = 1;
for (int i = 0; i < 100; ++i) {
    if (idx == i) {
    return val;
    }
    val = val * 2;
}
return val;
}

highp float rand(vec2 co)
{
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

float v(float xrel, float yrel) {
    vec2 xy;
    xy.x = mod(gl_FragCoord.x + xrel, u_resolution.x);
    xy.y = mod(gl_FragCoord.y + yrel, u_resolution.y);
    return texture2D(u_currentTexture, xy/u_resolution).a;
}

int count() {
int val = 0;
int idx = 0;
for (int i = -1; i < 2; ++i) {
    for (int j = -1; j < 2; ++j) {
    if ((v(float(i), float(j)) - 1.) < .1) {
        val += pow(idx);
    }
    idx += 1;
    }
}
return val;
}

void main() {
    float minRes = min(u_resolution.x, u_resolution.y);
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / minRes;

if(u_frameCount < 200) {
    //create random initial texture first 2 frames of program
    if (int(gl_FragCoord.x) == int(float(u_resolution.x) / 2.0) && int(gl_FragCoord.y) == int(float(u_resolution.y) / 2.0)) {
    gl_FragColor = vec4(0.0);
    } else {
    gl_FragColor = vec4(1.0);
    }
    }
else if (u_paused == 1) {
    int idx = 2;
    if (inOnes(idx)) {
    gl_FragColor = vec4(0.);
    } else if (inZeros(idx)) {
    gl_FragColor = vec4(1.);
    } else {
    gl_FragColor = vec4(v(0.,0.));
    }
}
}