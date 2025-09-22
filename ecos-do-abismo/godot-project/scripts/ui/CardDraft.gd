# Sprint 11 - Interface de Draft de Cartas
extends Control

@onready var gold_label = $RewardsPanel/RewardsContainer/GoldSection/GoldLabel
@onready var xp_label = $RewardsPanel/RewardsContainer/XPSection/XPLabel
@onready var cards_container = $CardDraftPanel/DraftContainer/CardsContainer
@onready var skip_btn = $CardDraftPanel/DraftContainer/SkipSection/SkipButton
@onready var continue_btn = $ContinueButton

var draft_options := []
var selected_card := -1
var rewards_given := false

func _ready():
	print("🏆 Card Draft - Sprint 11: Sistema de recompensas")

	# Conectar botões
	skip_btn.pressed.connect(_on_skip_pressed)
	continue_btn.pressed.connect(_on_continue_pressed)

	# Gerar recompensas e opções de draft
	_setup_rewards()
	_setup_draft_options()

	# Continue button começa desabilitado
	continue_btn.disabled = true

func _setup_rewards():
	"""Configurar recompensas básicas"""
	# Recompensas baseadas no tipo de combate
	var gold_reward = 12
	var xp_reward = 15
	var relic_reward = null

	if RunManager.current_run_active:
		var node_type = RunManager.get_current_node_type()
		match node_type:
			RunManager.NodeType.COMBAT:
				gold_reward = 12
				xp_reward = 15
			RunManager.NodeType.ELITE:
				gold_reward = 25
				xp_reward = 30
				# Elite sempre dá relíquia comum
				relic_reward = RelicSystem.get_random_relic(RelicSystem.RelicType.COMMON)
			RunManager.NodeType.BOSS:
				gold_reward = 40
				xp_reward = 50
				# Boss sempre dá relíquia de boss
				relic_reward = RelicSystem.get_random_relic(RelicSystem.RelicType.BOSS)

	# Atualizar labels
	gold_label.text = "💰 +%d moedas" % gold_reward
	if relic_reward:
		xp_label.text = "💎 %s" % relic_reward.name
		xp_label.modulate = RelicSystem.get_relic_color(relic_reward.type)
	else:
		xp_label.text = "✨ +%d XP" % xp_reward
		xp_label.modulate = Color.WHITE

	print("💰 Recompensas: %d ouro, %d XP" % [gold_reward, xp_reward])
	if relic_reward:
		print("💎 Relíquia: %s" % relic_reward.name)

func _setup_draft_options():
	"""Configurar opções de draft"""
	# Gerar 3 cartas aleatórias para escolher
	draft_options = CardPool.get_random_draft_options(3)

	# Criar botões para cada carta
	for i in range(draft_options.size()):
		var card = draft_options[i]
		var btn = Button.new()

		# Configurar botão da carta
		btn.text = _format_card_text(card)
		btn.custom_minimum_size = Vector2(150, 200)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# Cor baseada na raridade
		btn.modulate = CardPool.get_rarity_color(card.rarity)

		# Conectar sinal
		btn.pressed.connect(_on_card_selected.bind(i))

		cards_container.add_child(btn)

	print("🎴 Opções de draft geradas: %d cartas" % draft_options.size())

func _format_card_text(card: Dictionary) -> String:
	"""Formatar texto da carta para o botão"""
	var text = "🃏 %s\n⚡ %d energia\n" % [card.name, card.cost]

	# Adicionar raridade
	text += "⭐ %s\n\n" % CardPool.get_rarity_name(card.rarity)

	# Adicionar efeitos baseados no tipo
	match card.type:
		"attack":
			if card.has("hits") and card.hits > 1:
				text += "⚔️ %d dano x%d" % [card.damage, card.hits]
			else:
				text += "⚔️ %d dano" % card.damage
		"defense":
			text += "🛡️ %d escudo" % card.shield
		"heal":
			text += "💚 %d cura" % card.heal
		"energy":
			text += "⚡ +%d energia" % card.energy
		"power":
			if card.has("damage_bonus"):
				text += "💪 +%d dano permanente" % card.damage_bonus
			elif card.has("shield_bonus"):
				text += "🛡️ +%d escudo permanente" % card.shield_bonus
			elif card.has("energy_bonus"):
				text += "⚡ +%d energia permanente" % card.energy_bonus
		"skill":
			if card.has("draw_cards"):
				text += "📋 Compra %d cartas" % card.draw_cards

	text += "\n\n%s" % card.description
	return text

func _on_card_selected(card_index: int):
	"""Quando jogador seleciona uma carta"""
	selected_card = card_index
	var card = draft_options[card_index]

	print("🎯 Carta selecionada: %s" % card.name)

	# Highlight visual
	_update_card_selection()

	# Habilitar botão continuar
	continue_btn.disabled = false

func _update_card_selection():
	"""Atualizar visual da seleção"""
	for i in range(cards_container.get_child_count()):
		var btn = cards_container.get_child(i)
		if i == selected_card:
			btn.modulate = btn.modulate * 1.2  # Mais brilhante
			btn.text = "✅ SELECIONADA\n\n" + btn.text
		else:
			btn.modulate = btn.modulate * 0.7  # Mais escuro

func _on_skip_pressed():
	"""Pular - não adicionar nenhuma carta"""
	print("❌ Jogador pulou o draft")
	selected_card = -1

	# Desabilitar todas as cartas visualmente
	for btn in cards_container.get_children():
		btn.modulate = btn.modulate * 0.5
		btn.disabled = true

	# Habilitar botão continuar
	continue_btn.disabled = false

func _on_continue_pressed():
	"""Continuar - aplicar recompensas e voltar ao mapa"""
	print("➡️ Aplicando recompensas...")

	# Dar recompensas básicas (se ainda não deu)
	if not rewards_given:
		_give_basic_rewards()
		rewards_given = true

	# Adicionar carta selecionada ao deck
	if selected_card >= 0:
		var chosen_card = draft_options[selected_card]
		RunManager.add_card_to_deck(chosen_card)
		print("🃏 Carta adicionada ao deck: %s" % chosen_card.name)
	else:
		print("⏭️ Nenhuma carta adicionada")

	# Voltar ao mapa
	_return_to_map()

func _give_basic_rewards():
	"""Dar recompensas básicas (ouro, XP e relíquias)"""
	var gold_reward = 12
	var xp_reward = 15
	var relic_reward = null

	if RunManager.current_run_active:
		var node_type = RunManager.get_current_node_type()
		match node_type:
			RunManager.NodeType.COMBAT:
				gold_reward = 12
				xp_reward = 15
			RunManager.NodeType.ELITE:
				gold_reward = 25
				xp_reward = 30
				# Elite sempre dá relíquia comum
				relic_reward = RelicSystem.get_random_relic(RelicSystem.RelicType.COMMON)
			RunManager.NodeType.BOSS:
				gold_reward = 40
				xp_reward = 50
				# Boss sempre dá relíquia de boss
				relic_reward = RelicSystem.get_random_relic(RelicSystem.RelicType.BOSS)

	# Dar recompensas básicas
	GameData.add_coins(gold_reward)
	if relic_reward:
		# Se tem relíquia, não dar XP
		RunManager.add_relic(relic_reward)
		print("💰 +%d moedas, 💎 %s concedidos" % [gold_reward, relic_reward.name])
	else:
		GameData.add_xp(xp_reward)
		print("💰 +%d moedas, +%d XP concedidos" % [gold_reward, xp_reward])

	GameData.save_game()

func _return_to_map():
	"""Voltar ao mapa da run"""
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/ui/RunMap.tscn")