#version 140

uniform mat4 modelViewProjectionMatrix;
in vec4 vertex;

void main(void)
{
    gl_Position = modelViewProjectionMatrix * vertex;
}
