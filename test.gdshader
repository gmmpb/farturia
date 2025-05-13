shader_type spatial;
render_mode cull_disabled;

uniform vec3 base_color : source_color = vec3(0.1, 0.6, 0.1);
uniform vec3 tip_color  : source_color = vec3(0.3, 0.9, 0.3);
uniform sampler2D noise_tex;
uniform float noise_scale = 20.0;
uniform float time_speed = 1.0;
uniform float sway_strength = 0.2;
uniform float sway_freq = 3.0;

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    float sway = sin(UV.x * sway_freq + TIME * time_speed) * sway_strength;
    sway *= (1.0 - UV.y);
    VERTEX.x += sway;
}

void fragment() {
    float noise_val = 0.5;
    if (texture(noise_tex, world_pos.xz / noise_scale).r > 0.0) {
        noise_val = texture(noise_tex, world_pos.xz / noise_scale).r;
    }

    vec3 gradient = mix(base_color, tip_color, UV.y);
    vec3 noise_mix = mix(base_color, tip_color, noise_val);
    vec3 final_color = mix(gradient, noise_mix, 0.3);

    // Add vertical shading (fake AO)
    float shadow_factor = pow(1.0 - UV.y, 3.0);
    final_color *= mix(1.0, 0.6, shadow_factor);

    // Outline effect near blade edges
    float edge = smoothstep(0.0, 0.08, abs(UV.x - 0.5));
    final_color *= 1.0 - edge * 0.5;

    ALBEDO = final_color;

    if (!FRONT_FACING) {
        NORMAL = -NORMAL;
    }
}
