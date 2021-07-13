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
float feed = .0367;
float kill = .0649;
float delta = 1.;
uniform int u_w;
uniform int u_h;
float dA = 1.0;
float dB = 0.4;

vec2 v(float xrel, float yrel) {
    vec2 xy;
    xy.x = mod(gl_FragCoord.x + xrel, u_resolution.x);
    xy.y = mod(gl_FragCoord.y + yrel, u_resolution.y);

    return texture2D(u_currentTexture, xy/u_resolution).rg;
}

void main() {

if(u_frameCount < 20) //create random initial texture first 2 frames of program
    {
    if (abs(gl_FragCoord.x - float(u_w) / 2.) < 10. && abs(gl_FragCoord.y - float(u_h) / 2.) < 10.) {
    for (int i = 0; i < 10; ++i) {
        for (int j = 0; j < 10; ++j) {
        gl_FragColor = vec4(1., 1., 0., 1.);
        }
    }
    } else {
    gl_FragColor = vec4(1., 0., 0., 1.);
    }
    }
else if (u_paused == 1) {
    vec2 uv = v(0.,0.);
    vec2 uv0 = v(-1.,0.);
    vec2 uv1 = v(1.,0.);
    vec2 uv2 = v(0.,-1.);
    vec2 uv3 = v(0.,1.);
    vec2 uv4 = v(-1.,-1.);
    vec2 uv5 = v(1.,1.);
    vec2 uv6 = v(1.,-1.);
    vec2 uv7 = v(-1.,1.);

    vec2 lapl = (uv0 * .2 + uv1 * .2  + uv2 * .2  + uv3 * .2 + uv4 * .05 + uv5 * .05 + uv6 * .05 + uv7 * .05 - uv);//10485.76;
    float du = /*0.00002*/dA*lapl.r - uv.r*uv.g*uv.g + feed*(1.0 - uv.r);
    float dv = /*0.00001*/dB*lapl.g + uv.r*uv.g*uv.g - (feed+kill)*uv.g;
    vec2 dst = uv + 1.*vec2(du, dv);
    gl_FragColor = vec4(dst.r, dst.g, 0.0, 1.0);
}

}