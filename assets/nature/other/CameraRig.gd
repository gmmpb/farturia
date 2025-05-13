extends Node3D

@export var move_speed := 8.0      # meters/sec
@export var rot_speed  := 60.0     # degrees/sec

func _physics_process(delta):
	var input_dir := Vector3.ZERO

	## Movement (WASD or arrow keys)
	#if Input.is_action_pressed("ui_up"):    input_dir.z -= 1
	#if Input.is_action_pressed("ui_down"):  input_dir.z += 1
	#if Input.is_action_pressed("ui_left"):  input_dir.x -= 1
	#if Input.is_action_pressed("ui_right"): input_dir.x += 1

	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
		var move = global_transform.basis * input_dir * move_speed * delta
		translate(move)

	# Rotation (Q + E)
	var rot := 0.0
	if Input.is_action_pressed("cam_rot_left"):  rot += 1
	if Input.is_action_pressed("cam_rot_right"): rot -= 1

	if rot != 0.0:
		rotate_y(deg_to_rad(rot * rot_speed * delta))
