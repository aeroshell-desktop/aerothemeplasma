#version 140

uniform sampler2D texUnit;
uniform float opacity;
uniform vec2 windowSize;
uniform vec2 textureSize;
uniform vec2 windowPos;
uniform bool scaleY;
uniform mat4 colorMatrix;

in vec2 uv;

out vec4 fragColor;

void main(void)
{
    float xpos = clamp((gl_FragCoord.x - windowPos.x) / windowSize.x, 0, 1);

    float t_x = uv.x;
    if(xpos > 0.5) t_x = 1 - uv.x;
    else t_x = uv.x;

    float t_y = uv.y;
    if(scaleY) t_y = uv.y * windowSize.y;
    else t_y = uv.y;
    vec2 t_uv = vec2(windowSize.x * t_x / textureSize.x, windowSize.y * (1 - t_y) / textureSize.y);

    //fragColor = texture(sampler, newUV) * opacity;

    vec4 result = texture2D(texUnit, t_uv) * opacity;

    fragColor = result;
    fragColor *= colorMatrix;
}

