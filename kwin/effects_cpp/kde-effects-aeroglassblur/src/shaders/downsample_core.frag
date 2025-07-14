#version 140

uniform sampler2D texUnit;
uniform float offset;
uniform vec2 halfpixel;
uniform mat4 colorMatrix;

in vec2 uv;

out vec4 fragColor;

void main(void)
{
    vec2 texSize = 4 * halfpixel.xy;
    vec2 t_uv = (floor(gl_FragCoord.xy) + vec2(0.5, 0.5)) * texSize;

    vec4 sum = texture(texUnit, t_uv) * 4.0;
    sum += texture(texUnit, t_uv - halfpixel.xy * offset);
    sum += texture(texUnit, t_uv + halfpixel.xy * offset);
    sum += texture(texUnit, t_uv + vec2(halfpixel.x, -halfpixel.y) * offset);
    sum += texture(texUnit, t_uv - vec2(halfpixel.x, -halfpixel.y) * offset);

    fragColor = sum / 8.0;
}
