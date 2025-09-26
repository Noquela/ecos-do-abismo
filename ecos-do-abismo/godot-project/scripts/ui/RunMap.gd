# Sprint 9 - Interface do Mapa de Run
extends Control

# UI Components (original paths)
@onready var floor_info = $Header/FloorInfo
@onready var hp_label = $Header/PlayerStats/HPLabel
@onready var gold_label = $Header/PlayerStats/GoldLabel
@onready var tree_map = $MapContainer/MapGrid
@onready var node_info = $BottomPanel/BottomContainer/NodeInfo
@onready var back_btn = $BottomPanel/BottomContainer/ButtonsContainer/BackButton
@onready var next_btn = $BottomPanel/BottomContainer/ButtonsContainer/NextButton

# Referência ao RunManager
var run_manager: Node

func _ready():
	print("🗺️ RunMap carregado - CINEMATOGRAPHIC OVERHAUL")

	# Apply RICH eldritch map theme first
	_apply_run_map_theme()

	# Obter RunManager
	run_manager = get_node("/root/RunManager")
	if not run_manager:
		print("❌ RunManager não encontrado!")
		return

	# Conectar botões
	back_btn.pressed.connect(_on_back_pressed)
	# next_btn não é mais usado - escolhas são feitas diretamente no mapa

	# Skip TreeMap signal connection - using GridContainer instead
	# tree_map.node_selected.connect(_on_tree_node_selected)

	# Conectar sinais do RunManager
	run_manager.run_started.connect(_on_run_started)
	run_manager.node_completed.connect(_on_node_completed)

	_update_ui()

func _on_run_started():
	"""Callback quando run inicia"""
	print("🚀 Run iniciada, atualizando mapa")
	_update_ui()

func _on_node_completed(node_type: String):
	"""Callback quando node é completado"""
	print("✅ Node completado: %s" % node_type)
	_update_ui()

func _update_ui():
	"""Atualizar interface do mapa"""
	if not run_manager or not run_manager.current_run_active:
		_show_no_run_state()
		return

	var progress = run_manager.get_run_progress()

	# Atualizar header com assets quando disponíveis
	floor_info.text = "Andar %d de %d - Layer %d/%d" % [progress.floor, progress.max_floors, progress.layer + 1, progress.layers_per_floor]
	hp_label.text = "HP: %d/%d" % [progress.hp, progress.max_hp]
	gold_label.text = "%d moedas" % progress.gold

	# Apply theme to UI elements
	_apply_run_map_theme()

	# Atualizar mapa com contexto futuro
	_update_map_display()

	# Atualizar informações
	var choices = run_manager.get_current_layer_choices()
	if choices.size() > 1:
		node_info.text = "Escolha sua próxima jornada (%d opções) - Layer %d/%d" % [choices.size(), progress.layer + 1, progress.layers_per_floor]
	elif choices.size() == 1:
		var node_name = run_manager.get_node_type_name(choices[0])
		node_info.text = "Próximo: %s (Layer %d/%d)" % [node_name, progress.layer + 1, progress.layers_per_floor]
	else:
		node_info.text = "Nenhuma opção disponível"

	# Botão next desabilitado - agora escolhe diretamente nos botões do mapa
	next_btn.disabled = true
	next_btn.visible = false

	# Visual feedback do HP
	var hp_percent = float(progress.hp) / float(progress.max_hp)
	if hp_percent <= 0.3:
		hp_label.modulate = Color.RED
	elif hp_percent <= 0.6:
		hp_label.modulate = Color.ORANGE
	else:
		hp_label.modulate = Color.WHITE

func _show_no_run_state():
	"""Mostrar estado quando não há run ativa"""
	floor_info.text = "Nenhuma run ativa"
	hp_label.text = "HP: --/--"
	gold_label.text = "-- moedas"
	node_info.text = "Inicie uma nova run no Hub"
	next_btn.disabled = true

