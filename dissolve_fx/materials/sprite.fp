varying mediump vec2 var_texcoord0;
varying mediump vec2 var_noise_coord;

uniform lowp sampler2D texture0;
uniform lowp sampler2D texture1;
uniform lowp sampler2D texture2;

uniform lowp vec4 tint;
uniform lowp vec4 dissolve;

float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float gennoise(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

float fbm(vec3 x) {
    float v = 0.0;
    float a = 0.5;
    vec3 shift = vec3(100);
    for (int i = 0; i < 5; ++i) {
        v += a * gennoise(x);
        x = x * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void main()
{
    // lowp vec4 tex_color = texture2D(texture0, var_texcoord0.xy);
    // lowp vec4 noise = texture2D(texture1, var_noise_coord.xy + dissolve.xy).r;
    lowp float noise = fbm(vec3(var_noise_coord.xy * 20.0, 0.0));

    gl_FragColor = vec4(noise, noise, noise, 1.0);

    // lowp float test = noise - dissolve.w;

    // // Do we really need that?
    // lowp vec4 color = vec4(tex_color.rgb / tex_color.a, tex_color.a);

    // lowp float burn_size = 0.15;
    // if (test < burn_size && dissolve.w > 0.0) {
    //     lowp float test_n = test * (1.0 / burn_size);
    //     lowp vec4 ramp = texture2D(texture2, vec2(1.0 - test_n, 0.5));
    //     color.rgb = mix(color.rgb, ramp.rgb / ramp.a, ramp.a);
    //     // color.a = clamp(color.a * test_n, 0.0, 1.0);
    //     color.a = clamp(color.a * test_n * 2.0, 0.0, 1.0);
    // }

    // // Pre-multiply alpha since all runtime textures already are
    // lowp vec4 tint_pm = vec4(tint.xyz * tint.w, tint.w);

    // lowp vec4 color_pm = vec4(color.rgb * color.w, color.w);
    // gl_FragColor = color_pm * tint_pm;
}
