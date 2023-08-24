uniform sampler2D texUnit;
uniform float opacity;
uniform float translate;
uniform vec2 screenResolution;
uniform vec2 windowSize;

uniform vec2 windowPos;

void main(void)
{

    float middleLine = windowPos.x + windowSize.x / 2.0;
    float middleScreenLine = screenResolution.x / 2.0;
    float dx = translate * (middleScreenLine - middleLine) / 10.0;

    float x = (gl_FragCoord.x + dx) / screenResolution.x;
    float y = (gl_FragCoord.y) / screenResolution.y;

    vec2 uv = vec2(-x, y);

    gl_FragColor = vec4(texture2D(texUnit, uv).rgba);

    gl_FragColor.a = gl_FragColor.a * opacity;
}