func _apply_run_map_theme():
	"""Apply ADVANCED visual effects theme to RunMap"""

	# ADVANCED back button with portal effect
	if back_btn:
		var normal_style = StyleBoxFlat.new()
		var hover_style = StyleBoxFlat.new()
		var pressed_style = StyleBoxFlat.new()

		# DANGEROUS portal colors - red/dark
		normal_style.bg_color = Color(0.3, 0.1, 0.15, 0.95)
		hover_style.bg_color = Color(0.45, 0.15, 0.2, 0.98)
		pressed_style.bg_color = Color(0.2, 0.05, 0.1, 0.9)

		# THICK borders with glow
		for style in [normal_style, hover_style, pressed_style]:
			style.border_width_left = 4
			style.border_width_right = 4
			style.border_width_top = 4
			style.border_width_bottom = 4
			style.corner_radius_top_left = 12
			style.corner_radius_top_right = 12
			style.corner_radius_bottom_left = 12
			style.corner_radius_bottom_right = 12

		# Different border colors for each state
		normal_style.border_color = Color(0.7, 0.3, 0.4, 0.9)
		hover_style.border_color = Color(0.9, 0.4, 0.5, 1.0)
		pressed_style.border_color = Color(0.5, 0.2, 0.3, 0.7)

		# SHADOW effects
		normal_style.shadow_color = Color(0.4, 0.1, 0.2, 0.8)
		normal_style.shadow_size = 10
		normal_style.shadow_offset = Vector2(5, 5)

		hover_style.shadow_color = Color(0.6, 0.2, 0.3, 0.9)
		hover_style.shadow_size = 14
		hover_style.shadow_offset = Vector2(7, 7)

		back_btn.add_theme_stylebox_override("normal", normal_style)
		back_btn.add_theme_stylebox_override("hover", hover_style)
		back_btn.add_theme_stylebox_override("pressed", pressed_style)

		# Enhanced text with glow
		back_btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.95, 1.0))
		back_btn.add_theme_font_size_override("font_size", 18)

		# Add pulsing danger glow
		back_btn.modulate = Color(1.1, 1.0, 1.05, 1.0)
		_add_danger_glow_pulse(back_btn)

	# ADVANCED Header with mystical styling
	var header = find_child("Header")
	if header:
		# Apply background style to the header container
		pass

	# ADVANCED Bottom panel
	var bottom_panel = find_child("BottomPanel")
	if bottom_panel and bottom_panel is Panel:
		_create_advanced_shadow_box(bottom_panel, Vector2(4, 8))

	# Enhance labels with glow effects
	_enhance_map_labels()

	print("✨ ADVANCED RunMap Visual Effects Applied!")

func _add_danger_glow_pulse(button: Button):
	"""Add pulsing danger glow effect to button"""
	var tween = button.create_tween()
	tween.set_loops()

	var bright_glow = Color(1.2, 1.0, 1.1, 1.0)
	var normal_glow = Color(1.1, 1.0, 1.05, 1.0)

	tween.tween_property(button, "modulate", bright_glow, 2.0)
	tween.tween_property(button, "modulate", normal_glow, 2.0)

func _create_advanced_shadow_box(panel: Panel, shadow_offset: Vector2):
	"""Create advanced shadow box with custom offset"""
	var style = StyleBoxFlat.new()

	# Deep mystical background
	style.bg_color = Color(0.05, 0.07, 0.13, 0.93)

	# THICK borders with mystical colors
	style.border_width_left = 4
	style.border_width_right = 4
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.border_color = Color(0.35, 0.3, 0.5, 0.9)

	# VARIED corner radius for handmade feel
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 10

	# DRAMATIC shadow with custom offset
	style.shadow_color = Color(0.1, 0.05, 0.2, 0.8)
	style.shadow_size = 10
	style.shadow_offset = shadow_offset

	panel.add_theme_stylebox_override("panel", style)

