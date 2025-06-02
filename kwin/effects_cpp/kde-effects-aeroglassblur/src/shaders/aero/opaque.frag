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

varying vec2 uv;

void main(void)
{
    vec4 color = vec4(aeroColorR, aeroColorG, aeroColorB, aeroColorA);
    vec4 baseColor = vec4(0.871, 0.871, 0.871, 1.0 - aeroColorA);
    gl_FragColor = vec4(color.r * color.a + baseColor.r * baseColor.a,
                     color.g * color.a + baseColor.g * baseColor.a,
                     color.b * color.a + baseColor.b * baseColor.a, 1.0);
    gl_FragColor *= colorMatrix;
}
