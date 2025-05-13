extends CharacterBody3D

# ───── tunables ──────────────────────────────────────────
@export var walk_speed      := 3.0
@export var run_speed       := 6.0
@export var jump_velocity   := 8.0        # metres / sec
@export var gravity         := 20.0       # metres / sec²
@export var turn_smoothness := 10.0       # bigger = snappier
# ─────────────────────────────────────────────────────────

@onready var anim  : AnimationPlayer = $Knight/AnimationPlayer
@onready var model : Node3D          = $Knight

var action_lock := false             # locked while one-shot plays
var jumping     := false

func _physics_process(delta):
	# ───────── movement input ─────────
	var iv2 = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
	)

	# choose walk/run speed
	var target_speed = walk_speed
	if Input.is_action_pressed("ui_shift"):   # hold Shift to run
		target_speed = run_speed

	var move3 = Vector3.ZERO
	if iv2.length() > 0:
		iv2 = iv2.normalized()
		move3 = Vector3(iv2.x, 0, iv2.y) * target_speed

	# ───────── gravity & jump ─────────
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if jumping and velocity.y <= 0:
			# landed
			jumping = false
			if not action_lock:
				anim.play("Idle")      # landing ends jump
		if Input.is_action_just_pressed("ui_jump") and not action_lock:
			velocity.y = jump_velocity
			jumping = true
			action_lock = true
			anim.play("Jump_Start")    # play any jump clip you like

	# horizontal velocity
	velocity.x = move3.x
	velocity.z = move3.z
	move_and_slide()

	# ───────── rotation ─────────
	if move3.length() > 0:
		var target = atan2(move3.x, move3.z)
		model.rotation.y = lerp_angle(model.rotation.y, target, delta * turn_smoothness)

	# ───────── locomotion animations ─────────
	if is_on_floor() and not action_lock:     # don’t override one-shots / jump
		if move3.length() > 0:
			if Input.is_action_pressed("ui_shift"):
				if anim.current_animation != "Running_A":
					anim.play("Running_A")
			else:
				if anim.current_animation != "Walking_A":
					anim.play("Walking_A")
		else:
			if anim.current_animation != "Idle":
				anim.play("Idle")

	# ───────── unlock one-shots when done ─────────
	if action_lock and not anim.is_playing():
		action_lock = false


# ───────── one-shot actions on default keys ─────────
func _unhandled_input(event):
	if action_lock:          # ignore if locked
		return

	if event.is_action_pressed("ui_accept"):          # Enter  – melee
		play_one_shot("1H_Melee_Attack_Chop")

	elif event.is_action_pressed("ui_cancel"):        # Esc    – block
		play_one_shot("Block")

	elif event.is_action_pressed("ui_focus_next"):    # Tab    – dodge left
		play_one_shot("Dodge_Left")

	elif event.is_action_pressed("ui_focus_prev"):    # Shift+Tab – dodge right
		play_one_shot("Dodge_Right")


# helper
func play_one_shot(name: String):
	if anim.has_animation(name):
		action_lock = true
		anim.play(name)
