#version 140

uniform sampler2D texUnit;
uniform float opacity;
uniform float translate;
uniform vec2 screenResolution;
uniform vec2 windowSize;

uniform vec2 windowPos;

out vec4 fragColor;

void main(void)
{
    float middleLine = windowPos.x + windowSize.x / 2.0;
    float middleScreenLine = screenResolution.x / 2.0;
    float dx = translate * (middleScreenLine - middleLine) / 10.0;

    float x = (gl_FragCoord.x + dx) / screenResolution.x;
    float y = (gl_FragCoord.y) / screenResolution.y;

    vec2 uv = vec2(x, -y);

    vec4 result = texture(texUnit, uv) * opacity;
    //result.a *= opacity;
    fragColor = result;
    //fragColor.a = fragColor.a * opacity;

}
