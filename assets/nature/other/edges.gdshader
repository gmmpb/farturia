shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

/* OUTLINE controls */
uniform float   outline_thresh  = 0.38;                 // where black line starts
uniform float   outline_soft    = 0.15;                 // 0 = hard
uniform vec4    outline_color   = vec4(0.0,0.0,0.0,1.0); // black

/* HIGHLIGHT controls */
uniform float   glow_thresh     = 0.48;                 // > outline_thresh
uniform float   glow_soft       = 0.25;
uniform float   glow_boost      = 0.15;                 // 0-1 brightness
uniform vec3    glow_tint       = vec3(1.0);            // white

/* helpers */
float lum(vec3 c){ return dot(c, vec3(0.299,0.587,0.114)); }

void fragment(){
    vec2 px = 1.0 / vec2(textureSize(SCREEN_TEXTURE,0));

    /* Sobel luminance ------------------------------------------------ */
    float s00=lum(texture(SCREEN_TEXTURE,SCREEN_UV+px*vec2(-1,-1)).rgb);
    float s10=lum(texture(SCREEN_TEXTURE,SCREEN_UV+px*vec2( 0,-1)).rgb)*2.0;
    float s20=lum(texture(SCREEN_TEXTURE,SCREEN_UV+px*vec2( 1,-1)).rgb);

    float s01=lum(texture(SCREEN_TEXTURE,SCREEN_UV+px*vec2(-1, 0)).rgb)*2.0;
    float s21=lum(texture(SCREEN_TEXTURE,SCREEN_UV+px*vec2( 1, 0)).rgb)*2.0;

    float s02=lum(texture(SCREEN_TEXTURE,SCREEN_UV+px*vec2(-1, 1)).rgb);
    float s12=lum(texture(SCREEN_TEXTURE,SCREEN_UV+px*vec2( 0, 1)).rgb)*2.0;
    float s22=lum(texture(SCREEN_TEXTURE,SCREEN_UV+px*vec2( 1, 1)).rgb);

    float gx=(s20+s21+s22)-(s00+s01+s02);
    float gy=(s02+s12+s22)-(s00+s10+s20);
    float edge = length(vec2(gx,gy));                    /* 0-1 strength */
    /* --------------------------------------------------------------- */

    vec3 base = texture(SCREEN_TEXTURE,SCREEN_UV).rgb;

    /* highlight first (soft add) */
    float g = smoothstep(glow_thresh, glow_thresh+glow_soft, edge);
    base = mix(base, base + glow_tint*glow_boost, g);

    /* black outline last (overrides highlight at extreme edge) */
    float o = smoothstep(outline_thresh, outline_thresh+outline_soft, edge);
    vec3  final = mix(base, outline_color.rgb, o);

    COLOR = vec4(final,1.0);
}
