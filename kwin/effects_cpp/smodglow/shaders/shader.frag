uniform sampler2D sampler;
uniform float opacity;
uniform float bordertop;
uniform float borderleft;

uniform vec2 targetrect;
uniform vec2 texturerect;
uniform mat4 colorMatrix;

varying vec2 texcoord0;

float map(float value, float originalMin, float originalMax, float newMin, float newMax) {
    return (value - originalMin) / (originalMax - originalMin) * (newMax - newMin) + newMin;
}

float processAxis(float coord, float textureBorder, float windowBorder) {
    if (coord < windowBorder)
        return map(coord, 0, windowBorder, 0, textureBorder) ;
    if (coord < 1 - windowBorder)
        return map(coord,  windowBorder, 1 - windowBorder, textureBorder, 1 - textureBorder);
    return map(coord, 1 - windowBorder, 1, 1 - textureBorder, 1);
}

void main()
{
    vec2 u_dimensions = vec2(borderleft / targetrect.x, bordertop / targetrect.y);
    vec2 u_borders = vec2(borderleft / texturerect.x, bordertop / texturerect.y);
    vec2 newUV = vec2(
        processAxis(texcoord0.x, u_borders.x, u_dimensions.x),
        processAxis(texcoord0.y, u_borders.y, u_dimensions.y)
    );

    gl_FragColor = texture2D(sampler, newUV) * opacity;
    gl_FragColor *= colorMatrix;
}
