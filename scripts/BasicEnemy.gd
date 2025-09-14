extends CharacterBody2D

# Enemy stats
@export var health: int = 50
@export var speed: float = 150.0
@export var attack_damage: int = 15
@export var detection_range: float = 200.0
@export var attack_range: float = 60.0

# State
enum EnemyState { IDLE, CHASE, ATTACK, HURT, DEATH }
var current_state = EnemyState.IDLE
var player: CharacterBody2D
var is_attacking: bool = false

# Components
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var enemy_sprite: Sprite2D = $EnemySprite

func _ready():
	print("[BasicEnemy] Skeleton warrior spawned!")
	player = get_node("../Player") as CharacterBody2D
	setup_sprite()
	setup_collision()

func _physics_process(delta):
	if current_state == EnemyState.DEATH:
		return

	update_state()
	handle_movement(delta)
	move_and_slide()

func update_state():
	if not player:
		return

	var distance_to_player = global_position.distance_to(player.global_position)

	match current_state:
		EnemyState.IDLE:
			if distance_to_player <= detection_range:
				current_state = EnemyState.CHASE

		EnemyState.CHASE:
			if distance_to_player <= attack_range and not is_attacking:
				current_state = EnemyState.ATTACK
				start_attack()
			elif distance_to_player > detection_range * 1.2:
				current_state = EnemyState.IDLE

		EnemyState.ATTACK:
			if not is_attacking:
				current_state = EnemyState.CHASE

func handle_movement(delta):
	match current_state:
		EnemyState.CHASE:
			if player:
				var direction = (player.global_position - global_position).normalized()
				velocity = direction * speed
		EnemyState.IDLE, EnemyState.ATTACK:
			velocity = velocity.move_toward(Vector2.ZERO, speed * 3.0 * delta)

func start_attack():
	if is_attacking:
		return

	is_attacking = true
	current_state = EnemyState.ATTACK

	print("[BasicEnemy] Attacking player!")

	# Attack duration
	var attack_timer = get_tree().create_timer(0.5)
	attack_timer.timeout.connect(_on_attack_finished)

	# Update sprite color during attack
	update_sprite_color()

	# Perform attack hit detection
	if player and global_position.distance_to(player.global_position) <= attack_range:
		print("[BasicEnemy] Hit player for ", attack_damage, " damage!")

func _on_attack_finished():
	is_attacking = false
	update_sprite_color()
	print("[BasicEnemy] Attack finished")

func take_damage(damage: int):
	health -= damage
	print("[BasicEnemy] Took ", damage, " damage. Health: ", health)

	if health <= 0:
		die()
	else:
		current_state = EnemyState.HURT
		update_sprite_color()
		# Brief hurt state
		var hurt_timer = get_tree().create_timer(0.2)
		hurt_timer.timeout.connect(func(): current_state = EnemyState.CHASE)

func die():
	current_state = EnemyState.DEATH
	print("[BasicEnemy] Skeleton defeated!")
	update_sprite_color()

	# Death animation/effect
	var death_timer = get_tree().create_timer(1.0)
	death_timer.timeout.connect(queue_free)

func setup_sprite():
	# Create red enemy sprite
	var img = Image.create(48, 48, false, Image.FORMAT_RGB8)
	img.fill(Color.TRANSPARENT)

	# Draw red circle with darker border
	for x in range(48):
		for y in range(48):
			var dist = Vector2(x - 24, y - 24).length()
			if dist <= 16:
				if dist <= 14:
					img.set_pixel(x, y, Color.RED)
				else:
					img.set_pixel(x, y, Color.DARK_RED)

	var texture = ImageTexture.new()
	texture.set_image(img)
	enemy_sprite.texture = texture
	enemy_sprite.scale = Vector2(1.2, 1.2)

func setup_collision():
	if collision_shape.shape == null:
		var capsule = CapsuleShape2D.new()
		capsule.radius = 14
		capsule.height = 28
		collision_shape.shape = capsule

func update_sprite_color():
	match current_state:
		EnemyState.ATTACK:
			enemy_sprite.modulate = Color.ORANGE
		EnemyState.HURT:
			enemy_sprite.modulate = Color.WHITE
		EnemyState.DEATH:
			enemy_sprite.modulate = Color.GRAY
		_:
			enemy_sprite.modulate = Color.WHITE

func _draw():
	# Enemy visual
	var enemy_color = Color.RED
	match current_state:
		EnemyState.ATTACK:
			enemy_color = Color.ORANGE
		EnemyState.HURT:
			enemy_color = Color.PINK
		EnemyState.DEATH:
			enemy_color = Color.GRAY

	draw_circle(Vector2.ZERO, 14, enemy_color)

	# Draw detection range when chasing
	if current_state == EnemyState.CHASE:
		draw_circle(Vector2.ZERO, detection_range, Color.RED, false, 2)