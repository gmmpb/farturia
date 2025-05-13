shader_type canvas_item;

const int NUM_COLORS = 32;
const vec3 PALETTE[NUM_COLORS] = vec3[](
    // grass & foliage
    vec3(0.08, 0.12, 0.05),  // shadowed forest green
    vec3(0.12, 0.18, 0.08),
    vec3(0.18, 0.28, 0.12),
    vec3(0.24, 0.38, 0.16),
    vec3(0.32, 0.48, 0.22),
    vec3(0.42, 0.60, 0.30),
    vec3(0.50, 0.70, 0.40),
    vec3(0.58, 0.80, 0.50),

    // soil & earth
    vec3(0.15, 0.10, 0.07),  // dark clay
    vec3(0.23, 0.16, 0.10),
    vec3(0.32, 0.22, 0.14),
    vec3(0.40, 0.30, 0.20),
    vec3(0.50, 0.40, 0.28),
    vec3(0.60, 0.50, 0.36),
    vec3(0.70, 0.60, 0.45),
    vec3(0.78, 0.68, 0.55),

    // stone & wood
    vec3(0.25, 0.25, 0.25),  // dark stone
    vec3(0.40, 0.40, 0.40),
    vec3(0.55, 0.55, 0.55),
    vec3(0.70, 0.70, 0.70),

    // sky & water
    vec3(0.15, 0.25, 0.45),  // deep sky
    vec3(0.25, 0.40, 0.60),
    vec3(0.45, 0.60, 0.80),
    vec3(0.70, 0.85, 0.95),

    // clouds / highlights
    vec3(0.88, 0.92, 0.97),
    vec3(1.00, 1.00, 1.00),

    // accents / color pops
    vec3(0.50, 0.20, 0.10),  // brick
    vec3(0.85, 0.55, 0.30),  // orange leather
    vec3(0.95, 0.85, 0.60),  // sand / thatch
    vec3(1.00, 0.70, 0.40),  // warm sun
    vec3(0.90, 0.30, 0.30),  // red highlight
	vec3(0.95, 0.87, 0.78)  // soft highlight / skin / linen

);

// brute-force closest match
vec3 palette_limiter(in vec3 col) {
    vec3 best = PALETTE[0];
    float md = 999.0;
    for (int i = 0; i < NUM_COLORS; i++) {
        float d = distance(col, PALETTE[i]);
        if (d < md) {
            md = d;
            best = PALETTE[i];
            if (md < 0.001) break;
        }
    }
    return best;
}

void fragment() {
    vec3 src = texture(TEXTURE, UV).rgb;
    vec3 dst = palette_limiter(src);
    COLOR = vec4(dst, 1.0);
}
