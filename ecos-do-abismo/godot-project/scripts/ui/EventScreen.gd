# Sprint 13 - Interface de Eventos
extends Control

@onready var title_label = $EventPanel/EventContainer/TitleLabel
@onready var description_label = $EventPanel/EventContainer/DescriptionLabel
@onready var image_rect = $EventPanel/EventContainer/EventImage
@onready var choices_container = $EventPanel/EventContainer/ChoicesContainer
@onready var continue_btn = $ContinueButton

var current_event := {}
var choice_made := false
var choice_result := ""

func _ready():
	print("📖 Event Screen - Sprint 13: Sistema de eventos")

	# Conectar botão continuar
	continue_btn.pressed.connect(_on_continue_pressed)
	continue_btn.visible = false

	# Carregar evento aleatório
	_load_random_event()

func _load_random_event():
	"""Carregar evento aleatório"""
	current_event = EventSystem.get_random_event()

	if current_event.is_empty():
		print("❌ Nenhum evento disponível")
		_finish_event()
		return

	_display_event()

func _display_event():
	"""Exibir evento na interface"""
	title_label.text = "📖 " + current_event.name
	description_label.text = current_event.description

	# TODO: Carregar imagem baseada em current_event.image
	# Por enquanto, usar placeholder
	image_rect.modulate = _get_event_color(current_event.type)

	# Criar botões de escolha
	_create_choice_buttons()

	print("📖 Evento carregado: %s" % current_event.name)

func _get_event_color(event_type: EventSystem.EventType) -> Color:
	"""Obter cor baseada no tipo de evento"""
	match event_type:
		EventSystem.EventType.NARRATIVE: return Color.LIGHT_BLUE
		EventSystem.EventType.CHOICE: return Color.YELLOW
		EventSystem.EventType.RISK_REWARD: return Color.ORANGE
		EventSystem.EventType.SPECIAL: return Color.PURPLE
		_: return Color.WHITE

func _create_choice_buttons():
	"""Criar botões para as escolhas"""
	# Limpar botões existentes
	for child in choices_container.get_children():
		child.queue_free()

	# Criar botão para cada escolha
	for i in range(current_event.choices.size()):
		var choice = current_event.choices[i]
		var btn = Button.new()

		# Configurar texto do botão
		var button_text = choice.text

		# Adicionar custo se houver
		if choice.has("cost"):
			var cost_text = _format_cost(choice.cost)
			if cost_text != "":
				button_text += " (" + cost_text + ")"

		btn.text = button_text
		btn.custom_minimum_size = Vector2(300, 60)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# Verificar se pode pagar o custo
		if not EventSystem.can_afford_choice(choice):
			btn.disabled = true
			btn.modulate = Color.GRAY
			btn.tooltip_text = "Você não pode pagar este custo."

		# Conectar sinal
		btn.pressed.connect(_on_choice_selected.bind(i))

		choices_container.add_child(btn)

func _format_cost(cost: Dictionary) -> String:
	"""Formatar texto do custo"""
	var cost_parts = []

	if cost.has("gold"):
		cost_parts.append("💰 %d moedas" % cost.gold)

	if cost.has("hp"):
		cost_parts.append("❤️ %d HP" % cost.hp)

	return " + ".join(cost_parts)

func _on_choice_selected(choice_index: int):
	"""Quando uma escolha é selecionada"""
	if choice_made:
		return

	var choice = current_event.choices[choice_index]
	choice_made = true

	print("✅ Escolha selecionada: %s" % choice.text)

	# Pagar custo da escolha
	EventSystem.pay_choice_cost(choice)

	# Aplicar efeito da escolha
	var player_stats = GameData.get_player_stats()
	var result = EventSystem.apply_event_effect(choice.effect, player_stats)

	# Mostrar resultado
	if choice.has("result_text"):
		choice_result = choice.result_text
	else:
		choice_result = result.message

	_show_result()

func _show_result():
	"""Mostrar resultado da escolha"""
	# Desabilitar botões de escolha
	for btn in choices_container.get_children():
		btn.disabled = true
		btn.modulate = Color.GRAY

	# Atualizar descrição com resultado
	description_label.text += "\n\n✨ " + choice_result

	# Mostrar botão continuar
	continue_btn.visible = true

	print("📋 Resultado: %s" % choice_result)

func _on_continue_pressed():
	"""Continuar após evento"""
	print("➡️ Continuando após evento...")
	_finish_event()

func _finish_event():
	"""Finalizar evento e voltar ao mapa"""
	# Completar node atual no RunManager
	RunManager.complete_current_node()

	# Salvar progresso
	GameData.save_game()

	# Voltar ao mapa
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://scenes/ui/RunMap.tscn")

func get_event_summary() -> String:
	"""Obter resumo do evento para logs"""
	if current_event.is_empty():
		return "Nenhum evento"

	var summary = "📖 %s" % current_event.name
	if choice_made and choice_result != "":
		summary += " - " + choice_result

	return summary