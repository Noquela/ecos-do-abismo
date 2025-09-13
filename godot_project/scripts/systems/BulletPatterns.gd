extends Node
class_name BulletPatterns

# Pattern system for bullet hell mechanics
var projectile_pool: ProjectilePool

func _ready():
	projectile_pool = get_node("/root/Main/ProjectilePool") if get_node_or_null("/root/Main/ProjectilePool") else null

# Basic Patterns
func pattern_single(origin: Vector2, direction: Vector2, projectile_type: String = "default"):
	if not projectile_pool: return
	projectile_pool.spawn_projectile(origin, direction, projectile_type)

func pattern_burst(origin: Vector2, direction: Vector2, count: int, delay: float = 0.1, projectile_type: String = "default"):
	if not projectile_pool: return
	for i in range(count):
		var burst_delay = i * delay
		get_tree().create_timer(burst_delay).timeout.connect(
			func(): projectile_pool.spawn_projectile(origin, direction, projectile_type)
		)

# Circle Patterns
func pattern_circle(center: Vector2, radius: float = 20.0, count: int = 8, projectile_type: String = "default"):
	if not projectile_pool: return
	projectile_pool.spawn_pattern_circle(center, radius, count, projectile_type)

func pattern_expanding_circle(center: Vector2, count: int = 12, waves: int = 3, wave_delay: float = 0.5, projectile_type: String = "default"):
	if not projectile_pool: return
	for wave in range(waves):
		var delay = wave * wave_delay
		get_tree().create_timer(delay).timeout.connect(
			func(): projectile_pool.spawn_pattern_circle(center, 20.0 + wave * 15, count, projectile_type)
		)

# Spiral Patterns
func pattern_spiral(center: Vector2, arms: int = 4, turns: float = 2.0, projectiles_per_arm: int = 8, projectile_type: String = "default"):
	if not projectile_pool: return
	var total_projectiles = arms * projectiles_per_arm
	var angle_per_projectile = (TAU * turns) / total_projectiles
	var arm_offset = TAU / arms

	for arm in range(arms):
		for i in range(projectiles_per_arm):
			var delay = i * 0.1
			var base_angle = arm * arm_offset
			var spiral_angle = base_angle + (i * angle_per_projectile)
			var direction = Vector2(cos(spiral_angle), sin(spiral_angle))

			get_tree().create_timer(delay).timeout.connect(
				func(): projectile_pool.spawn_projectile(center, direction, projectile_type)
			)

func pattern_double_spiral(center: Vector2, projectiles_per_spiral: int = 16, clockwise: bool = true, projectile_type: String = "default"):
	if not projectile_pool: return
	var direction_multiplier = 1 if clockwise else -1

	for i in range(projectiles_per_spiral):
		var delay = i * 0.08
		var angle1 = (i * 0.5) * direction_multiplier
		var angle2 = angle1 + PI

		var dir1 = Vector2(cos(angle1), sin(angle1))
		var dir2 = Vector2(cos(angle2), sin(angle2))

		get_tree().create_timer(delay).timeout.connect(
			func():
				projectile_pool.spawn_projectile(center, dir1, projectile_type)
				projectile_pool.spawn_projectile(center, dir2, projectile_type)
		)

# Cone/Fan Patterns
func pattern_cone(origin: Vector2, target_direction: Vector2, cone_angle: float, count: int, projectile_type: String = "default"):
	if not projectile_pool: return
	projectile_pool.spawn_pattern_cone(origin, target_direction, cone_angle, count, projectile_type)

func pattern_rotating_cone(origin: Vector2, initial_direction: Vector2, cone_angle: float, count: int, rotations: float = 1.0, duration: float = 2.0, projectile_type: String = "default"):
	if not projectile_pool: return
	var shots = int(duration * 10)  # 10 shots per second
	var rotation_per_shot = (TAU * rotations) / shots

	for i in range(shots):
		var delay = i * (duration / shots)
		var current_angle = initial_direction.angle() + (i * rotation_per_shot)
		var current_direction = Vector2(cos(current_angle), sin(current_angle))

		get_tree().create_timer(delay).timeout.connect(
			func(): projectile_pool.spawn_pattern_cone(origin, current_direction, cone_angle, count, projectile_type)
		)

# Wave Patterns
func pattern_wave(start_pos: Vector2, end_pos: Vector2, wave_height: float, count: int, projectile_type: String = "default"):
	if not projectile_pool: return
	projectile_pool.spawn_pattern_wave(start_pos, end_pos, wave_height, count, projectile_type)

func pattern_sine_wave(origin: Vector2, direction: Vector2, amplitude: float, frequency: float, count: int, projectile_type: String = "default"):
	if not projectile_pool: return
	var perpendicular = Vector2(-direction.y, direction.x)

	for i in range(count):
		var t = float(i) / float(count - 1)
		var wave_offset = sin(t * frequency * TAU) * amplitude
		var spawn_direction = direction + perpendicular * wave_offset * 0.3
		spawn_direction = spawn_direction.normalized()

		var delay = i * 0.05
		get_tree().create_timer(delay).timeout.connect(
			func(): projectile_pool.spawn_projectile(origin, spawn_direction, projectile_type)
		)

# Advanced Patterns
func pattern_flower(center: Vector2, petals: int = 6, layers: int = 3, projectile_type: String = "default"):
	if not projectile_pool: return
	for layer in range(layers):
		var layer_delay = layer * 0.3
		var layer_radius = 30.0 + layer * 20
		var projectiles_in_layer = petals * (layer + 1)

		get_tree().create_timer(layer_delay).timeout.connect(
			func(): projectile_pool.spawn_pattern_circle(center, layer_radius, projectiles_in_layer, projectile_type)
		)

