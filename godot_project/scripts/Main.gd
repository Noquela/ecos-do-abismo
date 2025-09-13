extends Node2D

@onready var camera: CameraController = $Camera2D
var player: Player
var game_initialized: bool = false

func _ready():
	setup_scene()
	call_deferred("validate_game_loop")

func setup_scene():
	# Load and instantiate player
	var player_scene = preload("res://scenes/player/Player.tscn")
	player = player_scene.instantiate()

	# Attach the player script
	player.set_script(preload("res://scripts/player/Player.gd"))
	player.add_to_group("player")  # Add to group for enemy detection

	player.position = Vector2(0, 0)  # Center of the room
	add_child(player)

	# Setup camera to follow player
	camera.set_script(preload("res://scripts/CameraController.gd"))
	camera.set_target(player)

	# Connect player signals
	player.health_changed.connect(_on_player_health_changed)
	player.player_died.connect(_on_player_died)
	player.dash_used.connect(_on_player_dash_used)
	player.attack_performed.connect(_on_player_attack_performed)

	# Spawn test enemies
	spawn_test_enemies()

	game_initialized = true
	print("[Main] Egyptian tomb initialized - The adventure begins!")
	print("[Main] Golden circle = Player, Dark red circles = Enemies")
	print("[Main] Controls: WASD (move), Mouse/Space (attack), Shift (dash), Enter (switch weapon)")

func validate_game_loop():
	print("[Main] === GAME LOOP VALIDATION ===")
	print("[Main] FPS: ", Engine.get_frames_per_second())
	print("[Main] Player exists: ", player != null)
	print("[Main] Camera target set: ", camera.target != null)
	print("[Main] Game initialized: ", game_initialized)

	if player:
		player.validate_systems()

	print("[Main] === VALIDATION COMPLETE ===")

func _on_player_health_changed(new_health: int, max_health: int):
	print("[Main] Player health: ", new_health, "/", max_health)

func _on_player_died():
	print("[Main] Game Over - The pharaoh's curse claims another soul...")
	# TODO: Show game over screen

func _on_player_dash_used():
	# Camera shake on dash
	camera.shake_camera(2.0, 0.1)

func _on_player_attack_performed():
	# Small camera shake on attack
	camera.shake_camera(1.0, 0.05)

func spawn_test_enemies():
	# Spawn multiple test enemies around the player
	var enemy_positions = [
		Vector2(200, 0),
		Vector2(-200, 100),
		Vector2(100, -200),
		Vector2(-150, -150)
	]

	for pos in enemy_positions:
		var enemy_scene = preload("res://scenes/enemies/Enemy.tscn")
		var enemy = enemy_scene.instantiate()

		# Attach enemy script
		enemy.set_script(preload("res://scripts/enemies/Enemy.gd"))

		enemy.position = pos
		add_child(enemy)

		# Connect enemy signals
		enemy.enemy_died.connect(_on_enemy_died)
		enemy.enemy_attacked_player.connect(_on_enemy_attacked_player)
		enemy.health_changed.connect(_on_enemy_health_changed)

	print("[Main] Spawned ", enemy_positions.size(), " test enemies")

func _on_enemy_died():
	print("[Main] An enemy has been defeated!")

func _on_enemy_attacked_player():
	print("[Main] Player was attacked by enemy!")

func _on_enemy_health_changed(new_health: int, max_health: int):
	print("[Main] Enemy health: ", new_health, "/", max_health)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()