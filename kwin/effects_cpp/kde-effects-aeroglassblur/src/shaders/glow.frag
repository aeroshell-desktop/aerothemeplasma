uniform sampler2D texUnit;

varying vec2 texcoord;

void main()
{
    gl_FragColor = texture2D(texUnit, texcoord);
}
