extends Camera2D
class_name CameraController

@export var follow_speed: float = 5.0
@export var follow_offset: Vector2 = Vector2.ZERO
@export var zoom_level: Vector2 = Vector2(2.0, 2.0)

var target: Node2D
var smooth_enabled: bool = true

func _ready():
	zoom = zoom_level
	enabled = true

func _process(delta):
	if target:
		follow_target(delta)

func set_target(new_target: Node2D):
	target = new_target
	if target:
		global_position = target.global_position + follow_offset

func follow_target(delta):
	if not target:
		return

	var target_position = target.global_position + follow_offset

	if smooth_enabled:
		global_position = global_position.lerp(target_position, follow_speed * delta)
	else:
		global_position = target_position

func shake_camera(intensity: float, duration: float):
	var tween = create_tween()
	var original_offset = offset

	for i in range(int(duration * 60)):  # 60 FPS assumption
		var shake_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(self, "offset", original_offset + shake_offset, 0.016)

	tween.tween_property(self, "offset", original_offset, 0.1)