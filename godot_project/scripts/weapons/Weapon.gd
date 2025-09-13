extends Node2D
class_name Weapon

# Weapon stats based on roadmap specs
@export var weapon_name: String = "Egyptian Weapon"
@export var damage: int = 25
@export var attack_rate: float = 1.5  # attacks per second
@export var reach: int = 80           # pixels
@export var knockback: float = 100.0

# Attack properties
@export var attack_duration: float = 0.3
@export var windup_time: float = 0.1
@export var recovery_time: float = 0.2

# Components
@onready var hitbox: Area2D = $HitBox
@onready var collision_shape: CollisionShape2D = $HitBox/CollisionShape2D

# State
var is_attacking: bool = false
var attack_timer: float = 0.0
var cooldown_timer: float = 0.0
var targets_hit: Array[Node] = []

# Visual feedback
var attack_color: Color = Color.RED
var idle_color: Color = Color.GRAY

# Signals
signal attack_started
signal attack_hit(target: Node, damage_dealt: int)
signal attack_finished
signal weapon_ready

func _ready():
	setup_weapon()
	setup_signals()

func _physics_process(delta):
	update_timers(delta)
	update_visual_feedback()

func setup_weapon():
	# Setup collision shape based on weapon reach
	if collision_shape.shape == null:
		var rect = RectangleShape2D.new()
		rect.size = Vector2(reach, 20)
		collision_shape.shape = rect

	# Initially disable hitbox
	hitbox.set_deferred("monitoring", false)
	hitbox.collision_layer = 0  # Don't collide with anything
	hitbox.collision_mask = 2   # Only detect enemies (layer 2)

	print("[Weapon] ", weapon_name, " initialized - Damage: ", damage, ", Reach: ", reach)

func setup_signals():
	# Connect area signals for hit detection
	hitbox.area_entered.connect(_on_area_entered)
	hitbox.body_entered.connect(_on_body_entered)

func _draw():
	# Debug visualization
	var color = idle_color
	if is_attacking:
		color = attack_color

	# Draw weapon reach indicator
	var reach_rect = Rect2(-reach/2, -10, reach, 20)
	draw_rect(reach_rect, color, false, 2)

	# Draw attack arc for visual feedback
	if is_attacking:
		draw_arc(Vector2.ZERO, reach/2, -PI/4, PI/4, 16, attack_color, 3)

func can_attack() -> bool:
	return not is_attacking and cooldown_timer <= 0

func start_attack() -> bool:
	if not can_attack():
		return false

	is_attacking = true
	attack_timer = attack_duration
	cooldown_timer = 1.0 / attack_rate
	targets_hit.clear()

	# Enable hitbox after windup
	var windup_timer = get_tree().create_timer(windup_time)
	windup_timer.timeout.connect(_activate_hitbox)

	attack_started.emit()
	queue_redraw()

	print("[Weapon] Attack started with ", weapon_name)
	return true

func _activate_hitbox():
	if is_attacking:
		hitbox.set_deferred("monitoring", true)
		print("[Weapon] Hitbox activated")

func _on_area_entered(area: Area2D):
	# Hit another hitbox (enemy hurtbox)
	var target = area.get_parent()
	_process_hit(target)

func _on_body_entered(body: Node2D):
	# Hit a body directly
	_process_hit(body)

func _process_hit(target: Node):
	if not is_attacking or target in targets_hit:
		return

	# Check if target has a take_damage method
	if not target.has_method("take_damage"):
		return

	# Add to hit list to prevent multiple hits
	targets_hit.append(target)

	# Calculate knockback direction
	var knockback_direction = (target.global_position - global_position).normalized()

	# Deal damage
	target.take_damage(damage, global_position)

	# Apply knockback if target has velocity
	if target.has_method("set") and "velocity" in target:
		target.velocity += knockback_direction * knockback

	attack_hit.emit(target, damage)
	print("[Weapon] Hit ", target.name, " for ", damage, " damage")

func update_timers(delta):
	# Attack duration timer
	if attack_timer > 0:
		attack_timer -= delta
		if attack_timer <= 0:
			finish_attack()

	# Cooldown timer
	if cooldown_timer > 0:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			weapon_ready.emit()

func finish_attack():
	is_attacking = false
	hitbox.set_deferred("monitoring", false)
	attack_finished.emit()
	queue_redraw()
	print("[Weapon] Attack finished")

func update_visual_feedback():
	queue_redraw()

# Weapon presets from roadmap
static func create_khopesh() -> Weapon:
	var khopesh = preload("res://scenes/weapons/Weapon.tscn").instantiate()
	khopesh.weapon_name = "Khopesh of the Pharaoh"
	khopesh.damage = 25
	khopesh.attack_rate = 1.5
	khopesh.reach = 80
	khopesh.knockback = 100.0
	khopesh.attack_color = Color.GOLD
	return khopesh

static func create_spear_of_ra() -> Weapon:
	var spear = preload("res://scenes/weapons/Weapon.tscn").instantiate()
	spear.weapon_name = "Spear of Ra"
	spear.damage = 35
	spear.attack_rate = 1.0
	spear.reach = 120
	spear.knockback = 150.0
	spear.attack_color = Color.ORANGE
	return spear

static func create_axe_of_sobek() -> Weapon:
	var axe = preload("res://scenes/weapons/Weapon.tscn").instantiate()
	axe.weapon_name = "Axe of Sobek"
	axe.damage = 50
	axe.attack_rate = 0.7
	axe.reach = 100
	axe.knockback = 200.0
	axe.attack_color = Color.DARK_GREEN
	return axe

# Utility functions
func get_attack_cooldown_percentage() -> float:
	if cooldown_timer <= 0:
		return 0.0
	return cooldown_timer / (1.0 / attack_rate)

func get_dps() -> float:
	return damage * attack_rate