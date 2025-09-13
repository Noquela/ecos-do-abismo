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

# Weapon system
var current_weapon: Weapon
var weapon_holder: Node2D

# Debug placeholder - will be replaced with AI-generated sprites
var placeholder_color: Color = Color.GOLD

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

	# Setup collision shape with proper size
	if collision_shape.shape == null:
		var capsule = CapsuleShape2D.new()
		capsule.radius = 16
		capsule.height = 32
		collision_shape.shape = capsule

	# Setup weapon system
	setup_weapon_system()

	# Connect to health system
	health_changed.emit(health, max_health)

	print("[Player] Egyptian warrior initialized - Ready for battle!")
	print("[Player] Controls: WASD to move, Shift/RMB to dash, Space/LMB to attack")

func _physics_process(delta):
	handle_input()
	update_movement(delta)
	update_timers(delta)
	update_animation()
	move_and_slide()

func _draw():
	# Debug placeholder visuals until we have AI-generated sprites
	if iframe_timer > 0:
		# Flash white when taking damage
		if int(Time.get_time_msec() / 100) % 2:
			placeholder_color = Color.WHITE
		else:
			placeholder_color = Color.GOLD
	else:
		placeholder_color = Color.GOLD

	# Draw player as a simple shape
	match current_state:
		PlayerState.DASHING:
			placeholder_color = Color.CYAN
		PlayerState.ATTACKING:
			placeholder_color = Color.RED
		PlayerState.HURT:
			placeholder_color = Color.ORANGE_RED
		_:
			if is_moving():
				placeholder_color = Color.YELLOW
			else:
				placeholder_color = Color.GOLD

	# Draw player body
	draw_circle(Vector2.ZERO, 16, placeholder_color)

	# Draw directional indicator
	if velocity.length() > 0:
		var direction = velocity.normalized() * 20
		draw_line(Vector2.ZERO, direction, Color.BLACK, 3)

	# Draw dash cooldown indicator
	if not can_dash:
		var cooldown_progress = 1.0 - (dash_cooldown_timer / dash_cooldown)
		var arc_color = Color.BLUE
		draw_arc(Vector2.ZERO, 20, 0, cooldown_progress * TAU, 32, arc_color, 2)

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

	# Weapon switching (number keys)
	if Input.is_action_just_pressed("ui_accept"):  # Enter key for now
		cycle_weapon()

func update_movement(delta):
	if is_dashing:
		velocity = dash_direction * dash_speed
		queue_redraw()  # Update visuals
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

	queue_redraw()  # Update visuals

func is_moving() -> bool:
	return velocity.length() > 10

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
	print("[Player] Dash activated! Direction: ", dash_direction)

func setup_weapon_system():
	# Create weapon holder node
	weapon_holder = Node2D.new()
	weapon_holder.name = "WeaponHolder"
	add_child(weapon_holder)

	# Equip default weapon (Khopesh)
	equip_weapon("khopesh")

func equip_weapon(weapon_type: String):
	# Remove current weapon
	if current_weapon:
		current_weapon.queue_free()

	# Create new weapon based on type
	match weapon_type:
		"khopesh":
			current_weapon = Weapon.create_khopesh()
		"spear":
			current_weapon = Weapon.create_spear_of_ra()
		"axe":
			current_weapon = Weapon.create_axe_of_sobek()
		_:
			current_weapon = Weapon.create_khopesh()

	# Add weapon to holder
	current_weapon.set_script(preload("res://scripts/weapons/Weapon.gd"))
	weapon_holder.add_child(current_weapon)

	# Connect weapon signals
	current_weapon.attack_started.connect(_on_weapon_attack_started)
	current_weapon.attack_hit.connect(_on_weapon_hit)
	current_weapon.attack_finished.connect(_on_weapon_attack_finished)

	print("[Player] Equipped: ", current_weapon.weapon_name)

func cycle_weapon():
	var weapons = ["khopesh", "spear", "axe"]
	var current_type = ""

	if current_weapon:
		if "Khopesh" in current_weapon.weapon_name:
			current_type = "khopesh"
		elif "Spear" in current_weapon.weapon_name:
			current_type = "spear"
		elif "Axe" in current_weapon.weapon_name:
			current_type = "axe"

	var current_index = weapons.find(current_type)
	var next_index = (current_index + 1) % weapons.size()

	equip_weapon(weapons[next_index])

func start_attack():
	if not current_weapon or not current_weapon.can_attack():
		return

	current_state = PlayerState.ATTACKING

	# Orient weapon towards mouse/movement direction
	orient_weapon()

	# Start weapon attack
	if current_weapon.start_attack():
		attack_performed.emit()
		print("[Player] Attacking with ", current_weapon.weapon_name)

func orient_weapon():
	if not current_weapon:
		return

	# Get direction towards mouse cursor
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()

	# Set weapon rotation
	current_weapon.rotation = direction.angle()

	# Flip weapon holder if attacking to the left
	if direction.x < 0:
		weapon_holder.scale.y = -1
	else:
		weapon_holder.scale.y = 1

func _on_weapon_attack_started():
	print("[Player] Weapon attack started")

func _on_weapon_hit(target: Node, damage_dealt: int):
	print("[Player] Hit ", target.name, " for ", damage_dealt, " damage")

func _on_weapon_attack_finished():
	current_state = PlayerState.IDLE
	print("[Player] Weapon attack finished")

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
			queue_redraw()  # Update cooldown visual

	# I-frames
	if iframe_timer > 0:
		iframe_timer -= delta
		queue_redraw()  # Update flashing visual

func update_animation():
	# For now, just print state changes for validation
	static var last_state = PlayerState.IDLE
	if current_state != last_state:
		match current_state:
			PlayerState.IDLE:
				print("[Player] State: IDLE")
			PlayerState.WALKING:
				print("[Player] State: WALKING")
			PlayerState.DASHING:
				print("[Player] State: DASHING")
			PlayerState.ATTACKING:
				print("[Player] State: ATTACKING")
			PlayerState.HURT:
				print("[Player] State: HURT")
		last_state = current_state

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
	placeholder_color = Color.DARK_RED

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

# Validation functions
func validate_systems():
	print("[Player] === SYSTEM VALIDATION ===")
	print("[Player] Health: ", health, "/", max_health)
	print("[Player] Speed: ", base_speed)
	print("[Player] Position: ", global_position)
	print("[Player] Can dash: ", can_dash)
	print("[Player] Current state: ", PlayerState.keys()[current_state])
	print("[Player] Collision shape: ", collision_shape.shape != null)
	print("[Player] === VALIDATION COMPLETE ===")