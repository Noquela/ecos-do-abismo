# Sprint 9 - Interface do Mapa de Run
extends Control

@onready var floor_info = $Header/FloorInfo
@onready var hp_label = $Header/PlayerStats/HPLabel
@onready var gold_label = $Header/PlayerStats/GoldLabel
@onready var map_grid = $MapContainer/MapGrid
@onready var node_info = $BottomPanel/BottomContainer/NodeInfo
@onready var back_btn = $BottomPanel/BottomContainer/ButtonsContainer/BackButton
@onready var next_btn = $BottomPanel/BottomContainer/ButtonsContainer/NextButton

# Referência ao RunManager
var run_manager: Node

func _ready():
	print("🗺️ RunMap carregado - Sprint 9")

	# Obter RunManager
	run_manager = get_node("/root/RunManager")
	if not run_manager:
		print("❌ RunManager não encontrado!")
		return

	# Conectar botões
	back_btn.pressed.connect(_on_back_pressed)
	# next_btn não é mais usado - escolhas são feitas diretamente no mapa

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

	# Atualizar header
	floor_info.text = "Andar %d de %d - Layer %d/%d" % [progress.floor, progress.max_floors, progress.layer + 1, progress.layers_per_floor]
	hp_label.text = "❤️ HP: %d/%d" % [progress.hp, progress.max_hp]
	gold_label.text = "💰 %d moedas" % progress.gold

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
	hp_label.text = "❤️ HP: --/--"
	gold_label.text = "💰 -- moedas"
	node_info.text = "Inicie uma nova run no Hub"
	next_btn.disabled = true

func _update_map_display():
	"""Atualizar visualização do mapa com contexto futuro"""
	# Limpar grid atual
	for child in map_grid.get_children():
		child.queue_free()

	var floor_preview = run_manager.get_floor_preview()
	if floor_preview.is_empty():
		return

	# Mostrar todas as layers com contexto
	for layer_data in floor_preview:
		var layer_container = VBoxContainer.new()

		# Label da layer
		var layer_label = Label.new()
		layer_label.text = "Layer %d" % (layer_data.layer + 1)
		layer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

		if layer_data.is_current:
			layer_label.text += " (ATUAL)"
			layer_label.modulate = Color.WHITE
		elif layer_data.is_completed:
			layer_label.text += " (COMPLETO)"
			layer_label.modulate = Color.GRAY
		else:
			layer_label.text += " (FUTURO)"
			layer_label.modulate = Color.DIM_GRAY

		layer_container.add_child(layer_label)

		# Container para nodes da layer
		var nodes_container = HBoxContainer.new()

		# Criar botões para cada node da layer
		for i in range(layer_data.nodes.size()):
			var node_type = layer_data.nodes[i]
			var btn = Button.new()

			# Configurar texto e cor baseado no tipo
			var node_name = run_manager.get_node_type_name(node_type)
			btn.text = node_name
			btn.custom_minimum_size = Vector2(120, 60)

			# Estado baseado na layer
			if layer_data.is_current:
				# Layer atual - botões clicáveis
				btn.disabled = false
				btn.pressed.connect(_on_node_choice_pressed.bind(i))
			else:
				# Layers passadas/futuras - só preview
				btn.disabled = true

			# Cores por tipo de node
			var base_color = _get_node_color(node_type)

			if layer_data.is_completed:
				btn.modulate = base_color * 0.5  # Mais escuro (completo)
			elif layer_data.is_future:
				btn.modulate = base_color * 0.7  # Meio transparente (futuro)
			else:
				btn.modulate = base_color  # Normal (atual)

			nodes_container.add_child(btn)

		layer_container.add_child(nodes_container)
		map_grid.add_child(layer_container)

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

func _on_node_choice_pressed(choice_index: int):
	"""Quando jogador escolhe um node"""
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