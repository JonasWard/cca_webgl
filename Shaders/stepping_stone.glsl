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

highp float rand(vec2 co)
{
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

vec4 v(float xrel, float yrel) {
    vec2 xy;
    xy.x = mod(gl_FragCoord.x + xrel, u_resolution.x);
    xy.y = mod(gl_FragCoord.y + yrel, u_resolution.y);
    return texture2D(u_currentTexture, xy/u_resolution);
}

void main() {
    float minRes = min(u_resolution.x, u_resolution.y);
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / minRes;
vec4 fate = v(0.,0.);
if (u_frameCount < 2) {
    float _rand = random(uv * 1.5 * u_time);
    gl_FragColor = vec4(_rand);
}
else if (u_paused == 1) {
    float _rand = rand(uv * 1.5 * u_time);
    if (_rand < 0.5) {
    float _rand2 = rand(uv * 1. * u_time) * 3.;
    int n = int(sign(_rand2)*floor(abs(_rand2)+.5));
    if (n == 0) {
        gl_FragColor = v(0.,1.);
    } else if (n == 1) {
        gl_FragColor = v(1.,0.);
    } else if (n == 2) {
        gl_FragColor = v(0.,-1.);
    } else if (n == 3) {
        gl_FragColor = v(-1.,0.);
    }
    } else {
    gl_FragColor = vec4(fate.r, fate.g, fate.b, 1.);
    }
} else {
    gl_FragColor = vec4(fate.r, fate.g, fate.b, 1.);
}
}