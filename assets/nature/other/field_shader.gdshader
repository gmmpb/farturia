shader_type spatial;
render_mode cull_disabled; // allows backfaces, enables shadows

uniform vec3 base_color : source_color = vec3(0.054, 0.619, 0.106); // #0e9e1b
uniform float stripe_freq = 30.0;
uniform float stripe_strength = 0.04;

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // stripe pattern in X direction
    float stripe = sin(world_pos.x * stripe_freq) * 0.5 + 0.5;
    float stripe_dark = smoothstep(0.4, 0.6, stripe);

    vec3 final_color = base_color * (1.0 - stripe_dark * stripe_strength);
    ALBEDO = final_color;
}
