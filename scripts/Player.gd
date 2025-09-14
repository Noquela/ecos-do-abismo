extends CharacterBody2D

# Player Isométrico - Sprint 1
# Roadmap: Converter input WASD para movimento diagonal isométrico

# Configurações de movimento
@export var speed: float = 300.0
@export var dash_power: float = 1200.0
@export var dash_duration: float = 0.5

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
	# Debug: mostrar quando dash input é detectado
	if Input.is_action_just_pressed("dash"):
		print("[Player] DASH INPUT DETECTED! is_dashing=", is_dashing)
		if not is_dashing:
			start_dash()
		else:
			print("[Player] Dash ignored - already dashing")

func handle_movement(delta):
	# NÃO MOVER DURANTE DASH - deixa o dash controlar velocity
	if is_dashing:
		return

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
	print("[Player] start_dash() called - is_dashing=", is_dashing)
	if is_dashing:
		print("[Player] Dash blocked - already dashing")
		return

	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var dash_direction: Vector2

	print("[Player] Current input_vector: ", input_vector)
	print("[Player] Current velocity: ", velocity)

	# Se há input atual, usar essa direção
	if input_vector != Vector2.ZERO:
		# Converter input para isométrico
		dash_direction = IsometricUtils.convert_input_to_isometric(input_vector)
		print("[Player] Dash with current input: ", input_vector, " → ", dash_direction)
	else:
		print("[Player] No input detected - checking velocity")
		# Se não há input, usar última direção de movimento ou direção padrão
		if velocity.length() > 10:
			# Usar direção atual do movimento (já está em coordenadas isométricas)
			dash_direction = velocity.normalized()
			print("[Player] Dash using current velocity direction: ", dash_direction)
		else:
			# Direção padrão para frente na vista isométrica
			var default_input = Vector2(0, -1)  # W key direction
			dash_direction = IsometricUtils.convert_input_to_isometric(default_input)
			print("[Player] Dash using default direction: ", dash_direction)

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
	var player_size = 20

	if is_dashing:
		player_color = Color.RED  # VERMELHO BRILHANTE
		player_size = 30  # MAIOR durante dash

	# Desenhar player como losango para perspectiva isométrica
	var diamond_points = PackedVector2Array([
		Vector2(0, -player_size),  # Top
		Vector2(player_size * 0.8, 0),   # Right
		Vector2(0, player_size),   # Bottom
		Vector2(-player_size * 0.8, 0)   # Left
	])

	draw_colored_polygon(diamond_points, player_color)

	# Desenhar direção do movimento para debug
	if velocity.length() > 10:
		var line_color = Color.WHITE
		var line_width = 3
		if is_dashing:
			line_color = Color.YELLOW  # AMARELO BRILHANTE
			line_width = 8  # MUITO GROSSO
		draw_line(Vector2.ZERO, velocity.normalized() * 60, line_color, line_width)

	# Desenhar efeitos do dash - MUITO VISÍVEL
	if is_dashing:
		# Círculo pulsante
		draw_circle(Vector2.ZERO, 35, Color.YELLOW, false, 5)
		draw_circle(Vector2.ZERO, 45, Color.RED, false, 3)
		# Trail atrás do player
		var trail_pos = -velocity.normalized() * 25
		draw_circle(trail_pos, 15, Color.ORANGE, false, 4)