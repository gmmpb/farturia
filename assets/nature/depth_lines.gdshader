shader_type spatial;
render_mode unshaded, depth_draw_opaque, depth_prepass_alpha;

// buffers
uniform sampler2D DEPTH_TEXTURE  : hint_depth_texture,            filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture,           filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;

// tweak these
uniform float shadow_thickness = 2.0;    // outline radius in pixels
uniform float darken_factor    = 0.5;    // 0 = no darkening, 1 = full black
uniform float edge_strength    = 1.0;    // how strongly to apply the edge mask

vec2 getDepth(vec2 screen_uv, sampler2D depth_texture, mat4 inv_proj){
    float raw = texture(depth_texture, screen_uv).r;
    vec3 ndc = vec3(screen_uv * 2.0 - 1.0, raw);
    vec4 view = inv_proj * vec4(ndc, 1.0);
    view.xyz /= view.w;
    return vec2(-view.z, raw);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 px = vec2(1.0 / VIEWPORT_SIZE.x, 1.0 / VIEWPORT_SIZE.y);
    
    // fetch center data
    vec3 orig_color = texture(SCREEN_TEXTURE, uv).rgb;
    vec2  d0 = getDepth(uv, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
    vec3  n0 = texture(NORMAL_TEXTURE, uv).rgb * 2.0 - 1.0;

    float edge = 0.0;
    vec2 min_d = d0;
    float best = 1e9;
    vec3  sample_color;

    // gather samples
    for (float x = -shadow_thickness; x <= shadow_thickness; x += 1.0) {
      for (float y = -shadow_thickness; y <= shadow_thickness; y += 1.0) {
        if ((x==0. && y==0.) || (x*x + y*y > shadow_thickness*shadow_thickness))
          continue;

        vec2 off = vec2(x,y) * px;
        vec2 d1 = getDepth(uv + off, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
        vec3 n1 = texture(NORMAL_TEXTURE, uv + off).rgb * 2.0 - 1.0;

        // depth edge term
        edge += step(0.02, abs(d0.x - d1.x));

        // normal edge term
        edge += (1.0 - dot(n0, n1));

        // track closest depth for correct depth write
        if (d1.x < best) {
          best = d1.x;
          min_d = d1;
          sample_color = texture(SCREEN_TEXTURE, uv + off).rgb;
        }
      }
    }

    // normalize & smooth
    edge = smoothstep(0.0, 1.0, edge * 0.25 * edge_strength);

    // darken the sampled neighbor color
    vec3 dark = sample_color * (1.0 - darken_factor);

    // blend original → dark edge
    ALBEDO = mix(orig_color, dark, edge);

    // preserve correct depth & alpha for transparency
    DEPTH = mix(d0.y, min_d.y, edge);
    ALPHA = clamp(edge * 1.5, 0.0, 1.0);
}
