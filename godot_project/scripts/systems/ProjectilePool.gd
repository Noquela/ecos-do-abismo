extends Node
class_name ProjectilePool

# Pool configuration
@export var pool_size: int = 100
@export var auto_expand: bool = true
@export var max_pool_size: int = 500

# Pool storage
var available_projectiles: Array[Projectile] = []
var active_projectiles: Array[Projectile] = []
var projectile_scene: PackedScene

# Statistics
var total_created: int = 0
var total_reused: int = 0
var peak_active: int = 0

# Signals
signal pool_expanded(new_size: int)
signal pool_exhausted

func _ready():
	setup_pool()

func setup_pool():
	projectile_scene = preload("res://scenes/projectiles/Projectile.tscn")

	# Pre-create projectiles
	for i in range(pool_size):
		var projectile = create_new_projectile()
		available_projectiles.append(projectile)

	print("[ProjectilePool] Initialized with ", pool_size, " projectiles")

func create_new_projectile() -> Projectile:
	var projectile = projectile_scene.instantiate()
	add_child(projectile)
	projectile.visible = false
	projectile.set_physics_process(false)
	projectile.hitbox.monitoring = false
	projectile.projectile_destroyed.connect(_on_projectile_destroyed)
	projectile.is_pooled = true
	total_created += 1
	return projectile

func get_projectile() -> Projectile:
	var projectile: Projectile = null

	if available_projectiles.is_empty():
		if auto_expand and total_created < max_pool_size:
			expand_pool()
		else:
			pool_exhausted.emit()
			print("[ProjectilePool] Pool exhausted, reusing oldest projectile")
			# Force return oldest active projectile
			if not active_projectiles.is_empty():
				projectile = active_projectiles[0]
				projectile.destroy_projectile()

	if not available_projectiles.is_empty():
		projectile = available_projectiles.pop_back()
		active_projectiles.append(projectile)
		total_reused += 1

		# Update peak statistics
		if active_projectiles.size() > peak_active:
			peak_active = active_projectiles.size()

	return projectile

func return_projectile(projectile: Projectile):
	if projectile in active_projectiles:
		active_projectiles.erase(projectile)
		available_projectiles.append(projectile)

		# Reset projectile state
		projectile.return_to_pool()

func _on_projectile_destroyed(projectile: Projectile):
	return_projectile(projectile)

func spawn_projectile(position: Vector2, direction: Vector2, projectile_type: String = "default") -> Projectile:
	var projectile = get_projectile()
	if projectile == null:
		return null

	# Configure projectile based on type
	configure_projectile_type(projectile, projectile_type)

	# Activate projectile
	projectile.activate_from_pool(position, direction)

	return projectile

func configure_projectile_type(projectile: Projectile, type: String):
	match type:
		"fire_bolt":
			projectile.damage = 15
			projectile.speed = 250
			projectile.projectile_color = Color.ORANGE_RED
			projectile.glow_effect = true
			projectile.lifetime = 4.0

		"ice_shard":
			projectile.damage = 12
			projectile.speed = 200
			projectile.projectile_color = Color.CYAN
			projectile.pierce_count = 1
			projectile.lifetime = 5.0

		"dark_orb":
			projectile.damage = 20
			projectile.speed = 150
			projectile.projectile_color = Color.PURPLE
			projectile.homing_strength = 2.0
			projectile.size_scale = 1.5
			projectile.lifetime = 6.0

		"light_beam":
			projectile.damage = 8
			projectile.speed = 400
			projectile.projectile_color = Color.YELLOW
			projectile.pierce_count = 3
			projectile.size_scale = 0.7
			projectile.lifetime = 3.0

		"explosive":
			projectile.damage = 25
			projectile.speed = 180
			projectile.projectile_color = Color.RED
			projectile.size_scale = 1.2
			projectile.lifetime = 4.0

		_: # default
			projectile.damage = 10
			projectile.speed = 200
			projectile.projectile_color = Color.ORANGE
			projectile.glow_effect = true
			projectile.lifetime = 5.0

func expand_pool():
	var expansion_size = min(20, max_pool_size - total_created)

	for i in range(expansion_size):
		var projectile = create_new_projectile()
		available_projectiles.append(projectile)

	pool_expanded.emit(total_created)
	print("[ProjectilePool] Expanded to ", total_created, " total projectiles")

func clear_all_projectiles():
	# Return all active projectiles to pool
	var active_copy = active_projectiles.duplicate()
	for projectile in active_copy:
		projectile.destroy_projectile()

func get_pool_stats() -> Dictionary:
	return {
		"total_created": total_created,
		"available": available_projectiles.size(),
		"active": active_projectiles.size(),
		"total_reused": total_reused,
		"peak_active": peak_active,
		"efficiency": float(total_reused) / float(total_created) if total_created > 0 else 0.0
	}

func print_stats():
	var stats = get_pool_stats()
	print("[ProjectilePool Stats]")
	print("  Total Created: ", stats.total_created)
	print("  Available: ", stats.available)
	print("  Active: ", stats.active)
	print("  Total Reused: ", stats.total_reused)
	print("  Peak Active: ", stats.peak_active)
	print("  Efficiency: ", "%.1f%%" % (stats.efficiency * 100))

# Patterns for bullet hell
func spawn_pattern_circle(center: Vector2, radius: float, count: int, projectile_type: String = "default"):
	var angle_step = TAU / count
	for i in range(count):
		var angle = angle_step * i
		var direction = Vector2(cos(angle), sin(angle))
		var spawn_pos = center + direction * radius
		spawn_projectile(spawn_pos, direction, projectile_type)

func spawn_pattern_spiral(center: Vector2, count: int, spiral_rate: float, projectile_type: String = "default"):
	var angle_step = TAU / 8  # 8 arms
	for i in range(count):
		var angle = (angle_step * i) + (spiral_rate * i * 0.1)
		var direction = Vector2(cos(angle), sin(angle))
		spawn_projectile(center, direction, projectile_type)

func spawn_pattern_cone(origin: Vector2, target_direction: Vector2, cone_angle: float, count: int, projectile_type: String = "default"):
	var base_angle = target_direction.angle()
	var half_cone = cone_angle / 2

	for i in range(count):
		var angle_offset = lerp(-half_cone, half_cone, float(i) / float(count - 1))
		var final_angle = base_angle + angle_offset
		var direction = Vector2(cos(final_angle), sin(final_angle))
		spawn_projectile(origin, direction, projectile_type)

func spawn_pattern_wave(start_pos: Vector2, end_pos: Vector2, wave_height: float, count: int, projectile_type: String = "default"):
	var base_direction = (end_pos - start_pos).normalized()
	var perpendicular = Vector2(-base_direction.y, base_direction.x)

	for i in range(count):
		var t = float(i) / float(count - 1)
		var wave_offset = sin(t * TAU * 2) * wave_height
		var spawn_pos = start_pos.lerp(end_pos, t) + perpendicular * wave_offset
		spawn_projectile(spawn_pos, base_direction, projectile_type)