uniform sampler2D texUnit;
uniform float opacity;
uniform float translate;
uniform vec2 screenResolution;
uniform vec2 windowSize;
uniform mat4 colorMatrix;

uniform vec2 windowPos;

void main(void)
{

    float middleLine = windowPos.x + windowSize.x / 2.0;
    float middleScreenLine = screenResolution.x / 2.0;
    float dx = translate * (middleScreenLine - middleLine) / 10.0;

    float x = (gl_FragCoord.x + dx) / screenResolution.x;
    float y = (gl_FragCoord.y) / screenResolution.y;

    vec2 uv = vec2(x, -y);

    vec4 result = vec4(texture2D(texUnit, uv).rgba);
    result.a *= opacity;

    gl_FragColor = result;
    gl_FragColor *= colorMatrix;

    //gl_FragColor.a = gl_FragColor.a * opacity;
}
