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

    // Dissolve fx
    if (dissolve.w > 0.0 && color.a > 0.0) {
        lowp float burn_size = dissolve.z;
        lowp float burn_value = dissolve.w * (dissolve.w + burn_size);
        lowp float noise = texture2D(texture_sampler, var_noise_texcoord.xy).r;

        if (noise < burn_value) {
            // De-multiply alpha
            color = vec4(color.rgb / color.a, color.a);

            // Grab a color from the ramp
            lowp float ramp_x = min(1.0, (burn_value - noise) / burn_size);
            // Sample with bias -4.0 to get the highest mipmap to reduce artifacts, if you use textures with mipmaps
            lowp vec4 ramp = texture2D(texture_sampler, vec2(ramp_uvrect.x + ramp_uvrect.z * (ramp_x - 0.5), ramp_uvrect.y + ramp_uvrect.w * 0.5), -4.0);

            // Mix
            color.rgb = ramp.rgb;
            color.a = color.a * ramp.a;

            // Pre-multiply alpha again
            color = vec4(color.rgb * color.a, color.a);
        }
    }

    // Pre-multiply tint's alpha since all runtime textures already are
    lowp vec4 tint_pm = vec4(tint.rgb * tint.a, tint.a);
    gl_FragColor = color * tint_pm;
}
