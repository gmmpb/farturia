extends Node3D    # put on SpringArm3D or a parent CameraRig

@export var target_node: NodePath       # drag your Player here
@export var offset: Vector3 = Vector3(0, 2, -5)
@export var spring_speed: float = 8.0

var target      : CharacterBody3D
var current_pos : Vector3

func _ready():
	target = get_node(target_node)
	current_pos = global_transform.origin

func _process(delta):
	# desired camera world-space point
	var tform = target.global_transform
	var desired = tform.origin
		+ tform.basis.xform(offset)    # rotate offset by player’s orientation

	# lerp the camera in
	current_pos = current_pos.lerp(desired, clamp(delta * spring_speed, 0, 1))
	global_transform.origin = current_pos

	# always look at the player’s head
	look_at(target.global_transform.origin + Vector3(0,1.5,0), Vector3.UP)
