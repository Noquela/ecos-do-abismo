# Sprint 8+ - Combate com interface premium
extends Control

@onready var back_btn = $BackButton
@onready var cards_container = $CardsPanel/CardsSection/CardsContainer

# UI com painéis organizados
@onready var enemy_hp_label = $EnemyPanel/EnemySection/EnemyHP
@onready var enemy_hp_bar = $EnemyPanel/EnemySection/EnemyHPBar
@onready var enemy_shield_label = $EnemyPanel/EnemySection/EnemyShield

@onready var player_hp_label = $PlayerPanel/PlayerSection/PlayerHP
@onready var player_hp_bar = $PlayerPanel/PlayerSection/PlayerHPBar
@onready var player_shield_label = $PlayerPanel/PlayerSection/PlayerShield
@onready var energy_label = $PlayerPanel/PlayerSection/EnergyLabel
@onready var energy_bar = $PlayerPanel/PlayerSection/EnergyBar

@onready var turn_label = $GameInfoPanel/GameInfo/TurnLabel
@onready var enemy_number_label = $GameInfoPanel/GameInfo/EnemyNumberLabel
@onready var streak_label = $GameInfoPanel/GameInfo/StreakLabel

var enemy_hp = 35
var enemy_max_hp = 35
var enemy_shield = 0
var player_hp = 100
var player_max_hp = 100
var energy = 4
var max_energy = 4
var player_shield = 0
var damage_bonus = 0
var turn_count = 1
var enemy_count = 1

var hand = []

func _ready():
	print("⚔️ COMBATE - Sprint 9: Integrado com Runs")
	back_btn.pressed.connect(_on_back_pressed)

	# Verificar se estamos em uma run ativa
	if RunManager.current_run_active:
		_setup_run_combat()
	else:
		_setup_standalone_combat()

	_start_turn()

func _setup_run_combat():
	"""Configurar combate dentro de uma run"""
	print("🗺️ Combate em run ativa")

	# Usar dados da run atual
	var progress = RunManager.get_run_progress()
	player_hp = progress.hp
	player_max_hp = progress.max_hp

	# Aplicar upgrades permanentes na energia
	var stats = GameData.get_player_stats()
	max_energy = stats.starting_energy
	damage_bonus = stats.damage_bonus

	# Configurar inimigo baseado no tipo de node e andar
	var node_type = RunManager.get_current_node_type()
	match node_type:
		RunManager.NodeType.COMBAT:
			enemy_hp = 25 + (progress.floor * 10)
			enemy_max_hp = enemy_hp
			print("⚔️ Combate normal - Andar %d" % progress.floor)
		RunManager.NodeType.ELITE:
			enemy_hp = 40 + (progress.floor * 15)
			enemy_max_hp = enemy_hp
			print("💀 Combate Elite - Andar %d" % progress.floor)
		RunManager.NodeType.BOSS:
			enemy_hp = 60 + (progress.floor * 25)
			enemy_max_hp = enemy_hp
			print("👹 Boss Fight - Andar %d" % progress.floor)

func _setup_standalone_combat():
	"""Configurar combate standalone (modo antigo)"""
	print("🎮 Combate standalone")

	# Aplicar upgrades permanentes
	var stats = GameData.get_player_stats()
	player_hp = stats.max_hp
	player_max_hp = stats.max_hp
	max_energy = stats.starting_energy
	damage_bonus = stats.damage_bonus

	# Calcular HP do inimigo baseado no número
	enemy_hp = 30 + (enemy_count * 5)
	enemy_max_hp = enemy_hp

	print("💪 Upgrades aplicados: HP %d, Energia %d, Dano +%d" % [player_hp, max_energy, damage_bonus])

func _start_turn():
	print("🔄 TURNO %d - Inimigo %d" % [turn_count, enemy_count])
	energy = max_energy
	_draw_cards()
	_update_ui()
	turn_count += 1

func _draw_cards():
	# Limpar mão anterior
	hand.clear()
	for child in cards_container.get_children():
		child.queue_free()

	# Usar cartas do deck da run se estivermos em run ativa
	var available_cards = []
	if RunManager.current_run_active:
		available_cards = RunManager.get_run_deck()
		print("🃏 Usando deck da run: %d cartas disponíveis" % available_cards.size())
	else:
		available_cards = GameData.get_available_cards()
		print("🃏 Usando cartas do GameData: %d cartas disponíveis" % available_cards.size())

	# Sacar 4 cartas aleatórias das disponíveis
	for i in range(4):
		var card = available_cards[randi() % available_cards.size()].duplicate()
		hand.append(card)

		# Criar botão para a carta com estilo melhorado
		var btn = Button.new()
		btn.text = "🃏 %s\n⚡ %d energia" % [card.name, card.cost]
		btn.custom_minimum_size = Vector2(120, 80)

		# Visual feedback baseado no tipo da carta
		match card.name:
			"Ataque":
				btn.modulate = Color(1.0, 0.8, 0.8)  # Vermelho claro
			"Defesa":
				btn.modulate = Color(0.8, 0.8, 1.0)  # Azul claro
			"Cura":
				btn.modulate = Color(0.8, 1.0, 0.8)  # Verde claro
			_:
				btn.modulate = Color(1.0, 1.0, 0.8)  # Amarelo claro

		btn.pressed.connect(_on_card_played.bind(i))
		cards_container.add_child(btn)