func _enhance_map_labels():
	"""Enhance map labels with glow effects"""
	# Floor info with cosmic glow
	if floor_info:
		floor_info.add_theme_font_size_override("font_size", 18)
		floor_info.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3, 1.0))
		floor_info.add_theme_color_override("font_shadow_color", Color(0.8, 0.6, 0.1, 0.7))
		floor_info.add_theme_constant_override("shadow_offset_x", 3)
		floor_info.add_theme_constant_override("shadow_offset_y", 3)

	# HP label with health colors
	if hp_label:
		hp_label.add_theme_font_size_override("font_size", 16)
		hp_label.add_theme_color_override("font_shadow_color", Color(0.8, 0.2, 0.2, 0.6))
		hp_label.add_theme_constant_override("shadow_offset_x", 2)
		hp_label.add_theme_constant_override("shadow_offset_y", 2)

	# Gold label with golden glow
	if gold_label:
		gold_label.add_theme_font_size_override("font_size", 16)
		gold_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4, 1.0))
		gold_label.add_theme_color_override("font_shadow_color", Color(0.8, 0.7, 0.2, 0.6))
		gold_label.add_theme_constant_override("shadow_offset_x", 2)
		gold_label.add_theme_constant_override("shadow_offset_y", 2)

	# Node info with mystical glow
	if node_info:
		node_info.add_theme_font_size_override("font_size", 15)
		node_info.add_theme_color_override("font_color", Color(0.9, 0.8, 1.0, 1.0))
		node_info.add_theme_color_override("font_shadow_color", Color(0.5, 0.4, 0.7, 0.6))
		node_info.add_theme_constant_override("shadow_offset_x", 2)
		node_info.add_theme_constant_override("shadow_offset_y", 2)

func _style_bottom_panels():
	"""Style individual bottom bar panels with variation"""
	# Status panel
	var status_panel = find_child("StatusPanel")
	if status_panel:
		_create_varied_panel(status_panel, Color(0.06, 0.08, 0.14, 0.93), Vector2(2, 3))

	# Progress panel
	var progress_panel = find_child("ProgressPanel")
	if progress_panel:
		_create_varied_panel(progress_panel, Color(0.08, 0.06, 0.14, 0.93), Vector2(3, 2))

	# Action hint panel
	var action_panel = find_child("ActionHintPanel")
	if action_panel:
		_create_varied_panel(action_panel, Color(0.07, 0.09, 0.13, 0.93), Vector2(4, 4))

func _create_varied_panel(panel: Panel, bg_color: Color, shadow_offset: Vector2):
	"""Create panel with varied styling"""
	var style = StyleBoxFlat.new()

	style.bg_color = bg_color

	# VARIED borders for each panel
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.3, 0.25, 0.45, 0.8)

	# ORGANIC corner variations
	var corner_base = 8
	style.corner_radius_top_left = corner_base + 2
	style.corner_radius_top_right = corner_base - 1
	style.corner_radius_bottom_left = corner_base + 3
	style.corner_radius_bottom_right = corner_base

	# Subtle shadows with variation
	style.shadow_color = Color(0.1, 0.05, 0.2, 0.6)
	style.shadow_size = 6
	style.shadow_offset = shadow_offset

	panel.add_theme_stylebox_override("panel", style)

func _update_map_display():
	"""Atualizar visualização do mapa usando TreeMap"""
	var floor_preview = run_manager.get_floor_preview()
	if floor_preview.is_empty():
		return

	# Converter dados do RunManager para formato do TreeMap
	var tree_data = _convert_floor_data_to_tree(floor_preview)

	# Generate simple map buttons in GridContainer
	_generate_simple_map(tree_data)

func _convert_floor_data_to_tree(floor_preview: Array) -> Array:
	"""Converter dados do floor para formato de árvore"""
	var tree_data = []

	for layer_index in range(floor_preview.size()):
		var layer_data = floor_preview[layer_index]
		var layer_nodes = []

		for node_index in range(layer_data.nodes.size()):
			var node_type = layer_data.nodes[node_index]
			var node_name = run_manager.get_node_type_name(node_type)

			# Criar dados do node para TreeMap
			var node_data = {
				"type": _get_tree_node_type(node_type),
				"name": node_name,
				"layer": layer_index,
				"index": node_index,
				"available": layer_data.is_current,
				"completed": layer_data.is_completed,
				"connections": _get_node_connections(layer_index, node_index, floor_preview)
			}

			layer_nodes.append(node_data)

		tree_data.append(layer_nodes)

	return tree_data

func _get_tree_node_type(run_node_type) -> String:
	"""Converter tipo do RunManager para tipo do TreeMap"""
	match run_node_type:
		run_manager.NodeType.COMBAT:
			return "combat"
		run_manager.NodeType.ELITE:
			return "elite"
		run_manager.NodeType.BOSS:
			return "boss"
		run_manager.NodeType.EVENT:
			return "mystery"
		run_manager.NodeType.REST:
			return "campfire"
		run_manager.NodeType.SHOP:
			return "shop"
		_:
			return "combat"

