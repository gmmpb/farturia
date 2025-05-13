shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

uniform float thresh      = 0.4;                      // edge threshold
uniform float softness    = 0.2;                      // fade blend
uniform vec4  outline_col = vec4(0.0, 0.0, 0.0, 1.0); // black line

float luma(vec3 c) { return dot(c, vec3(0.299, 0.587, 0.114)); }

void fragment() {
    vec2 texel = 1.0 / vec2(textureSize(SCREEN_TEXTURE, 0));

    float c00 = luma(texture(SCREEN_TEXTURE, SCREEN_UV + texel * vec2(-1.0,-1.0)).rgb);
    float c10 = luma(texture(SCREEN_TEXTURE, SCREEN_UV + texel * vec2( 0.0,-1.0)).rgb) * 2.0;
    float c20 = luma(texture(SCREEN_TEXTURE, SCREEN_UV + texel * vec2( 1.0,-1.0)).rgb);

    float c01 = luma(texture(SCREEN_TEXTURE, SCREEN_UV + texel * vec2(-1.0, 0.0)).rgb) * 2.0;
    float c21 = luma(texture(SCREEN_TEXTURE, SCREEN_UV + texel * vec2( 1.0, 0.0)).rgb) * 2.0;

    float c02 = luma(texture(SCREEN_TEXTURE, SCREEN_UV + texel * vec2(-1.0, 1.0)).rgb);
    float c12 = luma(texture(SCREEN_TEXTURE, SCREEN_UV + texel * vec2( 0.0, 1.0)).rgb) * 2.0;
    float c22 = luma(texture(SCREEN_TEXTURE, SCREEN_UV + texel * vec2( 1.0, 1.0)).rgb);

    float gx = (c20 + c21 + c22) - (c00 + c01 + c02);
    float gy = (c02 + c12 + c22) - (c00 + c10 + c20);
    float edge = length(vec2(gx, gy));

    float mask = smoothstep(thresh, thresh + softness, edge);
    vec3 col = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
    COLOR = mix(vec4(col, 1.0), outline_col, mask);
}
