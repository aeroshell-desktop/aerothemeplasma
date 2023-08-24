#version 140

uniform vec4 color;
uniform float opacity;

out vec4 fragColor;

void main(void)
{
    fragColor = color;
    fragColor.a = fragColor.a * opacity;
}
