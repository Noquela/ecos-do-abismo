# Eldritch themed button with cosmic horror styling and animations
extends Button
class_name EldritchButton

enum ButtonType {
	MAIN_ACTION,    # Primary actions like "Enter Abyss"
	SECONDARY,      # Secondary actions
	DANGER,         # Dangerous actions like "End Run"
	MYSTICAL        # Mystical actions like upgrades
}

@export var button_type: ButtonType = ButtonType.MAIN_ACTION
@export var has_particle_effect: bool = false
@export var hover_sound: AudioStream

var original_scale: Vector2

func _ready():
	original_scale = scale
	apply_eldritch_styling()
	setup_animations()

func apply_eldritch_styling():
	"""Apply cosmic horror button styling"""

	# Normal state
	var normal_style = StyleBoxFlat.new()
	var hover_style = StyleBoxFlat.new()
	var pressed_style = StyleBoxFlat.new()
	var disabled_style = StyleBoxFlat.new()

	match button_type:
		ButtonType.MAIN_ACTION:
			# Void energy primary button
			normal_style.bg_color = Color(0.15, 0.1, 0.25, 0.95)
			normal_style.border_color = Color(0.6, 0.4, 0.9, 0.9)
			hover_style.bg_color = Color(0.25, 0.15, 0.35, 0.98)
			hover_style.border_color = Color(0.8, 0.6, 1.0, 1.0)
			pressed_style.bg_color = Color(0.1, 0.05, 0.2, 0.9)
			pressed_style.border_color = Color(0.4, 0.2, 0.6, 0.8)

		ButtonType.SECONDARY:
			# Subtle cosmic button
			normal_style.bg_color = Color(0.1, 0.08, 0.15, 0.85)
			normal_style.border_color = Color(0.5, 0.4, 0.7, 0.7)
			hover_style.bg_color = Color(0.18, 0.12, 0.22, 0.9)
			hover_style.border_color = Color(0.7, 0.5, 0.8, 0.8)
			pressed_style.bg_color = Color(0.08, 0.06, 0.12, 0.8)
			pressed_style.border_color = Color(0.3, 0.2, 0.4, 0.6)

		ButtonType.DANGER:
			# Blood red eldritch energy
			normal_style.bg_color = Color(0.2, 0.05, 0.05, 0.9)
			normal_style.border_color = Color(0.8, 0.2, 0.2, 0.9)
			hover_style.bg_color = Color(0.3, 0.08, 0.08, 0.95)
			hover_style.border_color = Color(1.0, 0.3, 0.3, 1.0)
			pressed_style.bg_color = Color(0.15, 0.03, 0.03, 0.85)
			pressed_style.border_color = Color(0.6, 0.1, 0.1, 0.8)

		ButtonType.MYSTICAL:
			# Golden cosmic energy
			normal_style.bg_color = Color(0.18, 0.15, 0.05, 0.9)
			normal_style.border_color = Color(0.9, 0.7, 0.3, 0.85)
			hover_style.bg_color = Color(0.25, 0.2, 0.08, 0.95)
			hover_style.border_color = Color(1.0, 0.8, 0.4, 1.0)
			pressed_style.bg_color = Color(0.12, 0.1, 0.03, 0.8)
			pressed_style.border_color = Color(0.7, 0.5, 0.2, 0.7)

	# Apply common styling
	for style in [normal_style, hover_style, pressed_style]:
		style.border_width_left = 3
		style.border_width_right = 3
		style.border_width_top = 3
		style.border_width_bottom = 3
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8

	# Disabled state
	disabled_style.bg_color = Color(0.05, 0.05, 0.05, 0.6)
	disabled_style.border_color = Color(0.2, 0.2, 0.2, 0.5)
	disabled_style.border_width_left = 2
	disabled_style.border_width_right = 2
	disabled_style.border_width_top = 2
	disabled_style.border_width_bottom = 2
	disabled_style.corner_radius_top_left = 8
	disabled_style.corner_radius_top_right = 8
	disabled_style.corner_radius_bottom_left = 8
	disabled_style.corner_radius_bottom_right = 8

	# Apply styles
	add_theme_stylebox_override("normal", normal_style)
	add_theme_stylebox_override("hover", hover_style)
	add_theme_stylebox_override("pressed", pressed_style)
	add_theme_stylebox_override("disabled", disabled_style)

	# Text styling
	add_theme_color_override("font_color", Color(0.95, 0.95, 1.0, 1.0))
	add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	add_theme_color_override("font_pressed_color", Color(0.85, 0.85, 0.95, 1.0))
	add_theme_color_override("font_disabled_color", Color(0.4, 0.4, 0.4, 0.7))

	# Add shadow to text for readability
	add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	add_theme_constant_override("shadow_offset_x", 2)
	add_theme_constant_override("shadow_offset_y", 2)

func setup_animations():
	"""Setup hover and press animations"""
	mouse_entered.connect(_on_hover_start)
	mouse_exited.connect(_on_hover_end)
	button_down.connect(_on_press_start)
	button_up.connect(_on_press_end)

func _on_hover_start():
	"""Eldritch hover animation"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	# Scale up with subtle rotation
	tween.parallel().tween_property(self, "scale", original_scale * 1.05, 0.2)
	tween.parallel().tween_property(self, "rotation", deg_to_rad(1), 0.2)

	# Glow effect
	tween.parallel().tween_property(self, "modulate", Color(1.15, 1.1, 1.25, 1.0), 0.2)

	# Play hover sound if available
	if hover_sound:
		# TODO: Add audio player when sound system is implemented
		pass

func _on_hover_end():
	"""Return to normal state"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)

	tween.parallel().tween_property(self, "scale", original_scale, 0.15)
	tween.parallel().tween_property(self, "rotation", 0.0, 0.15)
	tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.15)

func _on_press_start():
	"""Void energy press animation"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUINT)

	# Quick shrink with flash
	tween.parallel().tween_property(self, "scale", original_scale * 0.95, 0.08)
	tween.parallel().tween_property(self, "modulate", Color(1.3, 1.2, 1.4, 1.0), 0.08)

func _on_press_end():
	"""Bounce back from press"""
	if not is_hovered():
		# Return to normal if not hovering
		_on_hover_end()
	else:
		# Return to hover state
		_on_hover_start()

func set_button_type(new_type: ButtonType):
	"""Change button type and reapply styling"""
	button_type = new_type
	apply_eldritch_styling()

func pulse_effect():
	"""Special pulse effect for important actions"""
	var tween = create_tween()
	tween.set_loops(3)

	tween.tween_property(self, "modulate", Color(1.4, 1.3, 1.5, 1.0), 0.3)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)