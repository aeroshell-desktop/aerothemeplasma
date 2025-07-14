#version 140

uniform sampler2D texUnit;
uniform float opacity;
uniform float translate;
uniform vec2 screenResolution;
uniform vec2 windowSize;
uniform mat4 colorMatrix;
uniform vec2 windowPos;

// Glow
uniform vec2 textureSize;
uniform bool useWayland;
uniform sampler2D glowTexture;
uniform bool glowEnable;
uniform float glowOpacity;

in vec2 uv;

out vec4 fragColor;

vec4 glowFragment()
{
    float xpos = clamp((gl_FragCoord.x - windowPos.x) / windowSize.x, 0, 1);

    float t_x = uv.x;

    float t_y;
    if(useWayland) {
        t_y = clamp(((gl_FragCoord.y) - windowPos.y) / textureSize.y, 0, 1);
    } else {
        t_y = clamp(((screenResolution.y - gl_FragCoord.y) - windowPos.y) / textureSize.y, 0, 1);
    }
    vec2 t_uv = vec2(windowSize.x * t_x / textureSize.x, t_y);

    vec4 result = texture2D(glowTexture, t_uv) * glowOpacity;

    // Grab from the other side as well
    t_x = 1 - uv.x;
    t_uv = vec2(windowSize.x * t_x / textureSize.x, t_y);
    result += texture2D(glowTexture, t_uv) * glowOpacity;
    return result;
}

void main(void)
{
    float middleLine = windowPos.x + windowSize.x / 2.0;
    float middleScreenLine = screenResolution.x / 2.0;
    float dx = translate * (middleScreenLine - middleLine) / 10.0;

    float x = (gl_FragCoord.x + dx) / screenResolution.x;
    float y = (gl_FragCoord.y) / screenResolution.y;

    vec2 t_uv = vec2(x, -y);

    vec4 result = texture(texUnit, t_uv) * opacity;
    //result.a *= opacity;
    if(glowEnable)
    {
        result += glowFragment();
    }
    fragColor = result;

    fragColor *= colorMatrix;
    //fragColor.a = fragColor.a * opacity;

}
