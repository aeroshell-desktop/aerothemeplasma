#version 140

uniform sampler2D texUnit;
uniform float offset;
uniform vec2 halfpixel;

uniform float aeroColorR;
uniform float aeroColorG;
uniform float aeroColorB;
uniform float aeroColorA;
uniform float aeroColorBalance;
uniform float aeroAfterglowBalance;
uniform float aeroBlurBalance;

uniform mat4 colorMatrix;

in vec2 uv;

out vec4 fragColor;

void main(void)
{
    vec4 sum = texture(texUnit, uv + vec2(-halfpixel.x * 2.0, 0.0) * offset);
    sum += texture(texUnit, uv + vec2(-halfpixel.x, halfpixel.y) * offset) * 2.0;
    sum += texture(texUnit, uv + vec2(0.0, halfpixel.y * 2.0) * offset);
    sum += texture(texUnit, uv + vec2(halfpixel.x, halfpixel.y) * offset) * 2.0;
    sum += texture(texUnit, uv + vec2(halfpixel.x * 2.0, 0.0) * offset);
    sum += texture(texUnit, uv + vec2(halfpixel.x, -halfpixel.y) * offset) * 2.0;
    sum += texture(texUnit, uv + vec2(0.0, -halfpixel.y * 2.0) * offset);
    sum += texture(texUnit, uv + vec2(-halfpixel.x, -halfpixel.y) * offset) * 2.0;

    sum /= 12.0;
    vec4 color = vec4(aeroColorR, aeroColorG, aeroColorB, aeroColorA);
    color *= colorMatrix;
    vec3 primaryColor   = color.rgb;
    vec3 secondaryColor = color.rgb;
    vec3 primaryLayer   = primaryColor * aeroColorBalance; //pow(aeroColorBalance, 1.1);
    vec3 secondaryLayer = (secondaryColor * dot(sum.xyz, vec3(0.299, 0.587, 0.114))) * aeroAfterglowBalance;
    vec3 blurLayer      = sum.xyz * aeroBlurBalance;

    fragColor = vec4(primaryLayer + secondaryLayer + blurLayer, 1.0);

}
