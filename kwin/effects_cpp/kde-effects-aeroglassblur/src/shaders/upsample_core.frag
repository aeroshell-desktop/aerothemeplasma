#version 140

uniform sampler2D texUnit;
uniform float offset;
uniform vec2 halfpixel;

in vec2 uv;

out vec4 fragColor;

void main(void)
{
    vec2 texSize = halfpixel.xy;
    vec2 t_uv = (floor(gl_FragCoord.xy) + vec2(0.5, 0.5)) * texSize;
    vec4 sum = texture(texUnit, t_uv + vec2(-halfpixel.x * 2.0, 0.0) * offset);
    sum += texture(texUnit, t_uv + vec2(-halfpixel.x, halfpixel.y) * offset) * 2.0;
    sum += texture(texUnit, t_uv + vec2(0.0, halfpixel.y * 2.0) * offset);
    sum += texture(texUnit, t_uv + vec2(halfpixel.x, halfpixel.y) * offset) * 2.0;
    sum += texture(texUnit, t_uv + vec2(halfpixel.x * 2.0, 0.0) * offset);
    sum += texture(texUnit, t_uv + vec2(halfpixel.x, -halfpixel.y) * offset) * 2.0;
    sum += texture(texUnit, t_uv + vec2(0.0, -halfpixel.y * 2.0) * offset);
    sum += texture(texUnit, t_uv + vec2(-halfpixel.x, -halfpixel.y) * offset) * 2.0;

    sum /= 12.0;

    fragColor = sum;
}
