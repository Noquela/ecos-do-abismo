extends Enemy
class_name CasterEnemy

# Caster-specific properties
@export var cast_range: float = 300.0
@export var spell_damage: int = 15
@export var cast_cooldown: float = 2.0
@export var spell_type: String = "fire_bolt"
@export var projectile_count: int = 1
@export var cast_pattern: String = "single"  # single, burst, circle, cone

# Spell casting state
var cast_timer: float = 0.0
var is_casting: bool = false
var cast_windup_time: float = 0.8
var cast_channel_time: float = 0.3
var cast_current_time: float = 0.0

# Components
var projectile_pool: ProjectilePool
var cast_indicator: Node2D

# Visual effects
var cast_circle_radius: float = 0.0
var cast_glow_intensity: float = 0.0

# Signals
signal spell_started
signal spell_cast
signal spell_finished

func _ready():
	super._ready()
	setup_caster()

	# Override enemy stats for caster
	health = 60
	speed = 40
	damage = 10  # Reduced melee damage since this is primarily ranged
	detection_range = 250
	attack_range = cast_range

func setup_caster():
	# Find projectile pool in scene
	projectile_pool = get_node("/root/Main/ProjectilePool") if get_node_or_null("/root/Main/ProjectilePool") else null
	if not projectile_pool:
		print("[CasterEnemy] Warning: ProjectilePool not found!")

	# Setup cast indicator
	cast_indicator = Node2D.new()
	cast_indicator.name = "CastIndicator"
	add_child(cast_indicator)

	print("[CasterEnemy] Sacerdote de Thoth initialized - Spell:", spell_type, " Range:", cast_range)

func _physics_process(delta):
	super._physics_process(delta)
	update_casting(delta)

func _draw():
	super._draw()
	draw_caster_effects()

func draw_caster_effects():
	# Draw cast range when detecting player
	if current_state == EnemyState.CHASE:
		draw_arc(Vector2.ZERO, cast_range, 0, TAU, 32, Color.BLUE, 2)

	# Draw casting effects
	if is_casting:
		# Pulsing circle during cast
		var pulse_alpha = 0.5 + sin(cast_current_time * 10) * 0.3
		var cast_color = Color.ORANGE
		cast_color.a = pulse_alpha
		draw_circle(Vector2.ZERO, cast_circle_radius, cast_color)

		# Glow effect
		for i in range(3):
			var glow_color = Color.YELLOW
			glow_color.a = cast_glow_intensity * (0.3 - i * 0.1)
			draw_circle(Vector2.ZERO, 25 + i * 5, glow_color)

func update_casting(delta):
	cast_timer -= delta

	if is_casting:
		cast_current_time += delta

		# Update visual effects
		var cast_progress = cast_current_time / cast_windup_time
		cast_circle_radius = lerp(0.0, 40.0, cast_progress)
		cast_glow_intensity = sin(cast_progress * PI)

		queue_redraw()

		if cast_current_time >= cast_windup_time:
			execute_spell()

func handle_attack_state(delta):
	if not player_ref or not is_instance_valid(player_ref):
		change_state(EnemyState.IDLE)
		return

	var distance = global_position.distance_to(player_ref.global_position)

	# Start casting if in range and not casting
	if distance <= cast_range and cast_timer <= 0 and not is_casting:
		start_casting()
	elif distance > cast_range:
		# Too far to cast, try to get closer
		change_state(EnemyState.CHASE)
	elif not is_casting:
		# Face the player while waiting for cooldown
		look_at(player_ref.global_position)

func start_casting():
	if not projectile_pool:
		print("[CasterEnemy] Cannot cast - no ProjectilePool available")
		return

	is_casting = true
	cast_current_time = 0.0
	cast_timer = cast_cooldown
	velocity = Vector2.ZERO  # Stop moving while casting

	spell_started.emit()
	print("[CasterEnemy] Starting to cast ", spell_type)

func execute_spell():
	if not projectile_pool or not player_ref:
		finish_casting()
		return

	var target_direction = (player_ref.global_position - global_position).normalized()

	match cast_pattern:
		"single":
			cast_single_projectile(target_direction)
		"burst":
			cast_burst_pattern(target_direction)
		"circle":
			cast_circle_pattern()
		"cone":
			cast_cone_pattern(target_direction)
		_:
			cast_single_projectile(target_direction)

	spell_cast.emit()
	print("[CasterEnemy] Cast ", spell_type, " with pattern ", cast_pattern)

	finish_casting()

func cast_single_projectile(direction: Vector2):
	projectile_pool.spawn_projectile(global_position, direction, spell_type)

func cast_burst_pattern(direction: Vector2):
	# Fire multiple projectiles in sequence
	for i in range(projectile_count):
		var delay = i * 0.1
		get_tree().create_timer(delay).timeout.connect(
			func(): projectile_pool.spawn_projectile(global_position, direction, spell_type)
		)

func cast_circle_pattern():
	projectile_pool.spawn_pattern_circle(global_position, 20.0, 8, spell_type)

func cast_cone_pattern(direction: Vector2):
	projectile_pool.spawn_pattern_cone(global_position, direction, PI/3, 5, spell_type)

func finish_casting():
	is_casting = false
	cast_current_time = 0.0
	cast_circle_radius = 0.0
	cast_glow_intensity = 0.0

	spell_finished.emit()
	queue_redraw()

# Override take_damage to add spell interruption
func take_damage(amount: int, source_position: Vector2):
	super.take_damage(amount, source_position)

	# Interrupt casting when taking damage
	if is_casting:
		print("[CasterEnemy] Spell interrupted by damage!")
		finish_casting()
		cast_timer = cast_cooldown * 0.5  # Reduced cooldown after interruption

# Caster presets
static func create_sacerdote_thoth() -> CasterEnemy:
	var sacerdote = preload("res://scenes/enemies/CasterEnemy.tscn").instantiate()
	sacerdote.enemy_name = "Sacerdote de Thoth"
	sacerdote.health = 60
	sacerdote.speed = 40
	sacerdote.spell_type = "light_beam"
	sacerdote.cast_range = 280
	sacerdote.cast_cooldown = 2.5
	sacerdote.cast_pattern = "single"
	sacerdote.enemy_color = Color.CYAN
	return sacerdote

static func create_fire_cultist() -> CasterEnemy:
	var cultist = preload("res://scenes/enemies/CasterEnemy.tscn").instantiate()
	cultist.enemy_name = "Cultista do Fogo"
	cultist.health = 50
	cultist.speed = 45
	cultist.spell_type = "fire_bolt"
	cultist.cast_range = 250
	cultist.cast_cooldown = 2.0
	cultist.cast_pattern = "burst"
	cultist.projectile_count = 3
	cultist.enemy_color = Color.ORANGE_RED
	return cultist

static func create_dark_mage() -> CasterEnemy:
	var mage = preload("res://scenes/enemies/CasterEnemy.tscn").instantiate()
	mage.enemy_name = "Mago das Trevas"
	mage.health = 80
	mage.speed = 35
	mage.spell_type = "dark_orb"
	mage.cast_range = 320
	mage.cast_cooldown = 3.0
	mage.cast_pattern = "circle"
	mage.enemy_color = Color.PURPLE
	return mage