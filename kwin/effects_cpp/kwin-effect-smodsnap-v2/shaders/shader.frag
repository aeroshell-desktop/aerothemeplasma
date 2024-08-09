uniform sampler2D sampler;

varying vec2 texcoord0;

void main()
{
    gl_FragColor = texture2D(sampler, texcoord0);
}
