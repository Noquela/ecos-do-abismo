extends Node2D

# Weapon System Isométrico - Sprint 2
# Roadmap: Weapon orientation adaptado para vista isométrica

enum WeaponType { KHOPESH, SPEAR_OF_RA, AXE_OF_SOBEK }

# Weapon stats conforme roadmap
var weapon_stats = {
	WeaponType.KHOPESH: {
		"damage": 25,
		"attack_speed": 1.5,
		"range": 80,
		"name": "Khopesh"
	},
	WeaponType.SPEAR_OF_RA: {
		"damage": 35,
		"attack_speed": 1.0,
		"range": 120,
		"name": "Lança de Rá"
	},
	WeaponType.AXE_OF_SOBEK: {
		"damage": 50,
		"attack_speed": 0.7,
		"range": 100,
		"name": "Machado de Sobek"
	}
}

@export var current_weapon: WeaponType = WeaponType.KHOPESH
var is_attacking: bool = false
var attack_cooldown: float = 0.0

# Orientação da arma para vista isométrica
var weapon_angle: float = 0.0
var weapon_offset: Vector2 = Vector2.ZERO

func _ready():
	print("[WeaponSystem] Weapon system initialized - ", weapon_stats[current_weapon]["name"])
	print("[WeaponSystem] Ready - parent is: ", get_parent())

func _process(delta):
	if attack_cooldown > 0:
		attack_cooldown -= delta

	# Atualizar orientação da arma baseado no mouse
	update_weapon_orientation()

func update_weapon_orientation():
	# Calcular direção para o mouse em coordenadas isométricas
	var mouse_pos = get_global_mouse_position()
	var player_pos = get_parent().global_position
	var direction_to_mouse = (mouse_pos - player_pos).normalized()

	# Converter direção para ângulo isométrico
	weapon_angle = atan2(direction_to_mouse.y, direction_to_mouse.x)

	# Offset da arma baseado na direção (ao lado do player)
	weapon_offset = direction_to_mouse * 25

	# FORÇAR redraw visual
	queue_redraw()

func can_attack() -> bool:
	return attack_cooldown <= 0 and not is_attacking

func start_attack() -> bool:
	if not can_attack():
		return false

	var stats = weapon_stats[current_weapon]
	is_attacking = true
	attack_cooldown = 1.0 / stats["attack_speed"]

	print("[WeaponSystem] Attack started with ", stats["name"], " - damage: ", stats["damage"])

	# Timer para duração do ataque
	var attack_timer = get_tree().create_timer(0.3)
	attack_timer.timeout.connect(_on_attack_finished)

	return true

func _on_attack_finished():
	is_attacking = false
	print("[WeaponSystem] Attack finished")

func get_current_damage() -> int:
	return weapon_stats[current_weapon]["damage"]

func get_current_range() -> float:
	return weapon_stats[current_weapon]["range"]

func _draw():
	# Desenhar arma na orientação correta para perspectiva isométrica
	if not get_parent():
		return

	var stats = weapon_stats[current_weapon]
	var weapon_color = Color.GRAY

	if is_attacking:
		weapon_color = Color.WHITE

	# Desenhar arma baseado no tipo
	match current_weapon:
		WeaponType.KHOPESH:
			draw_khopesh(weapon_color)
		WeaponType.SPEAR_OF_RA:
			draw_spear(weapon_color)
		WeaponType.AXE_OF_SOBEK:
			draw_axe(weapon_color)

	# Desenhar range de ataque quando atacando
	if is_attacking:
		var range_circle = stats["range"]
		draw_circle(Vector2.ZERO, range_circle, Color.RED, false, 2)

func draw_khopesh(color: Color):
	# Khopesh curvado - formato egípcio característico
	var weapon_length = 30
	var handle_pos = weapon_offset
	var blade_end = handle_pos + Vector2(cos(weapon_angle), sin(weapon_angle)) * weapon_length

	# Cabo
	draw_line(handle_pos, handle_pos + Vector2(cos(weapon_angle), sin(weapon_angle)) * 15, Color.BROWN, 3)
	# Lâmina curvada
	draw_line(handle_pos + Vector2(cos(weapon_angle), sin(weapon_angle)) * 15, blade_end, color, 4)
	# Curva do khopesh
	var curve_point = blade_end + Vector2(cos(weapon_angle + PI/2), sin(weapon_angle + PI/2)) * 8
	draw_line(blade_end, curve_point, color, 3)

func draw_spear(color: Color):
	# Lança longa e reta
	var weapon_length = 45
	var handle_pos = weapon_offset
	var spear_end = handle_pos + Vector2(cos(weapon_angle), sin(weapon_angle)) * weapon_length

	# Cabo
	draw_line(handle_pos, spear_end - Vector2(cos(weapon_angle), sin(weapon_angle)) * 8, Color.BROWN, 2)
	# Ponta da lança
	draw_line(spear_end - Vector2(cos(weapon_angle), sin(weapon_angle)) * 8, spear_end, color, 5)

func draw_axe(color: Color):
	# Machado largo e pesado
	var weapon_length = 25
	var handle_pos = weapon_offset
	var axe_head = handle_pos + Vector2(cos(weapon_angle), sin(weapon_angle)) * weapon_length

	# Cabo
	draw_line(handle_pos, axe_head, Color.BROWN, 4)
	# Lâmina do machado (formato largo)
	var perpendicular = Vector2(cos(weapon_angle + PI/2), sin(weapon_angle + PI/2))
	draw_line(axe_head - perpendicular * 10, axe_head + perpendicular * 10, color, 6)