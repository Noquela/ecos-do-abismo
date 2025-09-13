extends CharacterBody2D
class_name Player

# Player Stats
@export var max_health: int = 100
@export var base_speed: float = 300.0
@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

# Movement variables
var health: int
var is_dashing: bool = false
var can_dash: bool = true
var dash_direction: Vector2 = Vector2.ZERO

# Components
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# Timers
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var iframe_timer: float = 0.0

# Animation states
enum PlayerState { IDLE, WALKING, ATTACKING, DASHING, HURT }
var current_state: PlayerState = PlayerState.IDLE

# Signals
signal health_changed(new_health: int, max_health: int)
signal player_died
signal dash_used
signal attack_performed

func _ready():
	health = max_health

	# Setup collision shape (placeholder - will be set when sprites are generated)
	if collision_shape.shape == null:
		var capsule = CapsuleShape2D.new()
		capsule.radius = 16
		capsule.height = 32
		collision_shape.shape = capsule

	# Connect to health system
	health_changed.emit(health, max_health)

	print("[Player] Egyptian warrior initialized - Ready for battle!")

func _physics_process(delta):
	handle_input()
	update_movement(delta)
	update_timers(delta)
	update_animation()
	move_and_slide()

func handle_input():
	if current_state == PlayerState.HURT:
		return

	# Movement input
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Dash input
	if Input.is_action_just_pressed("dash") and can_dash and input_vector != Vector2.ZERO:
		start_dash(input_vector)

	# Attack input
	if Input.is_action_just_pressed("attack") and current_state != PlayerState.ATTACKING:
		start_attack()

func update_movement(delta):
	if is_dashing:
		velocity = dash_direction * dash_speed
		return

	# Normal movement
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_vector != Vector2.ZERO:
		velocity = input_vector * base_speed
		current_state = PlayerState.WALKING
	else:
		velocity = velocity.move_toward(Vector2.ZERO, base_speed * 8 * delta)
		if current_state == PlayerState.WALKING:
			current_state = PlayerState.IDLE

func start_dash(direction: Vector2):
	if not can_dash:
		return

	is_dashing = true
	can_dash = false
	dash_direction = direction.normalized()
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	current_state = PlayerState.DASHING

	# i-frames during dash
	iframe_timer = dash_duration

	dash_used.emit()
	print("[Player] Dash activated!")

func start_attack():
	current_state = PlayerState.ATTACKING
	attack_performed.emit()

	# Attack animation will call _on_attack_finished when done
	if animated_sprite.has_animation("attack"):
		animated_sprite.play("attack")
	else:
		# Placeholder - immediate attack finish
		call_deferred("_on_attack_finished")

	print("[Player] Khopesh attack!")

func _on_attack_finished():
	current_state = PlayerState.IDLE

func update_timers(delta):
	# Dash timer
	if dash_timer > 0:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			current_state = PlayerState.IDLE

	# Dash cooldown
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0:
			can_dash = true

	# I-frames
	if iframe_timer > 0:
		iframe_timer -= delta

func update_animation():
	if not animated_sprite:
		return

	# Update sprite direction based on movement
	if velocity.x != 0:
		animated_sprite.flip_h = velocity.x < 0

	# Play appropriate animation
	match current_state:
		PlayerState.IDLE:
			if animated_sprite.has_animation("idle"):
				if animated_sprite.animation != "idle":
					animated_sprite.play("idle")

		PlayerState.WALKING:
			if animated_sprite.has_animation("walk"):
				if animated_sprite.animation != "walk":
					animated_sprite.play("walk")

		PlayerState.DASHING:
			if animated_sprite.has_animation("dash"):
				if animated_sprite.animation != "dash":
					animated_sprite.play("dash")

		PlayerState.ATTACKING:
			# Attack animation is already playing
			pass

		PlayerState.HURT:
			if animated_sprite.has_animation("hurt"):
				if animated_sprite.animation != "hurt":
					animated_sprite.play("hurt")

func take_damage(amount: int, source_position: Vector2 = Vector2.ZERO):
	if iframe_timer > 0:
		return  # I-frames active

	health -= amount
	iframe_timer = 0.5  # Brief i-frames after taking damage
	current_state = PlayerState.HURT

	# Knockback
	if source_position != Vector2.ZERO:
		var knockback_direction = (global_position - source_position).normalized()
		velocity += knockback_direction * 200

	health_changed.emit(health, max_health)

	if health <= 0:
		die()
	else:
		# Recovery from hurt state
		var hurt_timer = get_tree().create_timer(0.3)
		hurt_timer.timeout.connect(_on_hurt_recovery)

	print("[Player] Took ", amount, " damage! Health: ", health, "/", max_health)

func _on_hurt_recovery():
	if current_state == PlayerState.HURT:
		current_state = PlayerState.IDLE

func heal(amount: int):
	health = min(health + amount, max_health)
	health_changed.emit(health, max_health)
	print("[Player] Healed for ", amount, "! Health: ", health, "/", max_health)

func die():
	current_state = PlayerState.HURT
	velocity = Vector2.ZERO

	if animated_sprite.has_animation("death"):
		animated_sprite.play("death")

	# Disable player input and collision
	set_physics_process(false)
	collision_shape.set_deferred("disabled", true)

	player_died.emit()
	print("[Player] The pharaoh's champion has fallen...")

# Utility functions
func is_invulnerable() -> bool:
	return iframe_timer > 0

func get_health_percentage() -> float:
	return float(health) / float(max_health)

func get_dash_cooldown_percentage() -> float:
	if can_dash:
		return 0.0
	return dash_cooldown_timer / dash_cooldown