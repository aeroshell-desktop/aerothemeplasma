#version 140

uniform sampler2D sampler;
uniform float opacity;

in vec2 texcoord0;
out vec4 fragColor;

void main()
{
    //vec4 tex = texture(sampler, texcoord0);
    //tex *= opacity;
    //fragColor = tex;
    fragColor = texture(sampler, texcoord0) * opacity;
}
