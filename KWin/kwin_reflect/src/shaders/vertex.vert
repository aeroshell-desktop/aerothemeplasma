uniform mat4 modelViewProjectionMatrix;
attribute vec4 vertex;

void main(void)
{
    gl_Position = modelViewProjectionMatrix * vertex;
}
