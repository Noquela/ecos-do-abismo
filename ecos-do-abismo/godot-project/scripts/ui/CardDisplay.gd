# UI Component for displaying cards with minimalist design and tooltip
extends Control

@onready var card_art = $CardArt
@onready var name_label = $NameLabel
@onready var type_icon = $TypeIcon
@onready var background = $Background
@onready var card_frame = $CardFrame

var card_data: Dictionary
var tooltip_instance = null

signal card_clicked(card_data)

func display_card(card: Dictionary):
	"""Display a card with all its visual elements"""
	card_data = card

	# Wait for _ready if nodes aren't available yet
	if not name_label:
		await ready

	# Set basic text - minimalist approach
	if name_label:
		name_label.text = card.get("name", "Unknown Card")

	# Set type icon
	if type_icon:
		type_icon.text = get_type_icon(card.get("type", ""))

	# Load artwork if available
	var artwork_path = card.get("artwork", "")
	if artwork_path != "":
		print("Trying to load artwork: ", artwork_path)
		if ResourceLoader.exists(artwork_path):
			var texture = load(artwork_path)
			if texture and card_art:
				card_art.texture = texture
				card_art.visible = true
				print("✅ Artwork loaded successfully: ", artwork_path)
			else:
				print("❌ Failed to load texture: ", artwork_path)
				if card_art:
					card_art.visible = false
		else:
			print("❌ Artwork file not found: ", artwork_path)
			if card_art:
				card_art.visible = false
	else:
		print("⚠️ No artwork path specified")
		if card_art:
			card_art.visible = false

	# Update visual style based on rarity
	update_rarity_style(card.get("rarity", 0))

func get_type_icon(type: String) -> String:
	"""Get icon for card type"""
	match type:
		"attack": return "⚔️"
		"defense": return "🛡️"
		"heal": return "💚"
		"skill": return "✨"
		"power": return "💫"
		"energy": return "⚡"
		"combo": return "🔄"
		_: return "❓"

func get_type_display_name(type: String) -> String:
	"""Convert card type to display name"""
	match type:
		"attack": return "Ataque"
		"defense": return "Defesa"
		"heal": return "Cura"
		"skill": return "Habilidade"
		"power": return "Poder"
		"energy": return "Energia"
		"combo": return "Combo"
		_: return type.capitalize()

func format_description(base_description: String, card: Dictionary) -> String:
	"""Format description with card values"""
	var formatted = base_description

	# Replace common placeholders
	if card.has("damage"):
		formatted = formatted.replace("{damage}", str(card.damage))
	if card.has("shield"):
		formatted = formatted.replace("{shield}", str(card.shield))
	if card.has("heal"):
		formatted = formatted.replace("{heal}", str(card.heal))
	if card.has("energy"):
		formatted = formatted.replace("{energy}", str(card.energy))

	return formatted

func update_rarity_style(rarity: int):
	"""Update visual style based on card rarity with eldritch frames"""
	if not background or not name_label:
		return

	# Load appropriate frame based on rarity
	var frame_path = ""
	var glow_color = Color.WHITE
	var name_color = Color.WHITE

	match rarity:
		0: # Common - Dark stone with purple runes
			frame_path = "res://assets/generated/ui/frame_common.png"
			glow_color = Color(0.6, 0.4, 0.8, 0.8)  # Soft purple
			name_color = Color(0.9, 0.9, 0.9, 1)
		1: # Uncommon - Void energy crackling
			frame_path = "res://assets/generated/ui/frame_uncommon.png"
			glow_color = Color(0.3, 0.7, 1.0, 0.9)  # Eldritch blue
			name_color = Color(0.4, 0.8, 1.0, 1)
		2: # Rare - Cosmic horror legendary
			frame_path = "res://assets/generated/ui/frame_rare.png"
			glow_color = Color(1.0, 0.8, 0.2, 1.0)  # Golden void energy
			name_color = Color(1.0, 0.9, 0.3, 1)
		_:
			frame_path = "res://assets/generated/ui/frame_common.png"
			glow_color = Color.GRAY
			name_color = Color.GRAY

	# Apply frame if we have the card_frame node
	if card_frame and ResourceLoader.exists(frame_path):
		var frame_texture = load(frame_path)
		if frame_texture:
			card_frame.texture = frame_texture
			card_frame.visible = true
			# Add subtle glow effect
			card_frame.modulate = glow_color

	# Update name color with eldritch styling
	name_label.modulate = name_color

	# Add shadow effect for better readability
	if name_label.has_theme_color_override("font_shadow_color"):
		name_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		name_label.add_theme_constant_override("shadow_offset_x", 2)
		name_label.add_theme_constant_override("shadow_offset_y", 2)

func set_interactable(enabled: bool):
	"""Enable/disable card interaction"""
	mouse_filter = Control.MOUSE_FILTER_PASS if enabled else Control.MOUSE_FILTER_IGNORE

func _on_mouse_entered():
	"""Show tooltip on hover with smooth animation"""
	_show_tooltip()
	_animate_hover_in()

func _on_mouse_exited():
	"""Hide tooltip and reset visual feedback with smooth animation"""
	_hide_tooltip()
	_animate_hover_out()

