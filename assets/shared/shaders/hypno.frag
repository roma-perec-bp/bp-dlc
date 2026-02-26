#pragma header

uniform float iTime;
uniform float alphaShitLmao;

#define SPEED 5
#define RAYS 10
#define RING_PERIOD 80.0
#define TWIST_FACTOR 2

float getColorComponent(float dist, float angle) {
    return pow(((cos((angle * RAYS) + pow(dist * 2.0, (sin(iTime * SPEED) * TWIST_FACTOR)) * 20.0) + sin(dist * RING_PERIOD)) + 2.0) / 2.0, 10.0);
}

void main() {
    vec2 uv = openfl_TextureCoordv;
    vec2 delta = (uv - 0.5) * 2.0;
    delta.x *= openfl_TextureSize.x / openfl_TextureSize.y;
    
    float dist = length(delta);
    float angle = atan(delta.x, delta.y);
    
    gl_FragColor = vec4(
        min(getColorComponent(dist, angle), 1.) * alphaShitLmao,
        min(getColorComponent(dist, angle), 1.) * alphaShitLmao,
        min(getColorComponent(dist, angle), 1.) * alphaShitLmao,
       alphaShitLmao
    );
}