func _on_card_played(card_index: int):
	var card = hand[card_index]

	# Verificar energia
	if energy < card.cost:
		print("❌ Energia insuficiente!")
		return

	# Gastar energia
	energy -= card.cost

	print("🃏 Jogou: %s" % card.name)

	# Aplicar efeito
	match card.type:
		"attack":
			var damage = card.damage + damage_bonus
			var hits = card.get("hits", 1)
			for hit in range(hits):
				enemy_hp -= damage
			print("⚔️ Dano: %d x%d (+%d bonus)" % [damage, hits, damage_bonus])
		"heal":
			player_hp = min(player_max_hp, player_hp + card.heal)
			if card.has("shield"):
				player_shield += card.shield
				print("💚 Cura: %d + 🛡️ Escudo: %d" % [card.heal, card.shield])
			else:
				print("💚 Cura: %d" % card.heal)
		"defense":
			player_shield += card.shield
			print("🛡️ Escudo: +%d (Total: %d)" % [card.shield, player_shield])
		"energy":
			energy += card.energy
			print("⚡ +%d energia (Total: %d)" % [card.energy, energy])
		"power":
			# Powers aplicam modificadores permanentes no combate
			if card.has("damage_bonus"):
				damage_bonus += card.damage_bonus
				print("💪 +%d dano permanente (Total: +%d)" % [card.damage_bonus, damage_bonus])
			if card.has("shield_bonus"):
				# TODO: Implementar shield bonus permanente
				print("🛡️ +%d escudo permanente aplicado" % card.shield_bonus)
			if card.has("energy_bonus"):
				max_energy += card.energy_bonus
				print("⚡ +%d energia máxima (Total: %d)" % [card.energy_bonus, max_energy])
		"skill":
			if card.has("draw_cards"):
				print("📋 Compraria %d cartas (não implementado ainda)" % card.draw_cards)
		"combo":
			# Manter compatibilidade com cartas antigas
			var damage = card.damage + damage_bonus
			enemy_hp -= damage
			energy += card.energy
			print("⚔️ Combo: %d dano (+%d bonus) + %d energia" % [damage, damage_bonus, card.energy])

	# Remover carta da mão e recriar interface
	hand.remove_at(card_index)
	_recreate_hand_ui()

	_check_combat_end()
	_update_ui()

	# Verificar se deve terminar turno automaticamente
	if hand.size() == 0 or _cannot_play_any_card():
		await get_tree().create_timer(0.5).timeout
		_end_player_turn()

func _cannot_play_any_card() -> bool:
	"""Verifica se não consegue jogar nenhuma carta restante"""
	for card in hand:
		if energy >= card.cost:
			return false
	return true

func _recreate_hand_ui():
	"""Recriar interface das cartas para evitar problemas de índice"""
	# Limpar botões existentes
	for child in cards_container.get_children():
		child.queue_free()

	# Recriar botões para cartas restantes
	for i in range(hand.size()):
		var card = hand[i]
		var btn = Button.new()
		btn.text = "🃏 %s\n⚡ %d energia" % [card.name, card.cost]
		btn.custom_minimum_size = Vector2(120, 80)

		# Visual feedback baseado no tipo da carta
		match card.name:
			"Ataque":
				btn.modulate = Color(1.0, 0.8, 0.8)  # Vermelho claro
			"Defesa":
				btn.modulate = Color(0.8, 0.8, 1.0)  # Azul claro
			"Cura":
				btn.modulate = Color(0.8, 1.0, 0.8)  # Verde claro
			_:
				btn.modulate = Color(1.0, 1.0, 0.8)  # Amarelo claro

		# Desabilitar se não tem energia
		if energy < card.cost:
			btn.disabled = true
			btn.modulate = Color.GRAY

		btn.pressed.connect(_on_card_played.bind(i))
		cards_container.add_child(btn)

func _check_combat_end():
	if enemy_hp <= 0:
		print("🎉 VITÓRIA!")

		# Verificar se estamos em uma run ativa
		if RunManager.current_run_active:
			_handle_run_victory()
		else:
			_handle_standalone_victory()

