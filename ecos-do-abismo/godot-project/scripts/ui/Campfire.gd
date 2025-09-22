# Sprint 15 - Sistema de Descanso/Fogueira
extends Control

@onready var ambiance_label = $CampfirePanel/CampfireContainer/AmbianceLabel
@onready var recommendation_label = $CampfirePanel/CampfireContainer/RecommendationLabel
@onready var player_status_label = $CampfirePanel/CampfireContainer/PlayerStatusLabel
@onready var options_container = $CampfirePanel/CampfireContainer/OptionsContainer
@onready var continue_btn = $ContinueButton

var campfire_options := []
var option_buttons := []
var action_taken := false

func _ready():
	print("🔥 Campfire - Sprint 15: Sistema de descanso")

	# Conectar botão continuar
	continue_btn.pressed.connect(_on_continue_pressed)
	continue_btn.visible = false

	# Gerar opções da fogueira
	_generate_campfire_options()

	# Atualizar interface
	_update_ui()

func _generate_campfire_options():
	"""Gerar opções da fogueira"""
	campfire_options = CampfireSystem.get_campfire_options()
	print("🔥 Fogueira carregada com %d opções" % campfire_options.size())

func _update_ui():
	"""Atualizar interface da fogueira"""
	if not CampfireSystem.can_use_campfire():
		print("❌ Fogueira só funciona durante runs")
		return

	# Texto de ambientação
	ambiance_label.text = CampfireSystem.get_campfire_ambiance_text()

	# Recomendação baseada no estado
	recommendation_label.text = CampfireSystem.get_rest_recommendation()

	# Status do jogador
	var progress = RunManager.get_run_progress()
	player_status_label.text = "❤️ HP: %d/%d | 🃏 Deck: %d cartas" % [progress.hp, progress.max_hp, progress.deck_size]

	# Limpar botões existentes
	for btn in option_buttons:
		btn.queue_free()
	option_buttons.clear()

	# Criar botões para cada opção
	for i in range(campfire_options.size()):
		var option = campfire_options[i]
		var btn = Button.new()

		# Configurar botão
		btn.text = "%s %s\n%s" % [option.icon, option.name, option.description]
		btn.custom_minimum_size = Vector2(300, 100)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# Verificar se a opção está disponível
		if option.has("requires_cards") and RunManager.get_run_deck().is_empty():
			btn.disabled = true
			btn.modulate = Color.GRAY
			btn.tooltip_text = "Sem cartas no deck"

		# Conectar sinal
		btn.pressed.connect(_on_option_pressed.bind(i))

		options_container.add_child(btn)
		option_buttons.append(btn)

	print("🔥 Interface atualizada - %d opções disponíveis" % campfire_options.size())

func _on_option_pressed(option_index: int):
	"""Quando uma opção é pressionada"""
	if action_taken:
		return

	var option = campfire_options[option_index]
	action_taken = true

	print("🔥 Opção selecionada: %s" % option.name)

	# Executar ação
	var result = CampfireSystem.execute_campfire_action(option.action)

	if result.success:
		if result.needs_card_selection:
			_handle_card_upgrade()
		else:
			_show_action_result(result.message)
	else:
		_show_action_result("❌ Falha ao executar ação")

func _handle_card_upgrade():
	"""Lidar com melhoria de carta"""
	var candidates = CampfireSystem.get_upgrade_candidates()

	if candidates.is_empty():
		_show_action_result("❌ Nenhuma carta disponível para melhoria")
		return

	# Criar popup de seleção de carta
	var card_selection = _create_card_upgrade_popup(candidates)
	add_child(card_selection)

func _create_card_upgrade_popup(candidates: Array) -> Control:
	"""Criar popup para melhoria de carta"""
	var popup = Control.new()
	popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Background escuro
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.7)
	popup.add_child(bg)

	# Panel principal
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.size = Vector2(800, 600)
	panel.position = Vector2(-400, -300)
	popup.add_child(panel)

	# Container
	var container = VBoxContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 20)
	panel.add_child(container)

	# Título
	var title = Label.new()
	title.text = "⬆️ Escolha uma carta para MELHORAR"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(title)

	# Scroll container para cartas
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(scroll)

	var cards_grid = GridContainer.new()
	cards_grid.columns = 3
	scroll.add_child(cards_grid)

	# Criar botões para cada carta candidata
	for candidate in candidates:
		var card = candidate.card
		var card_btn = Button.new()
		card_btn.text = "🃏 %s\n⚡ %d energia\n%s" % [card.name, card.cost, card.description]
		card_btn.custom_minimum_size = Vector2(200, 120)
		card_btn.pressed.connect(_on_card_upgrade_selected.bind(candidate.index, popup))
		cards_grid.add_child(card_btn)

	# Botão cancelar
	var cancel_btn = Button.new()
	cancel_btn.text = "❌ Cancelar"
	cancel_btn.pressed.connect(_on_card_upgrade_canceled.bind(popup))
	container.add_child(cancel_btn)

	return popup

func _on_card_upgrade_selected(card_index: int, popup: Control):
	"""Quando uma carta é selecionada para melhoria"""
	var result = CampfireSystem.upgrade_card(card_index)
	popup.queue_free()
	_show_action_result(result.message)

func _on_card_upgrade_canceled(popup: Control):
	"""Quando melhoria de carta é cancelada"""
	popup.queue_free()
	action_taken = false
	_show_action_result("❌ Melhoria cancelada")

func _show_action_result(message: String):
	"""Mostrar resultado da ação"""
	print("📢 %s" % message)

	# Desabilitar todas as opções
	for btn in option_buttons:
		btn.disabled = true
		btn.modulate = Color.GRAY

	# Atualizar texto de ambientação com resultado
	ambiance_label.text = "🔥 " + message

	# Mostrar botão continuar
	continue_btn.visible = true

func _on_continue_pressed():
	"""Continuar após ação na fogueira"""
	print("➡️ Continuando após fogueira...")

	# Completar node e voltar ao mapa
	RunManager.complete_current_node()
	GameData.save_game()

	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/ui/RunMap.tscn")