func pattern_star(center: Vector2, points: int = 5, inner_radius: float = 40.0, outer_radius: float = 80.0, projectile_type: String = "default"):
	if not projectile_pool: return
	var angle_step = TAU / (points * 2)

	for i in range(points * 2):
		var angle = i * angle_step
		var radius = inner_radius if i % 2 == 0 else outer_radius
		var direction = Vector2(cos(angle), sin(angle))
		var spawn_pos = center + direction * radius * 0.3

		var delay = i * 0.1
		get_tree().create_timer(delay).timeout.connect(
			func(): projectile_pool.spawn_projectile(spawn_pos, direction, projectile_type)
		)

func pattern_cross(center: Vector2, arms: int = 4, projectiles_per_arm: int = 5, arm_length: float = 100.0, projectile_type: String = "default"):
	if not projectile_pool: return
	var angle_step = TAU / arms

	for arm in range(arms):
		var arm_angle = arm * angle_step
		var arm_direction = Vector2(cos(arm_angle), sin(arm_angle))

		for i in range(projectiles_per_arm):
			var distance = (i + 1) * (arm_length / projectiles_per_arm)
			var spawn_pos = center + arm_direction * distance * 0.5
			var delay = i * 0.1

			get_tree().create_timer(delay).timeout.connect(
				func(): projectile_pool.spawn_projectile(spawn_pos, arm_direction, projectile_type)
			)

# Tracking/Homing Patterns
func pattern_homing_barrage(origin: Vector2, target: Node, count: int = 8, spread_delay: float = 0.2, projectile_type: String = "dark_orb"):
	if not projectile_pool or not is_instance_valid(target): return

	for i in range(count):
		var delay = i * spread_delay
		var random_angle = randf() * TAU
		var initial_direction = Vector2(cos(random_angle), sin(random_angle))

		get_tree().create_timer(delay).timeout.connect(
			func():
				var projectile = projectile_pool.spawn_projectile(origin, initial_direction, projectile_type)
				if projectile:
					projectile.set_homing_target(target)
		)

# Rain/Shower Patterns
func pattern_rain(area_center: Vector2, area_size: Vector2, count: int, duration: float = 3.0, projectile_type: String = "default"):
	if not projectile_pool: return

	for i in range(count):
		var delay = randf() * duration
		var spawn_x = area_center.x + randf_range(-area_size.x/2, area_size.x/2)
		var spawn_y = area_center.y - area_size.y/2 - 50  # Start above the area
		var spawn_pos = Vector2(spawn_x, spawn_y)
		var direction = Vector2(randf_range(-0.2, 0.2), 1.0).normalized()  # Mostly downward

		get_tree().create_timer(delay).timeout.connect(
			func(): projectile_pool.spawn_projectile(spawn_pos, direction, projectile_type)
		)

# Egyptian Themed Patterns
func pattern_ankh(center: Vector2, size: float = 60.0, projectile_type: String = "light_beam"):
	if not projectile_pool: return
	# Ankh cross pattern
	var positions = [
		Vector2(0, -size),      # Top
		Vector2(-size*0.7, -size*0.3),  # Top left
		Vector2(size*0.7, -size*0.3),   # Top right
		Vector2(0, 0),          # Center
		Vector2(0, size*0.5),   # Bottom
		Vector2(0, size)        # Bottom tip
	]

	for i in range(positions.size()):
		var spawn_pos = center + positions[i]
		var direction = positions[i].normalized()
		var delay = i * 0.2

		get_tree().create_timer(delay).timeout.connect(
			func(): projectile_pool.spawn_projectile(spawn_pos, direction, projectile_type)
		)

func pattern_eye_of_ra(center: Vector2, radius: float = 80.0, projectile_type: String = "fire_bolt"):
	if not projectile_pool: return
	# Eye shape with central beam
	pattern_circle(center, radius, 12, projectile_type)

	get_tree().create_timer(0.5).timeout.connect(
		func():
			# Central focusing beam
			for i in range(4):
				var angle = i * PI/2
				var direction = Vector2(cos(angle), sin(angle))
				projectile_pool.spawn_projectile(center, direction, "light_beam")
	)

# Utility functions for pattern management
func get_pattern_difficulty(pattern_name: String) -> int:
	match pattern_name:
		"single", "burst": return 1
		"circle", "cone": return 2
		"spiral", "wave": return 3
		"flower", "star": return 4
		"double_spiral", "rotating_cone": return 5
		_: return 1

func execute_pattern_by_name(pattern_name: String, params: Dictionary):
	match pattern_name:
		"single":
			pattern_single(params.get("origin", Vector2.ZERO), params.get("direction", Vector2.RIGHT), params.get("type", "default"))
		"circle":
			pattern_circle(params.get("center", Vector2.ZERO), params.get("radius", 20.0), params.get("count", 8), params.get("type", "default"))
		"spiral":
			pattern_spiral(params.get("center", Vector2.ZERO), params.get("arms", 4), params.get("turns", 2.0), params.get("projectiles_per_arm", 8), params.get("type", "default"))
		"cone":
			pattern_cone(params.get("origin", Vector2.ZERO), params.get("direction", Vector2.RIGHT), params.get("angle", PI/3), params.get("count", 5), params.get("type", "default"))
		"flower":
			pattern_flower(params.get("center", Vector2.ZERO), params.get("petals", 6), params.get("layers", 3), params.get("type", "default"))
		"ankh":
			pattern_ankh(params.get("center", Vector2.ZERO), params.get("size", 60.0), params.get("type", "light_beam"))
		"eye_of_ra":
			pattern_eye_of_ra(params.get("center", Vector2.ZERO), params.get("radius", 80.0), params.get("type", "fire_bolt"))
		_:
			print("[BulletPatterns] Unknown pattern: ", pattern_name)