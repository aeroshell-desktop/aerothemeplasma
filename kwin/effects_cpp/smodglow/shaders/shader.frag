uniform sampler2D sampler;
uniform float opacity;

varying vec2 texcoord0;

void main()
{
    gl_FragColor = texture2D(sampler, texcoord0) * opacity;
}
