# Eldritch themed panel for consistent UI styling across the game
extends Panel
class_name EldritchPanel

enum PanelType {
	DARK_VOID,      # Deep dark with purple border
	COMBAT_HUD,     # Combat interface styling
	STATUS_INFO,    # Player stats and info
	TOOLTIP,        # Card tooltips and popups
	BUTTON_BASE     # Button backgrounds
}

@export var panel_type: PanelType = PanelType.DARK_VOID
@export var has_glow_effect: bool = false
@export var animated_border: bool = false

func _ready():
	apply_eldritch_style()
	if animated_border:
		start_border_animation()

func apply_eldritch_style():
	"""Apply cosmic horror styling based on panel type"""
	var style_box = StyleBoxFlat.new()

	match panel_type:
		PanelType.DARK_VOID:
			# Deep void background with eldritch purple border
			style_box.bg_color = Color(0.05, 0.05, 0.15, 0.95)
			style_box.border_color = Color(0.6, 0.4, 0.8, 0.9)
			style_box.border_width_left = 2
			style_box.border_width_right = 2
			style_box.border_width_top = 2
			style_box.border_width_bottom = 2
			style_box.corner_radius_top_left = 8
			style_box.corner_radius_top_right = 8
			style_box.corner_radius_bottom_left = 8
			style_box.corner_radius_bottom_right = 8

		PanelType.COMBAT_HUD:
			# Combat interface - more visible with energy crackling
			style_box.bg_color = Color(0.1, 0.05, 0.2, 0.9)
			style_box.border_color = Color(0.8, 0.3, 0.4, 1.0)  # Blood red energy
			style_box.border_width_left = 3
			style_box.border_width_right = 3
			style_box.border_width_top = 3
			style_box.border_width_bottom = 3
			style_box.corner_radius_top_left = 6
			style_box.corner_radius_top_right = 6
			style_box.corner_radius_bottom_left = 6
			style_box.corner_radius_bottom_right = 6

		PanelType.STATUS_INFO:
			# Player status - golden cosmic energy
			style_box.bg_color = Color(0.08, 0.08, 0.12, 0.92)
			style_box.border_color = Color(0.9, 0.7, 0.3, 0.85)  # Golden void
			style_box.border_width_left = 2
			style_box.border_width_right = 2
			style_box.border_width_top = 2
			style_box.border_width_bottom = 2
			style_box.corner_radius_top_left = 10
			style_box.corner_radius_top_right = 10
			style_box.corner_radius_bottom_left = 10
			style_box.corner_radius_bottom_right = 10

		PanelType.TOOLTIP:
			# Tooltip styling with shadow
			style_box.bg_color = Color(0.02, 0.02, 0.08, 0.98)
			style_box.border_color = Color(0.4, 0.7, 1.0, 0.9)  # Void blue
			style_box.border_width_left = 3
			style_box.border_width_right = 3
			style_box.border_width_top = 3
			style_box.border_width_bottom = 3
			style_box.corner_radius_top_left = 8
			style_box.corner_radius_top_right = 8
			style_box.corner_radius_bottom_left = 8
			style_box.corner_radius_bottom_right = 8
			style_box.shadow_color = Color(0.2, 0.1, 0.4, 0.7)
			style_box.shadow_size = 6
			style_box.shadow_offset = Vector2(3, 3)

		PanelType.BUTTON_BASE:
			# Button background
			style_box.bg_color = Color(0.12, 0.08, 0.18, 0.9)
			style_box.border_color = Color(0.7, 0.5, 0.9, 0.8)
			style_box.border_width_left = 2
			style_box.border_width_right = 2
			style_box.border_width_top = 2
			style_box.border_width_bottom = 2
			style_box.corner_radius_top_left = 6
			style_box.corner_radius_top_right = 6
			style_box.corner_radius_bottom_left = 6
			style_box.corner_radius_bottom_right = 6

	add_theme_stylebox_override("panel", style_box)

	if has_glow_effect:
		add_glow_effect()

func add_glow_effect():
	"""Add subtle glow effect to the panel"""
	modulate = Color(1.1, 1.05, 1.2, 1.0)

func start_border_animation():
	"""Animated border pulsing effect"""
	var tween = create_tween()
	tween.set_loops()

	# Pulse the border intensity
	var original_modulate = modulate
	var bright_modulate = Color(original_modulate.r * 1.3, original_modulate.g * 1.2, original_modulate.b * 1.4, original_modulate.a)

	tween.tween_property(self, "modulate", bright_modulate, 1.5)
	tween.tween_property(self, "modulate", original_modulate, 1.5)

func set_panel_type(new_type: PanelType):
	"""Change panel type and reapply styling"""
	panel_type = new_type
	apply_eldritch_style()