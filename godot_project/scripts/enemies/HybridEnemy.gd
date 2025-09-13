extends Enemy
class_name HybridEnemy

# Hybrid enemy that combines melee and ranged attacks
# Based on roadmap: Guerreiro-Sacerdote de Horus

# Combat modes
enum CombatMode {
	MELEE,
	RANGED,
	SWITCHING
}

# Hybrid-specific properties
@export var ranged_damage: int = 20
@export var melee_damage: int = 35
@export var cast_range: float = 200.0
@export var preferred_range: float = 120.0  # Sweet spot between melee and ranged
@export var mode_switch_cooldown: float = 3.0
@export var spell_type: String = "fire_bolt"

# AI decision making
@export var ranged_preference: float = 0.6  # 0.0 = always melee, 1.0 = always ranged
@export var hp_threshold_for_ranged: float = 0.4  # Switch to ranged when low on health

# State tracking
var current_combat_mode: CombatMode = CombatMode.MELEE
var mode_switch_timer: float = 0.0
var is_casting: bool = false
var cast_timer: float = 0.0
var cast_cooldown: float = 2.5

# Components
var projectile_pool: ProjectilePool
var bullet_patterns: BulletPatterns

# Visual effects
var mode_indicator_color: Color = Color.ORANGE
var switching_effect_time: float = 0.0

# Signals
signal mode_switched(new_mode: CombatMode)
signal hybrid_spell_cast
signal tactical_retreat

func _ready():
	super._ready()
	setup_hybrid()

	# Override base enemy stats
	health = 120
	max_health = 120
	speed = 60
	damage = melee_damage
	detection_range = 300
	attack_range = preferred_range

func setup_hybrid():
	# Find systems
	projectile_pool = get_node("/root/Main/ProjectilePool") if get_node_or_null("/root/Main/ProjectilePool") else null

	# Create bullet patterns manager
	bullet_patterns = BulletPatterns.new()
	add_child(bullet_patterns)

	print("[HybridEnemy] Guerreiro-Sacerdote de Horus initialized - Mode:", CombatMode.keys()[current_combat_mode])

func _physics_process(delta):
	super._physics_process(delta)
	update_hybrid_logic(delta)

func _draw():
	super._draw()
	draw_hybrid_effects()

func draw_hybrid_effects():
	# Mode indicator ring
	var ring_color = get_mode_color()
	draw_arc(Vector2.ZERO, 35, 0, TAU, 16, ring_color, 3)

	# Combat range indicators
	if current_state == EnemyState.CHASE or current_state == EnemyState.ATTACK:
		match current_combat_mode:
			CombatMode.MELEE:
				draw_circle(Vector2.ZERO, attack_range, Color.RED, false, 2)
			CombatMode.RANGED:
				draw_circle(Vector2.ZERO, cast_range, Color.BLUE, false, 2)

	# Switching effect
	if switching_effect_time > 0:
		var pulse = sin(switching_effect_time * 15) * 0.5 + 0.5
		var switch_color = Color.YELLOW
		switch_color.a = pulse
		draw_circle(Vector2.ZERO, 40 + pulse * 10, switch_color)

func get_mode_color() -> Color:
	match current_combat_mode:
		CombatMode.MELEE:
			return Color.ORANGE_RED
		CombatMode.RANGED:
			return Color.CYAN
		CombatMode.SWITCHING:
			return Color.YELLOW
		_:
			return Color.WHITE

func update_hybrid_logic(delta):
	mode_switch_timer -= delta
	cast_timer -= delta
	switching_effect_time = max(0, switching_effect_time - delta)

	# AI decision making
	if current_state == EnemyState.CHASE or current_state == EnemyState.ATTACK:
		evaluate_combat_mode()

	# Handle casting
	if is_casting and cast_timer <= 0:
		execute_ranged_attack()

func evaluate_combat_mode():
	if mode_switch_timer > 0 or current_combat_mode == CombatMode.SWITCHING:
		return

	if not player_ref or not is_instance_valid(player_ref):
		return

	var distance_to_player = global_position.distance_to(player_ref.global_position)
	var health_percentage = float(health) / float(max_health)
	var should_use_ranged = false

	# Health-based decision
	if health_percentage <= hp_threshold_for_ranged:
		should_use_ranged = true

	# Distance-based decision
	elif distance_to_player > preferred_range:
		should_use_ranged = randf() < ranged_preference

	# Random tactical decision
	elif randf() < 0.1:  # 10% chance to randomly switch
		should_use_ranged = randf() < ranged_preference

	# Switch mode if needed
	var target_mode = CombatMode.RANGED if should_use_ranged else CombatMode.MELEE
	if target_mode != current_combat_mode:
		switch_combat_mode(target_mode)

func switch_combat_mode(new_mode: CombatMode):
	if mode_switch_timer > 0:
		return

	current_combat_mode = CombatMode.SWITCHING
	switching_effect_time = 0.5
	mode_switch_timer = mode_switch_cooldown

	# Brief pause during switch
	velocity = Vector2.ZERO

	get_tree().create_timer(0.5).timeout.connect(
		func(): complete_mode_switch(new_mode)
	)

	mode_switched.emit(new_mode)
	print("[HybridEnemy] Switching to ", CombatMode.keys()[new_mode], " mode")

