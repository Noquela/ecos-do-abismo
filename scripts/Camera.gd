extends Camera2D

var player: CharacterBody2D
@export var follow_speed: float = 10.0  # Muito mais rápido

func _ready():
	# Find the player
	player = get_node("../Player") as CharacterBody2D
	if player:
		print("[Camera] Player found, following enabled")
		# Start camera at player position
		global_position = player.global_position

func _process(_delta):
	if player:
		# INSTANT camera following - no lerp, no delay, no dead zone
		global_position = player.global_position