func _get_node_connections(layer_index: int, node_index: int, floor_preview: Array) -> Array:
	"""Determinar conexões para criar estrutura de árvore"""
	# Se não é a última layer, conectar com nodes da próxima layer
	if layer_index < floor_preview.size() - 1:
		var next_layer = floor_preview[layer_index + 1]
		var connections = []

		# Por simplicidade, cada node conecta com os 2 próximos nodes (ou todos se houver menos)
		var start_index = max(0, node_index - 1)
		var end_index = min(next_layer.nodes.size() - 1, node_index + 1)

		for i in range(start_index, end_index + 1):
			connections.append(i)

		return connections

	return []

func _get_node_color(node_type) -> Color:
	"""Obter cor base do tipo de node"""
	match node_type:
		run_manager.NodeType.COMBAT:
			return Color(1.0, 0.8, 0.8)  # Rosa claro
		run_manager.NodeType.ELITE:
			return Color(1.0, 0.6, 0.6)  # Vermelho claro
		run_manager.NodeType.BOSS:
			return Color(0.8, 0.4, 0.4)  # Vermelho escuro
		run_manager.NodeType.EVENT:
			return Color(0.8, 0.8, 1.0)  # Azul claro
		run_manager.NodeType.REST:
			return Color(0.8, 1.0, 0.8)  # Verde claro
		run_manager.NodeType.SHOP:
			return Color(1.0, 1.0, 0.8)  # Amarelo claro
		_:
			return Color.WHITE

func _generate_simple_map(tree_data: Array):
	"""Generate simple map with buttons in GridContainer"""
	# Clear existing children
	for child in tree_map.get_children():
		child.queue_free()

	# Generate buttons for each layer
	for layer_index in range(tree_data.size()):
		var layer_data = tree_data[layer_index]

		for node_index in range(layer_data.size()):
			var node_data = layer_data[node_index]

			# Create button for each node
			var btn = Button.new()
			btn.text = node_data.name
			btn.custom_minimum_size = Vector2(100, 60)

			# Style the button based on availability
			if node_data.available:
				btn.modulate = Color.WHITE
				btn.disabled = false
				# Connect to selection
				btn.pressed.connect(_on_node_button_pressed.bind(node_data))
			else:
				btn.modulate = Color.GRAY
				btn.disabled = true

			# Add to grid
			tree_map.add_child(btn)

func _on_node_button_pressed(node_data: Dictionary):
	"""Handle node button press"""
	_on_tree_node_selected(node_data)

func _on_tree_node_selected(node_data: Dictionary):
	"""Quando jogador seleciona um node no TreeMap"""
	print("🎯 RunMap recebeu node_selected: %s" % node_data)

	if not node_data.get("available", false):
		print("⚠️ Node não disponível")
		return

	var choice_index = node_data.get("index", 0)
	var chosen_node_type = run_manager.choose_node(choice_index)
	print("🎯 Jogador escolheu: %s" % run_manager.get_node_type_name(chosen_node_type))

	# Navegar para cena apropriada baseada no tipo de node escolhido
	match chosen_node_type:
		run_manager.NodeType.COMBAT:
			get_tree().change_scene_to_file("res://scenes/gameplay/Combat.tscn")
		run_manager.NodeType.ELITE:
			# Elite = combate mais difícil
			get_tree().change_scene_to_file("res://scenes/gameplay/Combat.tscn")
		run_manager.NodeType.BOSS:
			# Boss = combate especial
			get_tree().change_scene_to_file("res://scenes/gameplay/Combat.tscn")
		run_manager.NodeType.EVENT:
			# Navegar para tela de eventos
			get_tree().change_scene_to_file("res://scenes/ui/EventScreen.tscn")
		run_manager.NodeType.REST:
			get_tree().change_scene_to_file("res://scenes/ui/Campfire.tscn")
		run_manager.NodeType.SHOP:
			get_tree().change_scene_to_file("res://scenes/ui/Shop.tscn")


func _on_back_pressed():
	"""Abandonar run atual"""
	if run_manager and run_manager.current_run_active:
		print("🚪 Abandonando run...")
		run_manager._complete_run(false)

	get_tree().change_scene_to_file("res://scenes/ui/Hub.tscn")