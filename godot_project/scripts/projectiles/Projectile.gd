extends RigidBody2D
class_name Projectile

# Projectile properties
@export var damage: int = 10
@export var speed: float = 200.0
@export var lifetime: float = 5.0
@export var pierce_count: int = 0  # 0 = destroyed on first hit
@export var homing_strength: float = 0.0  # 0 = no homing
@export var size_scale: float = 1.0

# Visual properties
@export var projectile_color: Color = Color.ORANGE
@export var trail_length: int = 8
@export var glow_effect: bool = true

# Physics properties
@export var gravity_scale_override: float = 0.0
@export var bounce_count: int = 0  # Number of times it can bounce

# Components
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $HitBox
@onready var hitbox_collision: CollisionShape2D = $HitBox/CollisionShape2D

# State
var current_lifetime: float
var pierce_remaining: int
var bounce_remaining: int
var targets_hit: Array[Node] = []
var direction: Vector2 = Vector2.RIGHT
var homing_target: Node = null
var is_pooled: bool = false
var trail_positions: Array[Vector2] = []

# Signals
signal projectile_hit(target: Node, damage_dealt: int)
signal projectile_destroyed
signal projectile_bounced

func _ready():
	setup_projectile()
	setup_signals()
	current_lifetime = lifetime
	pierce_remaining = pierce_count
	bounce_remaining = bounce_count

	# Set physics properties
	gravity_scale = gravity_scale_override
	linear_velocity = direction * speed

	# Set collision layers
	collision_layer = 4  # Projectiles layer
	collision_mask = 3   # Hit players (1) and enemies (2)

	print("[Projectile] Created with damage:", damage, " speed:", speed)

func _physics_process(delta):
	update_lifetime(delta)
	update_homing(delta)
	update_trail()

func _draw():
	# Draw projectile as a glowing circle
	var radius = 8 * size_scale

	# Glow effect
	if glow_effect:
		for i in range(3):
			var glow_color = projectile_color
			glow_color.a = 0.3 - (i * 0.1)
			draw_circle(Vector2.ZERO, radius + (i * 2), glow_color)

	# Main projectile
	draw_circle(Vector2.ZERO, radius, projectile_color)

	# Draw trail
	if trail_positions.size() > 1:
		for i in range(trail_positions.size() - 1):
			var alpha = float(i) / float(trail_positions.size())
			var trail_color = projectile_color
			trail_color.a = alpha * 0.5

			var start_pos = to_local(trail_positions[i])
			var end_pos = to_local(trail_positions[i + 1])
			draw_line(start_pos, end_pos, trail_color, 3 * alpha)

func setup_projectile():
	# Setup collision shapes
	if collision_shape.shape == null:
		var circle = CircleShape2D.new()
		circle.radius = 8 * size_scale
		collision_shape.shape = circle

	if hitbox_collision.shape == null:
		var circle = CircleShape2D.new()
		circle.radius = 10 * size_scale
		hitbox_collision.shape = circle

	# Set hitbox collision
	hitbox.collision_layer = 0
	hitbox.collision_mask = 3  # Hit players and enemies

func setup_signals():
	hitbox.area_entered.connect(_on_area_entered)
	hitbox.body_entered.connect(_on_body_entered)
	body_entered.connect(_on_collision_body_entered)

func _on_area_entered(area: Area2D):
	var target = area.get_parent()
	_process_hit(target)

func _on_body_entered(body: Node2D):
	_process_hit(body)

func _on_collision_body_entered(body: Node):
	# Handle bouncing off walls/obstacles
	if bounce_remaining > 0 and body.name.contains("Wall"):
		handle_bounce(body)
	else:
		_process_hit(body)

func _process_hit(target: Node):
	if not is_instance_valid(target) or target in targets_hit:
		return

	# Skip if hitting the same type (player projectile vs player, etc)
	if should_ignore_target(target):
		return

	targets_hit.append(target)

	# Deal damage if target can take it
	if target.has_method("take_damage"):
		target.take_damage(damage, global_position)
		projectile_hit.emit(target, damage)
		print("[Projectile] Hit ", target.name, " for ", damage, " damage")

	# Handle pierce
	if pierce_remaining > 0:
		pierce_remaining -= 1
		return

	# Destroy projectile
	destroy_projectile()

func should_ignore_target(target: Node) -> bool:
	# Add logic to ignore same-type targets
	# For now, projectiles hit everything
	return false

func handle_bounce(collision_body: Node):
	# Calculate bounce direction
	var collision_point = global_position
	var normal = Vector2.UP  # Simplified - should get actual collision normal

	# Reflect velocity
	var reflected_velocity = linear_velocity.reflect(normal)
	linear_velocity = reflected_velocity
	direction = reflected_velocity.normalized()

	bounce_remaining -= 1
	projectile_bounced.emit()
	print("[Projectile] Bounced, remaining bounces:", bounce_remaining)

func update_lifetime(delta):
	current_lifetime -= delta
	if current_lifetime <= 0:
		destroy_projectile()

func update_homing(delta):
	if homing_strength <= 0.0 or not is_instance_valid(homing_target):
		return

	var target_direction = (homing_target.global_position - global_position).normalized()
	direction = direction.lerp(target_direction, homing_strength * delta)
	linear_velocity = direction * speed

func update_trail():
	trail_positions.append(global_position)
	if trail_positions.size() > trail_length:
		trail_positions.remove_at(0)

	queue_redraw()

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()
	linear_velocity = direction * speed

func set_homing_target(target: Node):
	homing_target = target

func destroy_projectile():
	projectile_destroyed.emit()
	print("[Projectile] Destroyed")

	if is_pooled:
		# Return to pool instead of freeing
		return_to_pool()
	else:
		queue_free()

func return_to_pool():
	# Reset state for reuse
	targets_hit.clear()
	trail_positions.clear()
	current_lifetime = lifetime
	pierce_remaining = pierce_count
	bounce_remaining = bounce_count
	homing_target = null

	# Hide and disable
	visible = false
	set_physics_process(false)
	hitbox.monitoring = false

func activate_from_pool(pos: Vector2, dir: Vector2):
	global_position = pos
	set_direction(dir)
	visible = true
	set_physics_process(true)
	hitbox.monitoring = true
	is_pooled = true

# Projectile presets for different enemy types
static func create_fire_bolt() -> Projectile:
	var bolt = preload("res://scenes/projectiles/Projectile.tscn").instantiate()
	bolt.damage = 15
	bolt.speed = 250
	bolt.projectile_color = Color.ORANGE_RED
	bolt.glow_effect = true
	return bolt

static func create_ice_shard() -> Projectile:
	var shard = preload("res://scenes/projectiles/Projectile.tscn").instantiate()
	shard.damage = 12
	shard.speed = 200
	shard.projectile_color = Color.CYAN
	shard.pierce_count = 1
	return shard

static func create_dark_orb() -> Projectile:
	var orb = preload("res://scenes/projectiles/Projectile.tscn").instantiate()
	orb.damage = 20
	orb.speed = 150
	orb.projectile_color = Color.PURPLE
	orb.homing_strength = 2.0
	orb.size_scale = 1.5
	return orb

static func create_light_beam() -> Projectile:
	var beam = preload("res://scenes/projectiles/Projectile.tscn").instantiate()
	beam.damage = 8
	beam.speed = 400
	beam.projectile_color = Color.YELLOW
	beam.pierce_count = 3
	beam.size_scale = 0.7
	return beam