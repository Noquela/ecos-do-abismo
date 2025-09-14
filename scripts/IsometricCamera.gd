extends Camera2D

# Câmera Isométrica - Sprint 1
# Roadmap: Camera2D com rotação Z = 30° (ou 26.565°)

var player: CharacterBody2D
@export var follow_speed: float = 5.0

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
		global_position = global_position.lerp(player.global_position, follow_speed * delta)