# Sistema de tema unificado para UI eldritch/lovecraftiana
extends Node

# Paleta de cores temática
const COLORS = {
	"void_deep": Color(0.02, 0.02, 0.08, 0.98),      # Fundo void profundo
	"void_medium": Color(0.05, 0.05, 0.15, 0.95),    # Fundo void médio
	"void_light": Color(0.1, 0.08, 0.18, 0.9),       # Fundo void claro

	"eldritch_purple": Color(0.6, 0.4, 0.8, 0.9),    # Púrpura eldritch
	"eldritch_blue": Color(0.3, 0.7, 1.0, 0.9),      # Azul void
	"eldritch_gold": Color(1.0, 0.8, 0.2, 1.0),      # Dourado cósmico

	"blood_energy": Color(0.8, 0.3, 0.4, 1.0),       # Energia sangrenta
	"corruption_dark": Color(0.2, 0.1, 0.3, 0.8),    # Corrupção escura

	"text_primary": Color(0.95, 0.95, 1.0, 1.0),     # Texto primário
	"text_secondary": Color(0.8, 0.8, 0.9, 0.9),     # Texto secundário
	"text_disabled": Color(0.4, 0.4, 0.4, 0.7),      # Texto desabilitado
	"text_shadow": Color(0.0, 0.0, 0.0, 0.8),        # Sombra do texto
}

# Fonts (usando fontes built-in do Godot com styling)
const FONT_SIZES = {
	"title_large": 32,
	"title_medium": 24,
	"title_small": 18,
	"body": 14,
	"small": 12
}

# Aplicar tema a um Label
static func apply_label_theme(label: Label, style: String = "body"):
	if not label:
		return

	match style:
		"title_large":
			label.add_theme_font_size_override("font_size", FONT_SIZES.title_large)
			label.add_theme_color_override("font_color", COLORS.eldritch_gold)
			_add_text_shadow(label, Vector2(3, 3))

		"title_medium":
			label.add_theme_font_size_override("font_size", FONT_SIZES.title_medium)
			label.add_theme_color_override("font_color", COLORS.eldritch_purple)
			_add_text_shadow(label, Vector2(2, 2))

		"title_small":
			label.add_theme_font_size_override("font_size", FONT_SIZES.title_small)
			label.add_theme_color_override("font_color", COLORS.eldritch_blue)
			_add_text_shadow(label, Vector2(2, 2))

		"body":
			label.add_theme_font_size_override("font_size", FONT_SIZES.body)
			label.add_theme_color_override("font_color", COLORS.text_primary)
			_add_text_shadow(label, Vector2(1, 1))

		"small":
			label.add_theme_font_size_override("font_size", FONT_SIZES.small)
			label.add_theme_color_override("font_color", COLORS.text_secondary)
			_add_text_shadow(label, Vector2(1, 1))

		"danger":
			label.add_theme_font_size_override("font_size", FONT_SIZES.body)
			label.add_theme_color_override("font_color", COLORS.blood_energy)
			_add_text_shadow(label, Vector2(2, 2))

# Aplicar tema a um Panel usando texturas
static func apply_panel_theme(panel: Panel, style: String = "default"):
	if not panel:
		return

	# Try to use generated texture assets
	var panel_texture_path = "res://assets/generated/ui/panel_clean.png"
	if style == "light":
		panel_texture_path = "res://assets/generated/ui/panel_clean.png"

	if ResourceLoader.exists(panel_texture_path):
		# Use handmade texture assets
		var texture_style = StyleBoxTexture.new()
		texture_style.texture = load(panel_texture_path)
		_setup_texture_margins(texture_style)
		panel.add_theme_stylebox_override("panel", texture_style)
	else:
		# Fallback to simple clean styling
		var style_box = StyleBoxFlat.new()

		match style:
			"main":
				style_box.bg_color = Color(0.1, 0.1, 0.15, 0.8)
				style_box.border_color = Color(0.3, 0.3, 0.4, 0.6)
			"light":
				style_box.bg_color = Color(0.15, 0.15, 0.2, 0.7)
				style_box.border_color = Color(0.4, 0.4, 0.5, 0.5)
			_: # default
				style_box.bg_color = Color(0.05, 0.05, 0.1, 0.9)
				style_box.border_color = Color(0.2, 0.2, 0.3, 0.7)

		# Simple clean borders
		style_box.border_width_left = 1
		style_box.border_width_right = 1
		style_box.border_width_top = 1
		style_box.border_width_bottom = 1
		style_box.corner_radius_top_left = 4
		style_box.corner_radius_top_right = 4
		style_box.corner_radius_bottom_left = 4
		style_box.corner_radius_bottom_right = 4

		panel.add_theme_stylebox_override("panel", style_box)

