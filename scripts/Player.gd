extends CharacterBody2D

# Movement settings
@export var speed: float = 300.0

# Combat settings
@export var attack_damage: int = 25
@export var attack_range: float = 80.0

# State
var is_attacking: bool = false

# Components
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var player_sprite: Sprite2D = $PlayerSprite

func _ready():
	print("[Player] Egyptian warrior ready!")

	# Setup collision shape
	if collision_shape.shape == null:
		var capsule = CapsuleShape2D.new()
		capsule.radius = 16
		capsule.height = 32
		collision_shape.shape = capsule

	# Setup sprite with programmatic texture (since _draw isn't working)
	setup_sprite()

func _physics_process(_delta):
	handle_input()
	handle_movement()
	move_and_slide()

func handle_input():
	# Attack input
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

func handle_movement():
	# Get input vector
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Apply movement
	if input_vector != Vector2.ZERO:
		velocity = input_vector * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed * 8.0 * get_physics_process_delta_time())

func start_attack():
	if is_attacking:
		return

	is_attacking = true

	# Get attack direction towards mouse
	var mouse_pos = get_global_mouse_position()
	var attack_direction = (mouse_pos - global_position).normalized()

	print("[Player] Attacking towards ", attack_direction)

	# Simple attack duration
	var attack_timer = get_tree().create_timer(0.3)
	attack_timer.timeout.connect(_on_attack_finished)

	# Update sprite color for attack
	update_sprite_color()

	# Perform attack hit detection
	perform_attack_hit(attack_direction)

func perform_attack_hit(direction: Vector2):
	# Attack hit detection for enemies
	# Find all enemies in attack range
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("take_damage"):
			var distance = global_position.distance_to(enemy.global_position)
			if distance <= attack_range:
				# Check if enemy is in attack direction (cone attack)
				var to_enemy = (enemy.global_position - global_position).normalized()
				var dot_product = direction.dot(to_enemy)
				if dot_product > 0.5:  # 60 degree cone
					enemy.take_damage(attack_damage)
					print("[Player] Hit enemy for ", attack_damage, " damage!")

func _on_attack_finished():
	is_attacking = false
	update_sprite_color()  # Update sprite color when attack ends
	print("[Player] Attack finished")

func setup_sprite():
	# Create a bright, visible circle texture
	var img = Image.create(64, 64, false, Image.FORMAT_RGB8)
	img.fill(Color.TRANSPARENT)

	# Draw a bright circle with border
	for x in range(64):
		for y in range(64):
			var dist = Vector2(x - 32, y - 32).length()
			if dist <= 18:
				if dist <= 16:
					img.set_pixel(x, y, Color.YELLOW)  # Bright yellow center
				else:
					img.set_pixel(x, y, Color.WHITE)   # White border

	var texture = ImageTexture.new()
	texture.set_image(img)
	player_sprite.texture = texture

	# Make sprite bigger and more visible
	player_sprite.scale = Vector2(1.5, 1.5)

	print("[Player] Bright sprite texture created and assigned")

func update_sprite_color():
	if is_attacking:
		player_sprite.modulate = Color.RED
	else:
		player_sprite.modulate = Color.WHITE

func _draw():
	# Player visual
	var player_color = Color.GOLD
	if is_attacking:
		player_color = Color.RED  # Red when attacking

	draw_circle(Vector2.ZERO, 16, player_color)

	# Draw attack range when attacking
	if is_attacking:
		var mouse_pos = get_global_mouse_position()
		var attack_direction = (mouse_pos - global_position).normalized()
		var attack_end = attack_direction * attack_range

		# Draw attack line
		draw_line(Vector2.ZERO, attack_end, Color.WHITE, 4)
		# Draw attack area
		draw_circle(attack_end, 20, Color.RED, false, 3)