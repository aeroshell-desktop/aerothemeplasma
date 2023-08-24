uniform vec4 color;
uniform float opacity;

void main(void)
{
    gl_FragColor = color;
    gl_FragColor.a = gl_FragColor.a * opacity;
}