# Aplicar tema a um Button usando texturas
static func apply_button_theme(button: Button, style: String = "primary"):
	if not button:
		return

	# Try to use generated texture assets first
	var normal_texture_path = "res://assets/generated/ui/btn_clean_normal.png"
	var hover_texture_path = "res://assets/generated/ui/btn_clean_hover.png"

	if ResourceLoader.exists(normal_texture_path) and ResourceLoader.exists(hover_texture_path):
		# Use handmade texture assets
		var normal_style = StyleBoxTexture.new()
		var hover_style = StyleBoxTexture.new()
		var pressed_style = StyleBoxTexture.new()

		normal_style.texture = load(normal_texture_path)
		hover_style.texture = load(hover_texture_path)
		pressed_style.texture = load(normal_texture_path)

		# Set texture margins for proper scaling
		_setup_texture_margins(normal_style)
		_setup_texture_margins(hover_style)
		_setup_texture_margins(pressed_style)

		button.add_theme_stylebox_override("normal", normal_style)
		button.add_theme_stylebox_override("hover", hover_style)
		button.add_theme_stylebox_override("pressed", pressed_style)
	else:
		# Fallback to simple clean styling
		var normal_style = StyleBoxFlat.new()
		var hover_style = StyleBoxFlat.new()
		var pressed_style = StyleBoxFlat.new()

		match style:
			"primary":
				normal_style.bg_color = Color(0.2, 0.2, 0.3, 0.8)
				hover_style.bg_color = Color(0.3, 0.3, 0.4, 0.9)
				pressed_style.bg_color = Color(0.1, 0.1, 0.2, 0.9)
			"danger":
				normal_style.bg_color = Color(0.4, 0.2, 0.2, 0.8)
				hover_style.bg_color = Color(0.5, 0.3, 0.3, 0.9)
				pressed_style.bg_color = Color(0.3, 0.1, 0.1, 0.9)
			_: # secondary
				normal_style.bg_color = Color(0.15, 0.15, 0.25, 0.8)
				hover_style.bg_color = Color(0.25, 0.25, 0.35, 0.9)
				pressed_style.bg_color = Color(0.1, 0.1, 0.15, 0.9)

		# Apply simple styling to all states
		for style_box in [normal_style, hover_style, pressed_style]:
			style_box.border_width_left = 1
			style_box.border_width_right = 1
			style_box.border_width_top = 1
			style_box.border_width_bottom = 1
			style_box.corner_radius_top_left = 3
			style_box.corner_radius_top_right = 3
			style_box.corner_radius_bottom_left = 3
			style_box.corner_radius_bottom_right = 3
			style_box.border_color = Color(0.4, 0.4, 0.5, 0.6)

		# Apply styles
		button.add_theme_stylebox_override("normal", normal_style)
		button.add_theme_stylebox_override("hover", hover_style)
		button.add_theme_stylebox_override("pressed", pressed_style)

	# Text styling
	button.add_theme_color_override("font_color", COLORS.text_primary)
	button.add_theme_color_override("font_hover_color", COLORS.text_primary)
	button.add_theme_color_override("font_pressed_color", COLORS.text_secondary)

