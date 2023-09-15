varying highp vec2 var_texcoord0;
varying mediump vec2 var_noise_texcoord;
// varying mediump vec2 var_ramp_texcoord;

uniform lowp sampler2D texture_sampler;

uniform mediump vec4 tint;
uniform mediump vec4 dissolve;

uniform mediump vec4 ramp_uvrect;

void main()
{
    lowp vec4 color = texture2D(texture_sampler, var_texcoord0.xy);

    lowp float burn_size = 0.25;
    if (dissolve.w > 0.0 && color.a > 0.0) {
        lowp float noise = texture2D(texture_sampler, var_noise_texcoord.xy).r;
        lowp float test = noise - dissolve.w;

        if (test < burn_size) {
            // De-multiply alpha
            color = vec4(color.rgb / color.a, color.a);

            // Dissolve!
            lowp float test_n = test * (1.0 / burn_size);
            lowp vec4 ramp = texture2D(texture_sampler, vec2(ramp_uvrect.x + ramp_uvrect.z * (clamp(1.0 - test_n, 0.0, 1.0) - 0.5), ramp_uvrect.y + ramp_uvrect.w * 0.5));
            // color.rgb = ramp.rgb;

            color.rgb = mix(color.rgb, ramp.rgb, ramp.a);
            color.a = clamp(color.a * test_n, 0.0, 1.0);

            // Pre-multiply alpha again
            color = vec4(color.rgb * color.a, color.a);
        }
    }

    // Pre-multiply tint's alpha since all runtime textures already are
    lowp vec4 tint_pm = vec4(tint.rgb * tint.a, tint.a);
    gl_FragColor = color * tint_pm;
}
