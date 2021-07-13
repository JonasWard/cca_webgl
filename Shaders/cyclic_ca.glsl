uniform float u_time;
uniform vec2 u_resolution;
uniform sampler2D u_currentTexture;
uniform int u_frameCount;
uniform int u_c;
uniform int u_r;
uniform int u_t;
uniform bool u_moore;
uniform int u_paused;
varying vec2 vUv;

float v(float xrel, float yrel) {
    vec2 xy;
    xy.x = mod(gl_FragCoord.x + xrel, u_resolution.x);
    xy.y = mod(gl_FragCoord.y + yrel, u_resolution.y);

    return texture2D(u_currentTexture, xy/u_resolution).r;
}

highp float rand(vec2 co)
{
    // random function
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

float initialize()
{
    float r = rand(gl_FragCoord.xy + vec2(40.0, 2000.0));
    return floor(r * float(u_c) + 1e-10) / float(u_c);
}

int cellState(vec2 delta)
{
    return int((float(u_c) * texture2D(u_currentTexture, vec2(mod(vUv.x + delta.x, 1.0), mod(vUv.y + delta.y, 1.0))).r) + 0.5);
}

bool match(int mid, vec2 delta)
{
    vec2 d = (1.0) / u_resolution;
    if (mid == cellState(delta))
        return true;
    return false;
}

int sumNM(int mid, vec2 d)
{
    // Moore neighborhood
    int sum = 0;
    for (int x = 0; x <= 20; ++x)
    {
        if (x == u_r * 2 + 1)
            break;
        for (int y = 0; y <= 20; ++y)
        {
            if (x == u_r && y == u_r)
                continue;
            if (y == u_r * 2 + 1)
                break;
            if (match(mid, vec2((float(x - u_r)) * d.x, (float(y - u_r)) * d.y)))
                sum += 1;
        }
    }
    return sum;
}

int sumNN(int mid, vec2 d)
{
    // Von Neumann neighborhood
    int sum = 0;
    for (int x = 0; x <= 20; ++x)
    {
        if (x == u_r * 2 + 1)
            break;
        for (int y = 0; y <= 20; ++y)
        {
            if (x == u_r && y == u_r)
                continue;
            if (y == u_r * 2 + 1)
                break;
            if (float(u_r) < (abs(float(x - u_r)) + abs(float(y - u_r))))
                continue;
            if (match(mid, vec2(float(x - u_r) * d.x, float(y - u_r) * d.y)))
                sum += 1;
        }
    }
    return sum;
}

float calc()
{
    vec2 d = (1.0) / u_resolution;

    int cell = cellState(vec2(0.0, 0.0));

    int mid = cell - 1;
    if (mid < 0) mid = u_c - 1;

    int sum = 0;
    if (u_moore)
        sum = sumNN(mid, d);
    else
        sum = sumNM(mid, d);

    if (u_t <= sum)
        cell = mid;

    return float(cell) / float(u_c);
}

void main()
{
    float r = v(0.,0.);
    if (u_frameCount < 2)
        r = initialize();
    else if (u_paused == 1)
        r = calc();

    gl_FragColor = vec4(r, mod(r * 2.6, 1.), mod(r * 6.4, 1.), 1.);
}