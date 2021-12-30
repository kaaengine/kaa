@input {
    vec2 v_texcoord0 : TEXCOORD0;
}

// source: https://gist.github.com/Axeltherabbit/f8075aba20096fd2f5b5206d97b9fc8c

#include <kaa.sh>

SAMPLER2D(s_target, 1);

float randi(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float rand(float c) {
    return randi(vec2(c, 1.0));
}

float randomLine(float seed, vec2 uv) {
    float b = 0.01 * rand(seed);
    float a = rand(seed + 1.0);
    float c = rand(seed + 2.0) - 0.5;
    float mu = rand(seed + 3.0);
    float l = 1.0;
    if (mu > 0.2) {
        l = pow(abs(a * uv.x + b * uv.y + c), 1.0 / 8.0);
    } else {
        l = 2.0 - pow(abs(a * uv.x + b * uv.y + c), 1.0 / 8.0);
    }
    return mix(0.5,1.0,l);
}

float randomBlotch(float seed, vec2 uv) {
    float x = rand(seed);
    float y = rand(seed + 1.0);
    float s = 0.01 * rand(seed + 2.0);
    vec2 p = vec2(x, y) - uv;
    float a = atan(p.y / p.x);
    float v = 1.0;
    float ss = s * s * (sin(6.2831 * a * x) * 0.1 + 1.0);
    if (dot(p, p) < ss) {
        v = 0.2;
    } else {
        v = pow(dot(p, p) - ss, 1.0 / 16.0);
    }
    return mix(0.3 + 0.2 * (1.0 - (s / 0.02)), 1.0, v);
}

void main()
{
    vec2 uv = v_texcoord0;
    float t = float(u_dt / 20);
    vec2 suv = uv + 0.00325 * vec2(rand(t), rand(t));
    vec3 image = texture2D(s_target, suv).rgb;
    float luma = dot(vec3(0.2126, 0.7152, 0.0722), image);
    vec3 oldImage = luma * vec3(0.7, 0.7, 0.7);

    float vI = 11.0 * (uv.x * (1.0 - uv.x) * uv.y * (1.0 - uv.y));
    vI *= mix(0.7, 1.0, rand(t + 0.5));
    vI += 1.0 + 0.4 * rand(t);
    vI *= pow(16.0 * uv.x * (1.0 - uv.x) * uv.y * (1.0 - uv.y), 0.4);

    float l = (8.0 * rand(t + 7.0));
    for (float i = 0.0; i < 8.0; i++) {
        if (i < l) {
            vI *= randomLine(t + 6.0 + 17.0 * i, uv);
        }
    }

    float s = (max(8.0 * rand(t + 18.0) - 2.0, 0.0));
    for (float i = 0.0; i < 6.0; i++) {
        if (i < s) {
            vI *= randomBlotch(t + 6.0 + 19.0 * i, uv);
        }
    }

    gl_FragColor.rgb = oldImage * vI;
    gl_FragColor *= (1.0 + (randi(uv + vec2(t * 0.01)) - 0.2) * 0.185);
    gl_FragColor.a = 1.0;
}
