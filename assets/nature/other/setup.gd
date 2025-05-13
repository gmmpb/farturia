# File: pixel_postprocess_setup.gd
# Drop this on a Node3D scene root to set up postprocessing viewport in code

@tool
extends Node3D

@export var resolution: Vector2 = Vector2(320, 180)
@export var levels: int = 5
@export var edge_strength: float = 2.0

func _ready():
	# Setup SubViewport
	var viewport := SubViewport.new()
	viewport.name = "PixelViewport"
	viewport.size = resolution
	viewport.disable_3d = false
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	viewport.world_3d = get_viewport().world_3d


	# Setup SubViewportTexture
	await get_tree().process_frame
	var vp_texture := viewport.get_texture()

	# Setup TextureRect to display the viewport
	var canvas_layer := CanvasLayer.new()
	canvas_layer.layer = 0
	add_child(canvas_layer)

	var texture_rect := TextureRect.new()
	texture_rect.anchor_right = 1.0
	texture_rect.anchor_bottom = 1.0
	texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	texture_rect.texture = vp_texture
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP
	canvas_layer.add_child(texture_rect)

	# Shader
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;

uniform int LEVELS = %d;
uniform float EDGE = %.2f;

void fragment() {
	vec2 p = TEXTURE_PIXEL_SIZE;
	vec4 c = texture(TEXTURE, UV);
	c.rgb = floor(c.rgb * float(LEVELS)) / float(LEVELS);
	float gx = 0.0;
	float gy = 0.0;
	for (int x = -1; x <= 1; x++) {
		for (int y = -1; y <= 1; y++) {
			vec2 o = vec2(float(x), float(y)) * p;
			float l = length(c.rgb - texture(TEXTURE, UV + o).rgb);
			gx += float(x) * l;
			gy += float(y) * l;
		}
	}
	float edge = clamp(sqrt(gx * gx + gy * gy) * EDGE, 0.0, 1.0);
	vec3 final_color = mix(c.rgb, vec3(0.0), edge);
	COLOR = vec4(final_color, 1.0);
}
""" % [levels, edge_strength]

	var mat := ShaderMaterial.new()
	mat.shader = shader
	texture_rect.material = mat

	print("✅ Pixel post-process pipeline initialized.")
