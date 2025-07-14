#version 140

uniform sampler2D texUnit;
uniform float offset;
uniform vec2 halfpixel;
uniform mat4 colorMatrix;

in vec2 uv;

out vec4 fragColor;

void main(void)
{
    /*
     * Create our own UV sample coordinates instead of using
     * the default provided UV maps.
     * We can do this by simply querying gl_FragCoord^ and
     * multiplying it by 2 * halfpixel * [downscale factor]^^
     *
     * ^In the implementation, I first floor this value and then
     * reposition it back to the center of the texel. It feels
     * like this gives better results, although that might just
     * be a placebo.
     *
     * ^^ 2 * halfpixel already is the texture size information
     * that we need. When upscaling, the upscaling factor is just
     * 1/[downscale factor], which cancels out in our case.
     *
     */
    vec2 texSize = 4 * halfpixel.xy;
    vec2 t_uv = (floor(gl_FragCoord.xy) + vec2(0.5, 0.5)) * texSize;

    vec4 sum = texture(texUnit, t_uv) * 4.0;
    sum += texture(texUnit, t_uv - halfpixel.xy * offset);
    sum += texture(texUnit, t_uv + halfpixel.xy * offset);
    sum += texture(texUnit, t_uv + vec2(halfpixel.x, -halfpixel.y) * offset);
    sum += texture(texUnit, t_uv - vec2(halfpixel.x, -halfpixel.y) * offset);

    fragColor = sum / 8.0;
}