# Aplicar tema a ProgressBar usando texturas quando possível
static func apply_progressbar_theme(progress_bar: ProgressBar, style: String = "default"):
	if not progress_bar:
		return

	# Try to use generated texture assets for background and fill
	var bg_texture_path = "res://assets/generated/ui/bar_bg.png"
	var fill_texture_path = "res://assets/generated/ui/bar_fill.png"

	# Adjust paths based on style
	match style:
		"hp":
			bg_texture_path = "res://assets/generated/ui/bar_hp_bg.png"
			fill_texture_path = "res://assets/generated/ui/bar_hp_fill.png"
		"energy":
			bg_texture_path = "res://assets/generated/ui/bar_energy_bg.png"
			fill_texture_path = "res://assets/generated/ui/bar_energy_fill.png"
		"xp":
			bg_texture_path = "res://assets/generated/ui/bar_xp_bg.png"
			fill_texture_path = "res://assets/generated/ui/bar_xp_fill.png"

	# Check if texture assets exist and use them
	if ResourceLoader.exists(bg_texture_path) and ResourceLoader.exists(fill_texture_path):
		var bg_texture_style = StyleBoxTexture.new()
		var fill_texture_style = StyleBoxTexture.new()

		bg_texture_style.texture = load(bg_texture_path)
		fill_texture_style.texture = load(fill_texture_path)

		# Set margins for proper scaling
		_setup_progress_bar_margins(bg_texture_style)
		_setup_progress_bar_margins(fill_texture_style)

		progress_bar.add_theme_stylebox_override("background", bg_texture_style)
		progress_bar.add_theme_stylebox_override("fill", fill_texture_style)
	else:
		# Fallback to programmatic styling
		var bg_style = StyleBoxFlat.new()
		var fill_style = StyleBoxFlat.new()

		# Background
		bg_style.bg_color = COLORS.void_deep
		bg_style.border_color = COLORS.corruption_dark
		bg_style.border_width_left = 1
		bg_style.border_width_right = 1
		bg_style.border_width_top = 1
		bg_style.border_width_bottom = 1
		bg_style.corner_radius_top_left = 4
		bg_style.corner_radius_top_right = 4
		bg_style.corner_radius_bottom_left = 4
		bg_style.corner_radius_bottom_right = 4

		# Fill style based on type
		match style:
			"hp":
				fill_style.bg_color = COLORS.blood_energy
			"energy":
				fill_style.bg_color = COLORS.eldritch_blue
			"xp":
				fill_style.bg_color = COLORS.eldritch_gold
			_: # default
				fill_style.bg_color = COLORS.eldritch_purple

		fill_style.corner_radius_top_left = 3
		fill_style.corner_radius_top_right = 3
		fill_style.corner_radius_bottom_left = 3
		fill_style.corner_radius_bottom_right = 3

		progress_bar.add_theme_stylebox_override("background", bg_style)
		progress_bar.add_theme_stylebox_override("fill", fill_style)

# Aplicar glow effect a qualquer Control
static func add_glow_effect(control: Control, color: Color = COLORS.eldritch_purple):
	if not control:
		return
	control.modulate = Color(color.r * 1.2, color.g * 1.2, color.b * 1.2, 1.0)

# Animação de pulse para elementos importantes
static func add_pulse_animation(control: Control, duration: float = 2.0):
	if not control:
		return

	var tween = control.create_tween()
	tween.set_loops()

	var original_modulate = control.modulate
	var bright_modulate = Color(original_modulate.r * 1.3, original_modulate.g * 1.2, original_modulate.b * 1.4, original_modulate.a)

	tween.tween_property(control, "modulate", bright_modulate, duration / 2)
	tween.tween_property(control, "modulate", original_modulate, duration / 2)

# Funções auxiliares privadas
static func _add_text_shadow(_control: Control, _offset: Vector2):
	# Remove problematic shadow effects for now
	pass

static func _apply_common_border_style(style_box: StyleBoxFlat):
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8

static func _setup_button_colors(style_box: StyleBoxFlat, bg_color: Color, border_color: Color):
	style_box.bg_color = bg_color
	style_box.border_color = border_color
	_apply_common_border_style(style_box)
	style_box.border_width_left = 3
	style_box.border_width_right = 3
	style_box.border_width_top = 3
	style_box.border_width_bottom = 3

# Setup texture margins for proper scaling
static func _setup_texture_margins(texture_style: StyleBoxTexture):
	texture_style.texture_margin_left = 16
	texture_style.texture_margin_right = 16
	texture_style.texture_margin_top = 16
	texture_style.texture_margin_bottom = 16

# Setup progress bar texture margins
static func _setup_progress_bar_margins(texture_style: StyleBoxTexture):
	texture_style.texture_margin_left = 8
	texture_style.texture_margin_right = 8
	texture_style.texture_margin_top = 4
	texture_style.texture_margin_bottom = 4