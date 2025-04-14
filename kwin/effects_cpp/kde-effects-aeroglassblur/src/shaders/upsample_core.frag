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
uniform bool  aeroColorize;
uniform bool  basicColorization;

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

    if (aeroColorize)
    {
        vec4 color = vec4(aeroColorR, aeroColorG, aeroColorB, aeroColorA);

        if(basicColorization)
        {
            //color = vec4(aeroColorR, aeroColorG, aeroColorB, aeroColorBalance);
            vec4 baseColor = vec4(sum.x, sum.y, sum.z, 1.0 - aeroColorBalance);
            if(aeroColorA != -1.0) // Transparency is disabled
            {
                baseColor = vec4(0.871, 0.871, 0.871, 1.0 - aeroColorA);
                color = vec4(aeroColorR, aeroColorG, aeroColorB, aeroColorA);
                fragColor = vec4(color.r * color.a + baseColor.r * baseColor.a,
                             color.g * color.a + baseColor.g * baseColor.a,
                             color.b * color.a + baseColor.b * baseColor.a, 1.0);
                fragColor *= colorMatrix;
            }
            else
            {
                baseColor = vec4(sum.x, sum.y, sum.z, 1.0 - aeroColorBalance);
                color = vec4(aeroColorR, aeroColorG, aeroColorB, aeroColorBalance);
                color *= colorMatrix;
                fragColor = vec4(color.r * color.a + baseColor.r * baseColor.a,
                             color.g * color.a + baseColor.g * baseColor.a,
                             color.b * color.a + baseColor.b * baseColor.a, 1.0);
            }

        }
        else
        {
            if(aeroColorA != -1.0) // Transparency is disabled
            {
                vec4 baseColor = vec4(0.871, 0.871, 0.871, 1.0 - aeroColorA);
                fragColor = vec4(color.r * color.a + baseColor.r * baseColor.a,
                                 color.g * color.a + baseColor.g * baseColor.a,
                                 color.b * color.a + baseColor.b * baseColor.a, 1.0);
                fragColor *= colorMatrix;
            }
            else
            {
                color *= colorMatrix;
                vec3 primaryColor   = color.rgb;
                vec3 secondaryColor = color.rgb;
                vec3 primaryLayer   = primaryColor * pow(aeroColorBalance, 1.1);
                vec3 secondaryLayer = (secondaryColor * dot(sum.xyz, vec3(0.299, 0.587, 0.114))) * aeroAfterglowBalance;
                vec3 blurLayer      = sum.xyz * aeroBlurBalance;

                fragColor = vec4(primaryLayer + secondaryLayer + blurLayer, 1.0);
            }
        }

	//fragColor = vec4(blurLayer, 1.0);
    }
    else
    {
        fragColor = sum;
    }

}
