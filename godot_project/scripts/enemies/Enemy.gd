extends CharacterBody2D
class_name Enemy

# Enemy Stats (based on roadmap: Múmia Guerreira)
@export var max_health: int = 30
@export var damage: int = 15
@export var speed: float = 100.0
@export var detection_range: float = 150.0
@export var attack_range: float = 50.0

# State
var health: int
var target: Node2D = null
var is_dead: bool = false

# Components
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hurt_box: Area2D = $HurtBox
@onready var hurt_shape: CollisionShape2D = $HurtBox/HurtShape

# AI State Machine
enum EnemyState { IDLE, CHASE, ATTACK, HURT, DEATH }
var current_state: EnemyState = EnemyState.IDLE
var state_timer: float = 0.0

# Attack system
var attack_cooldown: float = 1.5
var attack_timer: float = 0.0
var can_attack: bool = true

# Visual feedback
var enemy_color: Color = Color.DARK_RED
var hurt_color: Color = Color.WHITE
var death_color: Color = Color.BLACK

# Signals
signal enemy_died
signal enemy_attacked_player
signal health_changed(new_health: int, max_health: int)

func _ready():
	health = max_health
	setup_enemy()

func _physics_process(delta):
	if is_dead:
		return

	update_state_machine(delta)
	update_timers(delta)
	move_and_slide()

func _draw():
	# Debug placeholder visual
	var color = enemy_color

	match current_state:
		EnemyState.HURT:
			if int(Time.get_time_msec() / 100) % 2:
				color = hurt_color
		EnemyState.DEATH:
			color = death_color
		EnemyState.ATTACK:
			color = Color.ORANGE_RED
		EnemyState.CHASE:
			color = Color.CRIMSON

	# Draw enemy body
	draw_circle(Vector2.ZERO, 14, color)

	# Draw detection range (when idle)
	if current_state == EnemyState.IDLE:
		draw_circle(Vector2.ZERO, detection_range, Color(1, 0, 0, 0.1))

	# Draw attack range indicator
	if current_state == EnemyState.CHASE and target:
		var distance = global_position.distance_to(target.global_position)
		if distance <= attack_range:
			draw_circle(Vector2.ZERO, attack_range, Color(1, 0, 0, 0.3))

func setup_enemy():
	# Setup collision shapes
	if collision_shape.shape == null:
		var circle = CircleShape2D.new()
		circle.radius = 14
		collision_shape.shape = circle

	if hurt_shape.shape == null:
		var circle = CircleShape2D.new()
		circle.radius = 16
		hurt_shape.shape = circle

	# Setup hurt box for receiving damage
	hurt_box.collision_layer = 2  # Enemy layer
	hurt_box.collision_mask = 0   # Don't detect anything

	# Set physics collision
	collision_layer = 2  # Enemy physics layer
	collision_mask = 1   # Collide with player

	print("[Enemy] Múmia Guerreira spawned - Health: ", health)

func update_state_machine(delta):
	state_timer += delta

	match current_state:
		EnemyState.IDLE:
			handle_idle_state()

		EnemyState.CHASE:
			handle_chase_state(delta)

		EnemyState.ATTACK:
			handle_attack_state(delta)

		EnemyState.HURT:
			handle_hurt_state(delta)

		EnemyState.DEATH:
			handle_death_state(delta)

	queue_redraw()

func handle_idle_state():
	velocity = Vector2.ZERO

	# Look for player
	var player = find_player_in_range()
	if player:
		target = player
		change_state(EnemyState.CHASE)

func handle_chase_state(delta):
	if not target or not is_instance_valid(target):
		change_state(EnemyState.IDLE)
		return

	var distance = global_position.distance_to(target.global_position)

	# Lost target
	if distance > detection_range * 1.5:
		target = null
		change_state(EnemyState.IDLE)
		return

	# Close enough to attack
	if distance <= attack_range and can_attack:
		change_state(EnemyState.ATTACK)
		return

	# Move towards target
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed

func handle_attack_state(delta):
	velocity = Vector2.ZERO

	if state_timer >= 0.5:  # Attack duration
		# Deal damage to player if in range
		if target and global_position.distance_to(target.global_position) <= attack_range:
			if target.has_method("take_damage"):
				target.take_damage(damage, global_position)
				enemy_attacked_player.emit()
				print("[Enemy] Múmia attacked player for ", damage, " damage!")

		# Start attack cooldown
		can_attack = false
		attack_timer = attack_cooldown

		change_state(EnemyState.CHASE)

func handle_hurt_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, speed * 3 * delta)

	if state_timer >= 0.3:  # Hurt duration
		change_state(EnemyState.CHASE if target else EnemyState.IDLE)

func handle_death_state(delta):
	velocity = Vector2.ZERO
	# Death animation would play here

func change_state(new_state: EnemyState):
	current_state = new_state
	state_timer = 0.0

	match new_state:
		EnemyState.CHASE:
			print("[Enemy] Chasing target!")
		EnemyState.ATTACK:
			print("[Enemy] Attacking!")
		EnemyState.HURT:
			print("[Enemy] Hurt!")
		EnemyState.DEATH:
			print("[Enemy] Death!")

func update_timers(delta):
	if attack_timer > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			can_attack = true

func find_player_in_range() -> Node2D:
	# Find player within detection range
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = global_position
	query.collision_mask = 1  # Player layer

	# Check in a circle around enemy
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		if global_position.distance_to(player.global_position) <= detection_range:
			return player

	return null

func take_damage(amount: int, source_position: Vector2 = Vector2.ZERO):
	if is_dead:
		return

	health -= amount
	health_changed.emit(health, max_health)

	# Knockback
	if source_position != Vector2.ZERO:
		var knockback_direction = (global_position - source_position).normalized()
		velocity += knockback_direction * 150

	change_state(EnemyState.HURT)

	print("[Enemy] Took ", amount, " damage! Health: ", health, "/", max_health)

	if health <= 0:
		die()

func die():
	is_dead = true
	change_state(EnemyState.DEATH)

	# Disable collision
	collision_shape.set_deferred("disabled", true)
	hurt_box.set_deferred("monitoring", false)

	enemy_died.emit()
	print("[Enemy] Múmia Guerreira has been defeated!")

	# Remove after death animation
	var death_timer = get_tree().create_timer(1.0)
	death_timer.timeout.connect(queue_free)

# Factory function for different enemy types
static func create_mummy_warrior() -> Enemy:
	var enemy = preload("res://scenes/enemies/Enemy.tscn").instantiate()
	enemy.max_health = 30
	enemy.health = 30
	enemy.damage = 15
	enemy.speed = 100.0
	enemy.enemy_color = Color.SADDLE_BROWN
	return enemy

static func create_anubis_guardian() -> Enemy:
	var enemy = preload("res://scenes/enemies/Enemy.tscn").instantiate()
	enemy.max_health = 100
	enemy.health = 100
	enemy.damage = 25
	enemy.speed = 80.0
	enemy.attack_range = 80.0
	enemy.enemy_color = Color.DARK_SLATE_BLUE
	return enemy