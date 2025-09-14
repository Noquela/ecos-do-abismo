extends CharacterBody2D

# Enemy básico para testar sistema de colisão isométrico

@export var max_health: int = 100
@export var speed: float = 150.0

var current_health: int
var is_dead: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	current_health = max_health
	setup_collision()
	print("[Enemy] Enemy spawned with ", max_health, " health")

func _physics_process(_delta):
	if is_dead:
		return

	# AI básico: mover em direção ao player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var direction_to_player = (player.global_position - global_position).normalized()

		# Converter direção para coordenadas isométricas usando chamada estática
		velocity = direction_to_player * speed

	move_and_slide()

func setup_collision():
	if collision_shape.shape == null:
		var capsule = CapsuleShape2D.new()
		capsule.radius = 12
		capsule.height = 24
		collision_shape.shape = capsule

func take_damage(damage: int):
	if is_dead:
		return

	current_health -= damage

	if current_health <= 0:
		die()

func die():
	is_dead = true

	# Efeito visual de morte
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.2)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
	tween.tween_callback(queue_free)

func _draw():
	if is_dead:
		return

	# Desenhar enemy como losango vermelho para perspectiva isométrica
	var enemy_color = Color.RED
	var enemy_size = 15

	# Piscar quando levou dano
	if current_health < max_health:
		var flash_intensity = 1.0 - (float(current_health) / float(max_health))
		enemy_color = enemy_color.lerp(Color.WHITE, flash_intensity * 0.5)

	var diamond_points = PackedVector2Array([
		Vector2(0, -enemy_size),       # Top
		Vector2(enemy_size * 0.8, 0),  # Right
		Vector2(0, enemy_size),        # Bottom
		Vector2(-enemy_size * 0.8, 0)  # Left
	])

	draw_colored_polygon(diamond_points, enemy_color)

	# Barra de vida
	if current_health < max_health:
		var health_bar_width = 30
		var health_bar_height = 4
		var health_percent = float(current_health) / float(max_health)

		# Background da barra
		draw_rect(Rect2(-health_bar_width/2, -enemy_size - 15, health_bar_width, health_bar_height), Color.BLACK)
		# Vida atual
		draw_rect(Rect2(-health_bar_width/2, -enemy_size - 15, health_bar_width * health_percent, health_bar_height), Color.GREEN)