func _animate_hover_in():
	"""Eldritch hover animation with void energy"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	# Scale and glow effect
	tween.parallel().tween_property(self, "scale", Vector2(1.08, 1.08), 0.2)
	tween.parallel().tween_property(self, "modulate", Color(1.2, 1.1, 1.3, 1.0), 0.2)

	# Add subtle rotation for eldritch feel
	tween.parallel().tween_property(self, "rotation", deg_to_rad(1), 0.2)

	# Frame glow intensification
	if card_frame and card_frame.visible:
		var current_color = card_frame.modulate
		var intensified = Color(current_color.r * 1.3, current_color.g * 1.3, current_color.b * 1.3, current_color.a)
		tween.parallel().tween_property(card_frame, "modulate", intensified, 0.2)

func _animate_hover_out():
	"""Return to normal with eldritch fade"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUART)

	# Return to normal scale and color
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.15)
	tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.15)
	tween.parallel().tween_property(self, "rotation", 0.0, 0.15)

	# Reset frame glow
	if card_frame and card_frame.visible:
		var rarity = card_data.get("rarity", 0)
		var original_color
		match rarity:
			0: original_color = Color(0.6, 0.4, 0.8, 0.8)
			1: original_color = Color(0.3, 0.7, 1.0, 0.9)
			2: original_color = Color(1.0, 0.8, 0.2, 1.0)
			_: original_color = Color.GRAY
		tween.parallel().tween_property(card_frame, "modulate", original_color, 0.15)

func _show_tooltip():
	"""Create and show tooltip with card stats"""
	if tooltip_instance:
		return  # Already showing

	# Create tooltip (for now, simple popup)
	tooltip_instance = create_tooltip_popup()
	get_viewport().add_child(tooltip_instance)

	# Position tooltip near mouse
	var mouse_pos = get_global_mouse_position()
	tooltip_instance.global_position = mouse_pos + Vector2(20, -50)

func _hide_tooltip():
	"""Remove tooltip"""
	if tooltip_instance:
		tooltip_instance.queue_free()
		tooltip_instance = null

func create_tooltip_popup() -> Control:
	"""Create an eldritch tooltip popup with cosmic horror styling"""
	var popup = Panel.new()
	popup.custom_minimum_size = Vector2(220, 140)

	# Eldritch styling - void energy background
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.05, 0.05, 0.15, 0.97)  # Deep void color

	# Rarity-based border color
	var rarity = card_data.get("rarity", 0)
	match rarity:
		0: style_box.border_color = Color(0.6, 0.4, 0.8, 0.9)  # Purple eldritch
		1: style_box.border_color = Color(0.3, 0.7, 1.0, 0.9)  # Void blue
		2: style_box.border_color = Color(1.0, 0.8, 0.2, 1.0)  # Cosmic gold
		_: style_box.border_color = Color(0.4, 0.4, 0.4, 0.8)

	style_box.border_width_left = 3
	style_box.border_width_right = 3
	style_box.border_width_top = 3
	style_box.border_width_bottom = 3
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8

	# Add subtle shadow effect
	style_box.shadow_color = Color(0.2, 0.1, 0.3, 0.6)
	style_box.shadow_size = 4
	style_box.shadow_offset = Vector2(2, 2)

	popup.add_theme_stylebox_override("panel", style_box)

	# Add content
	var vbox = VBoxContainer.new()
	popup.add_child(vbox)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 4)

	# Title
	var title = Label.new()
	title.text = card_data.get("name", "Unknown Card")
	title.add_theme_color_override("font_color", Color.WHITE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Type and cost
	var type_cost = Label.new()
	type_cost.text = "%s %s • Custo: %d" % [get_type_icon(card_data.get("type", "")), get_type_display_name(card_data.get("type", "")), card_data.get("cost", 0)]
	type_cost.add_theme_color_override("font_color", Color.YELLOW)
	type_cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(type_cost)

	# Effects
	var effects = Label.new()
	var effect_text = ""
	if card_data.has("damage"):
		effect_text += "Dano: %d\n" % card_data.damage
	if card_data.has("heal"):
		effect_text += "Cura: %d\n" % card_data.heal
	if card_data.has("shield"):
		effect_text += "Escudo: %d\n" % card_data.shield
	if card_data.has("energy"):
		effect_text += "Energia: +%d\n" % card_data.energy

	effects.text = effect_text.strip_edges()
	effects.add_theme_color_override("font_color", Color.CYAN)
	effects.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(effects)

	# Description
	var desc = Label.new()
	desc.text = format_description(card_data.get("description", ""), card_data)
	desc.add_theme_color_override("font_color", Color.LIGHT_GRAY)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(desc)

	return popup

func _ready():
	# Connect mouse signals for hover effects
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _gui_input(event):
	"""Handle card click with juice animation"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_animate_click()
		card_clicked.emit(card_data)

func _animate_click():
	"""Eldritch click animation with void energy pulse"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)

	# Quick shrink with rotation
	tween.parallel().tween_property(self, "scale", Vector2(0.9, 0.9), 0.08)
	tween.parallel().tween_property(self, "rotation", deg_to_rad(-3), 0.08)

	# Void energy flash
	tween.parallel().tween_property(self, "modulate", Color(1.5, 1.3, 1.8, 1.0), 0.08)

	# Bounce back with opposite rotation
	tween.parallel().tween_property(self, "scale", Vector2(1.15, 1.15), 0.18)
	tween.parallel().tween_property(self, "rotation", deg_to_rad(2), 0.18)

	# Return to normal
	tween.parallel().tween_property(self, "scale", Vector2.ONE, 0.12)
	tween.parallel().tween_property(self, "rotation", 0.0, 0.12)
	tween.parallel().tween_property(self, "modulate", Color.WHITE, 0.12)