func complete_mode_switch(new_mode: CombatMode):
	current_combat_mode = new_mode
	switching_effect_time = 0.0

	# Adjust stats based on mode
	match current_combat_mode:
		CombatMode.MELEE:
			damage = melee_damage
			attack_range = 50.0
			speed = 70  # Faster in melee mode
		CombatMode.RANGED:
			damage = ranged_damage
			attack_range = cast_range
			speed = 50  # Slower but more cautious in ranged mode

	queue_redraw()

func handle_attack_state(delta):
	if not player_ref or not is_instance_valid(player_ref):
		change_state(EnemyState.IDLE)
		return

	var distance = global_position.distance_to(player_ref.global_position)

	match current_combat_mode:
		CombatMode.MELEE:
			handle_melee_attack(distance)
		CombatMode.RANGED:
			handle_ranged_attack(distance)
		CombatMode.SWITCHING:
			# Wait during switch
			velocity = Vector2.ZERO

func handle_melee_attack(distance: float):
	if distance <= attack_range and attack_timer <= 0:
		perform_melee_attack()
	elif distance > attack_range * 1.5:
		# Too far for melee, chase or consider switching
		change_state(EnemyState.CHASE)

func handle_ranged_attack(distance: float):
	if distance <= cast_range and cast_timer <= 0 and not is_casting:
		start_ranged_attack()
	elif distance > cast_range:
		# Try to get in range
		change_state(EnemyState.CHASE)
	elif distance < attack_range * 0.5:
		# Too close, tactical retreat
		perform_tactical_retreat()

func perform_melee_attack():
	super.handle_attack_state(0)  # Use parent's melee attack logic

func start_ranged_attack():
	if not projectile_pool:
		return

	is_casting = true
	cast_timer = 1.0  # Cast time
	velocity = Vector2.ZERO  # Stop moving while casting

	print("[HybridEnemy] Starting ranged attack")

func execute_ranged_attack():
	if not projectile_pool or not player_ref:
		is_casting = false
		return

	var target_direction = (player_ref.global_position - global_position).normalized()

	# Use different attack patterns based on health and situation
	var health_percentage = float(health) / float(max_health)

	if health_percentage < 0.3:
		# Desperate - use powerful pattern
		bullet_patterns.pattern_cone(global_position, target_direction, PI/2, 5, "fire_bolt")
	elif health_percentage < 0.6:
		# Wounded - use medium pattern
		bullet_patterns.pattern_burst(global_position, target_direction, 3, 0.2, spell_type)
	else:
		# Healthy - use basic attack
		bullet_patterns.pattern_single(global_position, target_direction, spell_type)

	is_casting = false
	cast_timer = cast_cooldown
	hybrid_spell_cast.emit()

	print("[HybridEnemy] Executed ranged attack")

func perform_tactical_retreat():
	if not player_ref:
		return

	# Move away from player
	var retreat_direction = (global_position - player_ref.global_position).normalized()
	velocity = retreat_direction * speed * 1.2  # Faster retreat

	tactical_retreat.emit()
	print("[HybridEnemy] Tactical retreat!")

	# Switch to ranged mode if not already
	if current_combat_mode == CombatMode.MELEE:
		switch_combat_mode(CombatMode.RANGED)

# Override take_damage to add tactical responses
func take_damage(amount: int, source_position: Vector2):
	super.take_damage(amount, source_position)

	# Interrupt casting
	if is_casting:
		is_casting = false
		cast_timer = cast_cooldown * 0.5

	# Consider mode switching based on damage
	var health_percentage = float(health) / float(max_health)
	if health_percentage <= hp_threshold_for_ranged and current_combat_mode == CombatMode.MELEE:
		switch_combat_mode(CombatMode.RANGED)

# Hybrid enemy presets
static func create_guerreiro_sacerdote() -> HybridEnemy:
	var guerreiro = preload("res://scenes/enemies/HybridEnemy.tscn").instantiate()
	guerreiro.enemy_name = "Guerreiro-Sacerdote de Horus"
	guerreiro.health = 120
	guerreiro.max_health = 120
	guerreiro.melee_damage = 35
	guerreiro.ranged_damage = 20
	guerreiro.speed = 60
	guerreiro.cast_range = 200
	guerreiro.ranged_preference = 0.6
	guerreiro.spell_type = "fire_bolt"
	guerreiro.enemy_color = Color.GOLD
	return guerreiro

static func create_anubis_guard() -> HybridEnemy:
	var guard = preload("res://scenes/enemies/HybridEnemy.tscn").instantiate()
	guard.enemy_name = "Guardião de Anubis"
	guard.health = 100
	guard.max_health = 100
	guard.melee_damage = 40
	guard.ranged_damage = 15
	guard.speed = 65
	guard.cast_range = 180
	guard.ranged_preference = 0.4  # Prefers melee
	guard.spell_type = "dark_orb"
	guard.enemy_color = Color.DARK_SLATE_GRAY
	return guard

static func create_temple_sentinel() -> HybridEnemy:
	var sentinel = preload("res://scenes/enemies/HybridEnemy.tscn").instantiate()
	sentinel.enemy_name = "Sentinela do Templo"
	sentinel.health = 150
	sentinel.max_health = 150
	sentinel.melee_damage = 30
	sentinel.ranged_damage = 25
	sentinel.speed = 55
	sentinel.cast_range = 220
	sentinel.ranged_preference = 0.7  # Prefers ranged
	sentinel.spell_type = "light_beam"
	sentinel.hp_threshold_for_ranged = 0.6  # Switches earlier
	sentinel.enemy_color = Color.LIGHT_BLUE
	return sentinel