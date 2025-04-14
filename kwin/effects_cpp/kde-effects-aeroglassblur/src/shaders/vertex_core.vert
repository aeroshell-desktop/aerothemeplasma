#version 140

uniform mat4 modelViewProjectionMatrix;
//TODO: Add transformProjectionMatrix
//TODO: Add deviceBackgroundRect
//TODO: Make separate shader just for transformed windows

in vec2 position;
in vec2 texcoord;

out vec2 uv;

void main(void)
{
    vec4 pos = modelViewProjectionMatrix * vec4(position, 0.0, 1.0);
    gl_Position = pos;
    //float u = pos.x / deviceBackgroundRect.width();
    //float v = 1.0f - transformed.y() / deviceBackgroundRect.height();

    uv = texcoord;//vec2(temp.x, temp.y);
}
