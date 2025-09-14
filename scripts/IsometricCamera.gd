extends Camera2D

# Câmera Isométrica - Sprint 1 + 4
# Roadmap: Camera2D com rotação Z = 30° + bounds para salas

var player: CharacterBody2D
@export var follow_speed: float = 5.0
@export var enable_bounds: bool = true

var room_bounds: Rect2 = Rect2(-500, -300, 1000, 600)  # Default room bounds

func _ready():
	print("[IsometricCamera] Initializing isometric camera system")

	# ROADMAP CRÍTICO: Camera2D com rotação Z = 30°
	rotation = deg_to_rad(30)  # Vista isométrica verdadeira

	# Encontrar player
	player = get_node("../Player") as CharacterBody2D
	if player:
		print("[IsometricCamera] Player found - isometric following enabled")
		global_position = player.global_position
	else:
		print("[IsometricCamera] ERROR: Player not found!")

func _process(delta):
	if player:
		# ROADMAP: Manter smooth camera following em isométrico
		var target_position = player.global_position

		# Aplicar bounds da sala se habilitado
		if enable_bounds:
			target_position = apply_camera_bounds(target_position)

		global_position = global_position.lerp(target_position, follow_speed * delta)

func apply_camera_bounds(target_pos: Vector2) -> Vector2:
	# Aplicar limites da câmera para não sair da sala
	var viewport_size = get_viewport_rect().size
	var half_viewport = viewport_size * 0.5 / zoom

	var clamped_pos = Vector2(
		clamp(target_pos.x, room_bounds.position.x + half_viewport.x, room_bounds.position.x + room_bounds.size.x - half_viewport.x),
		clamp(target_pos.y, room_bounds.position.y + half_viewport.y, room_bounds.position.y + room_bounds.size.y - half_viewport.y)
	)

	return clamped_pos

func set_room_bounds(bounds: Rect2):
	# Definir novos bounds da sala
	room_bounds = bounds
	print("[IsometricCamera] Room bounds updated: ", bounds)