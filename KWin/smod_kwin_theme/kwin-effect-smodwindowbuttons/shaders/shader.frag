uniform sampler2D sampler;
uniform float opacity;

varying vec2 texcoord0;

void main()
{
    //vec4 tex = texture2D(sampler, texcoord0);
    //tex *= opacity;
    //gl_FragColor = tex;
    gl_FragColor = texture2D(sampler, texcoord0) * opacity;
}
