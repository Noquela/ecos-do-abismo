extends CharacterBody2D

# Player Isométrico - Sprint 1
# Roadmap: Converter input WASD para movimento diagonal isométrico

# Configurações de movimento
@export var speed: float = 300.0
@export var dash_power: float = 800.0
@export var dash_duration: float = 0.3

# Estado
var is_dashing: bool = false
var dash_timer: float = 0.0

# Componentes
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	print("[Player] Egyptian warrior ready for isometric combat!")
	setup_collision()

func _physics_process(delta):
	if not is_dashing:
		handle_input()
		handle_movement(delta)
	else:
		handle_dash(delta)

	move_and_slide()

func handle_input():
	# Dash input
	if Input.is_action_just_pressed("dash") and not is_dashing:
		start_dash()

func handle_movement(delta):
	# ROADMAP CRÍTICO: Input vector conversion para diagonal movement
	var raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if raw_input != Vector2.ZERO:
		# Converter input para coordenadas isométricas
		var isometric_input = IsometricUtils.convert_input_to_isometric(raw_input)
		velocity = isometric_input * speed
		print("[Player] Isometric movement: raw=", raw_input, " iso=", isometric_input)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed * 3.0 * delta)

func start_dash():
	if is_dashing:
		return

	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector == Vector2.ZERO:
		return

	# ROADMAP: Dash funciona na direção visual correta
	var dash_direction = IsometricUtils.convert_input_to_isometric(input_vector)

	is_dashing = true
	dash_timer = dash_duration
	velocity = dash_direction * dash_power

	print("[Player] Dash started in isometric direction: ", dash_direction)

func handle_dash(delta):
	dash_timer -= delta
	if dash_timer <= 0:
		is_dashing = false
		print("[Player] Dash finished")

func setup_collision():
	if collision_shape.shape == null:
		var capsule = CapsuleShape2D.new()
		capsule.radius = 16
		capsule.height = 32
		collision_shape.shape = capsule

func _draw():
	# ROADMAP: Debug visual adaptado para perspectiva isométrica
	var player_color = Color.CYAN
	if is_dashing:
		player_color = Color.YELLOW

	# Desenhar player como losango para perspectiva isométrica
	var diamond_points = PackedVector2Array([
		Vector2(0, -20),  # Top
		Vector2(16, 0),   # Right
		Vector2(0, 20),   # Bottom
		Vector2(-16, 0)   # Left
	])

	draw_colored_polygon(diamond_points, player_color)

	# Desenhar direção do movimento para debug
	if velocity.length() > 10:
		draw_line(Vector2.ZERO, velocity.normalized() * 30, Color.WHITE, 3)