func _handle_run_victory():
	"""Vitória em combate durante uma run"""
	print("🗺️ Vitória na run - indo para recompensas")

	# Salvar HP atual na run
	RunManager.set_player_hp(player_hp)

	# Registrar vitória
	GameData.register_victory()
	GameData.save_game()

	# Completar node atual
	RunManager.complete_current_node()

	# Ir para tela de draft/recompensas
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/ui/CardDraft.tscn")

func _handle_standalone_victory():
	"""Vitória em combate standalone (modo antigo)"""
	print("🎮 Vitória standalone - próximo inimigo")

	# Registrar vitória no GameData
	GameData.register_victory()
	GameData.save_game()

	enemy_count += 1
	enemy_hp = int(enemy_hp * 1.3) + 35  # Próximo mais forte
	enemy_max_hp = enemy_hp
	var max_hp = GameData.get_player_stats().max_hp
	player_hp = min(max_hp, player_hp + 15)
	turn_count = 1  # Reset contador de turnos
	print("🔄 Próximo inimigo #%d: HP %d" % [enemy_count, enemy_hp])
	await get_tree().create_timer(1.0).timeout
	_start_turn()
func _end_player_turn():
	"""Terminar turno do jogador e inimigo atacar"""
	print("🔚 Fim do turno do jogador")

	# Inimigo ataca
	var enemy_damage = 12
	var actual_damage = max(0, enemy_damage - player_shield)

	if player_shield > 0:
		var shield_absorbed = min(player_shield, enemy_damage)
		player_shield = max(0, player_shield - enemy_damage)
		print("💥 Inimigo atacou! Dano: %d (🛡️ Absorvido: %d, Real: %d)" % [enemy_damage, shield_absorbed, actual_damage])
	else:
		print("💥 Inimigo atacou! Dano: %d" % actual_damage)

	player_hp -= actual_damage

	if player_hp <= 0:
		print("💀 GAME OVER")

		# Verificar se estamos em uma run ativa
		if RunManager.current_run_active:
			_handle_run_defeat()
		else:
			_handle_standalone_defeat()
	else:
		_update_ui()
		await get_tree().create_timer(1.5).timeout
		_start_turn()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/Hub.tscn")

func _update_ui():
	# Seção do inimigo com barras de progresso
	enemy_hp_label.text = "❤️ HP: %d/%d" % [enemy_hp, enemy_max_hp]
	var enemy_hp_percent = float(enemy_hp) / float(enemy_max_hp) * 100.0
	enemy_hp_bar.value = enemy_hp_percent
	enemy_hp_bar.modulate = Color.RED if enemy_hp_percent < 30 else Color.ORANGE if enemy_hp_percent < 60 else Color.GREEN
	enemy_shield_label.text = "🛡️ Escudo: %d" % enemy_shield

	# Seção do jogador com barras de progresso
	player_hp_label.text = "❤️ HP: %d/%d" % [player_hp, player_max_hp]
	var player_hp_percent = float(player_hp) / float(player_max_hp) * 100.0
	player_hp_bar.value = player_hp_percent
	player_hp_bar.modulate = Color.RED if player_hp_percent < 30 else Color.ORANGE if player_hp_percent < 60 else Color.GREEN
	player_shield_label.text = "🛡️ Escudo: %d" % player_shield

	energy_label.text = "⚡ Energia: %d/%d" % [energy, max_energy]
	var energy_percent = float(energy) / float(max_energy) * 100.0
	energy_bar.value = energy_percent
	energy_bar.modulate = Color.BLUE

	# Informações do jogo
	turn_label.text = "⏰ Turno: %d" % (turn_count - 1)
	enemy_number_label.text = "👹 Inimigo: #%d" % enemy_count
	var current_streak = GameData.current_streak
	streak_label.text = "🔥 Sequência: %d" % current_streak

func _handle_run_defeat():
	"""Derrota em combate durante uma run"""
	print("💀 Derrota na run - run finalizada")

	# Registrar derrota
	GameData.register_defeat()
	GameData.save_game()

	# Terminar run atual (sem sucesso)
	RunManager._complete_run(false)

	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/ui/Hub.tscn")

func _handle_standalone_defeat():
	"""Derrota em combate standalone (modo antigo)"""
	print("💀 Derrota standalone - resetando jogo")

	GameData.register_defeat()
	GameData.save_game()
	_reset_game()

func _reset_game():
	enemy_hp = 35
	enemy_count = 1
	var stats = GameData.get_player_stats()
	player_hp = stats.max_hp
	player_shield = 0
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/ui/Hub.tscn")