varying highp vec2 var_texcoord0;
varying mediump vec2 var_noise_texcoord;

uniform lowp sampler2D texture_sampler;

uniform mediump vec4 tint;
uniform mediump vec4 dissolve;
uniform mediump vec4 ramp_uvrect;

void main()
{
    // Sample sprite's color
    lowp vec4 color = texture2D(texture_sampler, var_texcoord0.xy);

    // Dissolve effect
    if (dissolve.w > 0.0 && color.a > 0.0) {
        lowp float burn_size = dissolve.z;
        lowp float burn_value = dissolve.w * (dissolve.w + burn_size);
        lowp float noise = texture2D(texture_sampler, var_noise_texcoord.xy).r;

        if (noise < burn_value) {
            // Grab a color from the ramp
            lowp float ramp_x = min(1.0, (burn_value - noise) / burn_size);
            highp vec2 ramp_texcoord = vec2(ramp_uvrect.x, ramp_uvrect.y);
            if (ramp_uvrect.z > ramp_uvrect.w) {
                ramp_texcoord += vec2(ramp_uvrect.z * (ramp_x - 0.5), ramp_uvrect.w * 0.5);
            } else {
                // In case the atlas builder has flipped the sprite to optimise the space.
                ramp_texcoord += vec2(ramp_uvrect.z * 0.5, ramp_uvrect.w * -(ramp_x - 0.5));
            }
            // Sample with bias -8.0 to get the highest mipmap to reduce artifacts (if you use textures with mipmaps)
            lowp vec4 ramp = texture2D(texture_sampler, ramp_texcoord, -8.0);

            // Mix
            color.rgb = ramp.rgb;
            color.a *= ramp.a;
        }
    }

    // Pre-multiply tint's alpha since all runtime textures already are
    lowp vec4 tint_pm = vec4(tint.rgb * tint.a, tint.a);
    gl_FragColor = color * tint_pm;
}
