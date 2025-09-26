# Sprint 17 - Combate com Sistema de Intenções
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

# Buff indicators
var player_buff_indicator: Control
var enemy_buff_indicator: Control

# Enemy intent display
var enemy_intent_container: Control

# Combat state - novo sistema
var active_enemies: Array = []
var current_enemy_index: int = 0
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
	print("👹 COMBATE - Sprint 17: Sistema de Intenções dos Inimigos")
	back_btn.pressed.connect(_on_back_pressed)

	# Apply eldritch theme to combat UI
	_apply_combat_theme()

	# Criar indicadores visuais
	_setup_buff_indicators()
	# _setup_intent_display()  # TODO: Implementar display de intenções

	# Limpar sistemas anteriores
	BuffSystem.clear_all_buffs("player")
	for enemy_id in EnemySystem.active_enemies.keys():
		BuffSystem.clear_all_buffs(enemy_id)
		EnemySystem.remove_enemy(enemy_id)

	# Configurar combate
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

	# NOVO SISTEMA: Gerar inimigos baseado no tipo de node e andar
	var node_type = RunManager.get_current_node_type()
	active_enemies = EnemySystem.generate_encounter(progress.floor, node_type)

	if not active_enemies.is_empty():
		current_enemy_index = 0
		print("👹 Encontro gerado: %d inimigos" % active_enemies.size())
		for enemy in active_enemies:
			print("  - %s (HP: %d/%d)" % [enemy.name, enemy.current_hp, enemy.max_hp])
	else:
		print("❌ Erro ao gerar encontro!")

func _setup_standalone_combat():
	"""Configurar combate standalone (modo antigo)"""
	print("🎮 Combate standalone")

	# Aplicar upgrades permanentes
	var stats = GameData.get_player_stats()
	player_hp = stats.max_hp
	player_max_hp = stats.max_hp
	max_energy = stats.starting_energy
	damage_bonus = stats.damage_bonus

	# NOVO SISTEMA: Gerar inimigo simples para modo standalone
	active_enemies = [EnemySystem.create_enemy(EnemySystem.EnemyType.CULTISTA, "standalone_enemy", enemy_count)]
	current_enemy_index = 0

	print("💪 Upgrades aplicados: HP %d, Energia %d, Dano +%d" % [player_hp, max_energy, damage_bonus])

func _start_turn():
	print("🔄 TURNO %d - Inimigo %d" % [turn_count, enemy_count])

	# INTEGRAÇÃO ABYSSSYSTEM: Ativar ecos das cartas anteriores
	AbyssSystem.trigger_echoes()

	# Processar buffs no início do turno
	BuffSystem.process_turn_start_buffs("player")
	BuffSystem.process_turn_start_buffs("enemy")

	# Aplicar energia base + buffs de energia + modificador de corrupção
	var base_energy = max_energy + BuffSystem.get_extra_energy("player")
	var shadow_mana = AbyssSystem.get_shadow_mana()
	energy = base_energy + shadow_mana

	if shadow_mana > 0:
		print("🌙 Energia aumentada pela mana sombria: +%d" % shadow_mana)

	_draw_cards()
	_update_ui()
	_refresh_buff_indicators()
	_update_abyss_display()
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

		# INTEGRAÇÃO ABYSSSYSTEM: Chance de transformar carta pela corrupção
		if AbyssSystem.should_transform_card(card):
			card = AbyssSystem.transform_card(card)

		hand.append(card)

		# Criar CardDisplay para a carta
		var card_display = preload("res://scenes/ui/CardDisplay.tscn").instantiate()
		card_display.display_card(card)
		card_display.custom_minimum_size = Vector2(180, 250)

		# Adicionar click handling
		card_display.card_clicked.connect(func(_card_data): _on_card_played(i))

		# Visual feedback baseado na disponibilidade
		if energy < card.cost:
			card_display.modulate = Color(0.5, 0.5, 0.5, 0.7)  # Escurecido se não tem energia

		cards_container.add_child(card_display)


func _on_card_played(card_index: int):
	var card = hand[card_index]

	# INTEGRAÇÃO ABYSSSYSTEM: Aplicar modificador de custo da corrupção
	var final_cost = max(0, card.cost + AbyssSystem.get_energy_cost_modifier())

	# Verificar energia
	if energy < final_cost:
		print("❌ Energia insuficiente! (Custo: %d)" % final_cost)
		return

	# Gastar energia
	energy -= final_cost

	if final_cost != card.cost:
		print("🌑 Custo modificado pela corrupção: %d → %d" % [card.cost, final_cost])

	print("🃏 Jogou: %s" % card.name)

	# Aplicar efeito
	match card.type:
		"attack":
			var base_damage = card.damage + damage_bonus
			var corruption_damage = AbyssSystem.modify_combat_damage(base_damage)
			var modified_damage = BuffSystem.modify_damage_dealt("player", corruption_damage)
			var final_damage = BuffSystem.modify_damage_received("enemy", modified_damage)
			var hits = card.get("hits", 1)
			var current_enemy = _get_current_enemy()
			if current_enemy != null:
				for hit in range(hits):
					var enemy_died = EnemySystem.damage_enemy(current_enemy["id"], final_damage)
					_create_floating_number(final_damage, Color.ORANGE_RED, enemy_hp_label.global_position)
					if enemy_died:
						_on_enemy_defeated()
						break
			print("⚔️ Dano: %d base → %d corrupção → %d final x%d" % [base_damage, corruption_damage, final_damage, hits])
		"heal":
			player_hp = min(player_max_hp, player_hp + card.heal)
			_create_floating_number(card.heal, Color.GREEN, player_hp_label.global_position)
			if card.has("shield"):
				player_shield += card.shield
				_create_floating_number(card.shield, Color.CYAN, player_shield_label.global_position)
				print("💚 Cura: %d + 🛡️ Escudo: %d" % [card.heal, card.shield])
			else:
				print("💚 Cura: %d" % card.heal)
		"defense":
			var base_shield = card.shield
			var modified_shield = BuffSystem.modify_block_gained("player", base_shield)
			player_shield += modified_shield
			_create_floating_number(modified_shield, Color.CYAN, player_shield_label.global_position)
			print("🛡️ Escudo: %d base → %d final (Total: %d)" % [base_shield, modified_shield, player_shield])
		"energy":
			energy += card.energy
			print("⚡ +%d energia (Total: %d)" % [card.energy, energy])
		"power":
			# Powers aplicam buffs temporários
			if card.has("damage_bonus"):
				BuffSystem.apply_buff("player", BuffSystem.BuffType.STRENGTH, card.damage_bonus, 3)
				print("💪 +%d Força por 3 turnos" % card.damage_bonus)
			if card.has("shield_bonus"):
				BuffSystem.apply_buff("player", BuffSystem.BuffType.DEFENSE, card.shield_bonus, 3)
				print("🛡️ +%d Defesa por 3 turnos" % card.shield_bonus)
			if card.has("energy_bonus"):
				BuffSystem.apply_buff("player", BuffSystem.BuffType.ENERGY, card.energy_bonus, 3)
				print("⚡ +%d Energia por 3 turnos" % card.energy_bonus)
			# Buffs permanentes (para compatibilidade)
			if card.has("permanent_damage"):
				damage_bonus += card.permanent_damage
				print("💪 +%d dano permanente (Total: +%d)" % [card.permanent_damage, damage_bonus])
			if card.has("permanent_energy"):
				max_energy += card.permanent_energy
				print("⚡ +%d energia máxima (Total: %d)" % [card.permanent_energy, max_energy])
		"skill":
			if card.has("draw_cards"):
				print("📋 Compraria %d cartas (não implementado ainda)" % card.draw_cards)
			# Aplicar debuffs nos inimigos
			if card.has("applies_poison"):
				BuffSystem.apply_buff("enemy", BuffSystem.BuffType.POISON, card.applies_poison, card.get("poison_duration", 3))
				print("☠️ Inimigo envenenado: %d dano por %d turnos" % [card.applies_poison, card.get("poison_duration", 3)])
			if card.has("applies_weakness"):
				BuffSystem.apply_buff("enemy", BuffSystem.BuffType.WEAKNESS, card.applies_weakness, card.get("weakness_duration", 2))
				print("💔 Inimigo enfraquecido: -%d dano por %d turnos" % [card.applies_weakness, card.get("weakness_duration", 2)])
			if card.has("applies_vulnerable"):
				BuffSystem.apply_buff("enemy", BuffSystem.BuffType.VULNERABLE, card.applies_vulnerable, card.get("vulnerable_duration", 2))
				print("🎯 Inimigo vulnerável: +%d%% dano por %d turnos" % [card.applies_vulnerable, card.get("vulnerable_duration", 2)])
			# Aplicar buffs no jogador
			if card.has("applies_strength"):
				BuffSystem.apply_buff("player", BuffSystem.BuffType.STRENGTH, card.applies_strength, card.get("strength_duration", 3))
				print("💪 Força aumentada: +%d dano por %d turnos" % [card.applies_strength, card.get("strength_duration", 3)])
			if card.has("applies_regen"):
				BuffSystem.apply_buff("player", BuffSystem.BuffType.REGENERATION, card.applies_regen, card.get("regen_duration", 4))
				print("💚 Regeneração ativa: +%d HP por turno durante %d turnos" % [card.applies_regen, card.get("regen_duration", 4)])
			# Aplicar dano base se a carta tiver
			if card.has("damage"):
				var base_damage = card.damage + damage_bonus
				var modified_damage = BuffSystem.modify_damage_dealt("player", base_damage)
				var final_damage = BuffSystem.modify_damage_received("enemy", modified_damage)
				var current_enemy = _get_current_enemy()
				if current_enemy != null:
					var enemy_died = EnemySystem.damage_enemy(current_enemy["id"], final_damage)
					if enemy_died:
						_on_enemy_defeated()
				print("⚔️ Dano skill: %d base → %d final" % [base_damage, final_damage])
		"combo":
			# Manter compatibilidade com cartas antigas
			var damage = card.damage + damage_bonus
			var current_enemy = _get_current_enemy()
			if current_enemy != null:
				var enemy_died = EnemySystem.damage_enemy(current_enemy["id"], damage)
				if enemy_died:
					_on_enemy_defeated()
			energy += card.energy
			print("⚔️ Combo: %d dano (+%d bonus) + %d energia" % [damage, damage_bonus, card.energy])

	# INTEGRAÇÃO ABYSSSYSTEM: Criar eco da carta jogada
	AbyssSystem.create_echo(card)

	# Remover carta da mão e recriar interface
	hand.remove_at(card_index)
	_recreate_hand_ui()

	_check_combat_end()
	_update_ui()
	_refresh_buff_indicators()

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
	# Limpar cartas existentes
	for child in cards_container.get_children():
		child.queue_free()

	# Recriar CardDisplays para cartas restantes
	for i in range(hand.size()):
		var card = hand[i]
		var card_display = preload("res://scenes/ui/CardDisplay.tscn").instantiate()
		card_display.display_card(card)
		card_display.custom_minimum_size = Vector2(160, 220)

		# Adicionar click handling
		card_display.card_clicked.connect(func(_card_data): _on_card_played(i))

		# Visual feedback baseado na disponibilidade
		if energy < card.cost:
			card_display.modulate = Color(0.5, 0.5, 0.5, 0.7)  # Escurecido se não tem energia
		else:
			card_display.modulate = Color.WHITE

		cards_container.add_child(card_display)

func _check_combat_end():
	if active_enemies.is_empty():
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
	# NOVO SISTEMA: Criar inimigo mais forte
	var new_hp = int(35 * pow(1.3, enemy_count - 1)) + 35
	active_enemies = [EnemySystem.create_enemy(EnemySystem.EnemyType.CULTISTA, "standalone_enemy_%d" % enemy_count, enemy_count)]
	current_enemy_index = 0
	# Ajustar HP do novo inimigo
	var current_enemy = _get_current_enemy()
	if current_enemy != null:
		current_enemy["max_hp"] = new_hp
		current_enemy["current_hp"] = new_hp
	var max_hp = GameData.get_player_stats().max_hp
	player_hp = min(max_hp, player_hp + 15)
	turn_count = 1  # Reset contador de turnos
	print("🔄 Próximo inimigo #%d: HP %d" % [enemy_count, new_hp])
	await get_tree().create_timer(1.0).timeout
	_start_turn()
func _end_player_turn():
	"""Terminar turno do jogador e inimigo atacar"""
	print("🔚 Fim do turno do jogador")

	# Processar buffs no final do turno
	BuffSystem.process_turn_end_buffs("player")
	BuffSystem.process_turn_end_buffs("enemy")

	# Inimigo ataca com modificadores de buff
	var base_enemy_damage = 12
	var modified_enemy_damage = BuffSystem.modify_damage_dealt("enemy", base_enemy_damage)
	var final_enemy_damage = BuffSystem.modify_damage_received("player", modified_enemy_damage)

	var actual_damage = max(0, final_enemy_damage - player_shield)

	if player_shield > 0:
		var shield_absorbed = min(player_shield, final_enemy_damage)
		player_shield = max(0, player_shield - final_enemy_damage)
		print("💥 Inimigo atacou! Dano: %d base → %d final (🛡️ Absorvido: %d, Real: %d)" % [base_enemy_damage, final_enemy_damage, shield_absorbed, actual_damage])
	else:
		print("💥 Inimigo atacou! Dano: %d base → %d final" % [base_enemy_damage, final_enemy_damage])

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
		_refresh_buff_indicators()
		await get_tree().create_timer(1.5).timeout
		_start_turn()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/Hub.tscn")

func _create_floating_number(value: int, color: Color, start_pos: Vector2):
	"""Create floating damage/heal number with juice animation"""
	var label = Label.new()
	label.text = str(value)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	# Add outline for visibility
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 2)

	# Position the label
	label.global_position = start_pos + Vector2(-20, -10)
	get_viewport().add_child(label)

	# Animate the floating number
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)

	# Scale in effect
	label.scale = Vector2.ZERO
	tween.parallel().tween_property(label, "scale", Vector2.ONE, 0.2)

	# Float up and fade out
	tween.parallel().tween_property(label, "global_position", start_pos + Vector2(randf_range(-30, 30), -80), 1.0)
	tween.parallel().tween_property(label, "modulate", Color.TRANSPARENT, 1.0)

	# Cleanup
	tween.tween_callback(label.queue_free)

func _update_ui():
	# NOVO SISTEMA: Usar dados do inimigo atual
	var enemy_data = _get_current_enemy_display_data()

	# Seção do inimigo com barras de progresso
	enemy_hp_label.text = "❤️ HP: %d/%d" % [enemy_data.hp, enemy_data.max_hp]
	var enemy_hp_percent = float(enemy_data.hp) / float(enemy_data.max_hp) * 100.0
	enemy_hp_bar.value = enemy_hp_percent
	enemy_hp_bar.modulate = Color.RED if enemy_hp_percent < 30 else Color.ORANGE if enemy_hp_percent < 60 else Color.GREEN
	enemy_shield_label.text = "🛡️ Escudo: %d" % enemy_data.shield

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
	# NOVO SISTEMA: Resetar usando EnemySystem
	active_enemies = [EnemySystem.create_enemy(EnemySystem.EnemyType.CULTISTA, "standalone_enemy", 1)]
	current_enemy_index = 0
	enemy_count = 1
	var stats = GameData.get_player_stats()
	player_hp = stats.max_hp
	player_shield = 0
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/ui/Hub.tscn")

# === BUFF INDICATOR FUNCTIONS ===

func _setup_buff_indicators():
	"""Configurar indicadores visuais de buff"""
	# Criar indicador de buffs do jogador
	player_buff_indicator = preload("res://scenes/ui/BuffIndicator.tscn").instantiate()
	player_buff_indicator.position = Vector2(50, 500)  # Posição próxima ao painel do jogador
	player_buff_indicator.set_target("player")
	add_child(player_buff_indicator)

	# Criar indicador de buffs do inimigo
	enemy_buff_indicator = preload("res://scenes/ui/BuffIndicator.tscn").instantiate()
	enemy_buff_indicator.position = Vector2(900, 100)  # Posição próxima ao painel do inimigo
	enemy_buff_indicator.set_target("enemy")
	add_child(enemy_buff_indicator)

	print("🔮 Indicadores de buff configurados")

func _refresh_buff_indicators():
	"""Atualizar indicadores de buff"""
	if player_buff_indicator:
		player_buff_indicator.refresh_buffs()
	if enemy_buff_indicator:
		enemy_buff_indicator.refresh_buffs()

func _update_abyss_display():
	"""Atualizar display de informações do abismo"""
	var status = AbyssSystem.get_abyss_status()

	# Atualizar label de streak para mostrar info do abismo
	streak_label.text = "🌑 Profundidade: %d | Corrupção: %d%%" % [status.depth, status.corruption]

	# Modificar cor baseada na corrupção
	if status.corruption >= 75:
		streak_label.modulate = Color.PURPLE  # Alta corrupção
	elif status.corruption >= 50:
		streak_label.modulate = Color.MAGENTA  # Média corrupção
	elif status.corruption >= 25:
		streak_label.modulate = Color.ORANGE   # Baixa corrupção
	else:
		streak_label.modulate = Color.WHITE    # Sem corrupção

	# Log de ecos ativos
	if status.active_echoes > 0:
		print("🔮 %d ecos ativos aguardando ativação" % status.active_echoes)

# === BUFF APPLICATION HELPERS ===

func apply_test_buffs():
	"""Aplicar buffs de teste (para debug)"""
	BuffSystem.apply_buff("player", BuffSystem.BuffType.STRENGTH, 5, 3)
	BuffSystem.apply_buff("player", BuffSystem.BuffType.DEFENSE, 3, 2)
	BuffSystem.apply_buff("enemy", BuffSystem.BuffType.POISON, 2, 4)
	BuffSystem.apply_buff("enemy", BuffSystem.BuffType.WEAKNESS, 3, 2)
	_refresh_buff_indicators()
	print("🔮 Buffs de teste aplicados")

func apply_buff_from_card(target: String, buff_type: BuffSystem.BuffType, value: int, duration: int = 3):
	"""Aplicar buff através de carta"""
	BuffSystem.apply_buff(target, buff_type, value, duration)
	_refresh_buff_indicators()

# Exemplo de uso em cartas especiais:
func _apply_strength_potion():
	"""Carta especial: Poção de Força"""
	apply_buff_from_card("player", BuffSystem.BuffType.STRENGTH, 4, 3)
	print("🍶 Poção de Força aplicada: +4 Força por 3 turnos")

func _apply_poison_dagger():
	"""Carta especial: Adaga Envenenada"""
	apply_buff_from_card("enemy", BuffSystem.BuffType.POISON, 3, 5)
	print("🗡️ Adaga Envenenada: Inimigo envenenado por 5 turnos")

func _apply_shield_stance():
	"""Carta especial: Postura Defensiva"""
	apply_buff_from_card("player", BuffSystem.BuffType.DEFENSE, 2, 4)
	apply_buff_from_card("player", BuffSystem.BuffType.DEXTERITY, 3, 4)
	print("🛡️ Postura Defensiva: +2 Defesa e +3 Destreza por 4 turnos")

# === HELPER FUNCTIONS ===

func _get_current_enemy() -> Dictionary:
	"""Obter inimigo atual"""
	if active_enemies.is_empty() or current_enemy_index >= active_enemies.size():
		return {}
	return active_enemies[current_enemy_index]

func _on_enemy_defeated():
	"""Quando um inimigo é derrotado"""
	print("💀 Inimigo derrotado!")

	# Remover inimigo da lista
	if current_enemy_index < active_enemies.size():
		active_enemies.remove_at(current_enemy_index)

	# Verificar se há mais inimigos
	if active_enemies.is_empty():
		_on_all_enemies_defeated()
	else:
		# Ajustar índice se necessário
		if current_enemy_index >= active_enemies.size():
			current_enemy_index = 0
		_update_ui()

func _on_all_enemies_defeated():
	"""Quando todos os inimigos são derrotados"""
	print("🎉 Todos os inimigos derrotados!")
	_check_combat_end()

func _get_current_enemy_display_data() -> Dictionary:
	"""Obter dados do inimigo para display"""
	var enemy = _get_current_enemy()
	if enemy.is_empty():
		return {"hp": 0, "max_hp": 100, "shield": 0, "name": "Nenhum"}

	return {
		"hp": enemy["current_hp"],
		"max_hp": enemy["max_hp"],
		"shield": enemy.get("block", 0),
		"name": enemy["name"]
	}

func _apply_combat_theme():
	"""Apply RICH eldritch theme with heavy visual polish"""

	# ENEMY SECTION - Make it look intimidating
	var enemy_panel = $EnemyPanel
	if enemy_panel:
		_create_advanced_panel(enemy_panel, "enemy_combat")

	# PLAYER SECTION - Make it feel powerful
	var player_panel = $PlayerPanel
	if player_panel:
		_create_advanced_panel(player_panel, "player_combat")

	# CARDS SECTION - Make it feel mystical
	var cards_panel = $CardsPanel
	if cards_panel:
		_create_advanced_panel(cards_panel, "cards_mystical")

	# GAME INFO - Make it feel cosmic
	var game_info_panel = $GameInfoPanel
	if game_info_panel:
		_create_advanced_panel(game_info_panel, "cosmic_info")

	# Create ornate labels with decorations
	_enhance_combat_labels()

	# Create rich progress bars with glow effects
	_create_advanced_progress_bars()

	# Enhance back button dramatically
	_create_ornate_back_button()

	print("⚔️ RICH Eldritch Combat Theme Applied!")

func _create_advanced_panel(panel: Panel, style_type: String):
	"""Create visually rich panels with multiple layers"""
	var style_box = StyleBoxFlat.new()

	match style_type:
		"enemy_combat":
			# Dark crimson with pulsing border
			style_box.bg_color = Color(0.08, 0.02, 0.02, 0.95)
			style_box.border_color = Color(0.9, 0.2, 0.2, 1.0)
			style_box.border_width_left = 4
			style_box.border_width_right = 4
			style_box.border_width_top = 4
			style_box.border_width_bottom = 4

		"player_combat":
			# Deep blue-purple with golden accents
			style_box.bg_color = Color(0.05, 0.08, 0.15, 0.95)
			style_box.border_color = Color(0.8, 0.6, 1.0, 1.0)
			style_box.border_width_left = 4
			style_box.border_width_right = 4
			style_box.border_width_top = 4
			style_box.border_width_bottom = 4

		"cards_mystical":
			# Mystical void with eldritch borders
			style_box.bg_color = Color(0.02, 0.05, 0.1, 0.9)
			style_box.border_color = Color(0.4, 0.7, 0.9, 0.8)
			style_box.border_width_left = 3
			style_box.border_width_right = 3
			style_box.border_width_top = 3
			style_box.border_width_bottom = 3

		"cosmic_info":
			# Cosmic gold with shadow
			style_box.bg_color = Color(0.1, 0.08, 0.03, 0.92)
			style_box.border_color = Color(1.0, 0.8, 0.3, 0.9)
			style_box.border_width_left = 3
			style_box.border_width_right = 3
			style_box.border_width_top = 3
			style_box.border_width_bottom = 3

	# Enhanced corner styling
	style_box.corner_radius_top_left = 12
	style_box.corner_radius_top_right = 12
	style_box.corner_radius_bottom_left = 12
	style_box.corner_radius_bottom_right = 12

	# Add dramatic shadow
	style_box.shadow_color = Color(0.1, 0.1, 0.3, 0.8)
	style_box.shadow_size = 8
	style_box.shadow_offset = Vector2(4, 4)

	panel.add_theme_stylebox_override("panel", style_box)

func _enhance_combat_labels():
	"""Make labels look rich and ornate"""
	# Enemy labels - intimidating red
	var enemy_label = $EnemyPanel/EnemySection/EnemyLabel
	if enemy_label:
		_create_ornate_label(enemy_label, Color(1.0, 0.3, 0.3, 1.0), 20)

	# Player labels - heroic blue-gold
	var player_label = $PlayerPanel/PlayerSection/PlayerLabel
	if player_label:
		_create_ornate_label(player_label, Color(0.7, 0.8, 1.0, 1.0), 20)

	# Cards label - mystical cyan
	var cards_label = $CardsPanel/CardsSection/CardsLabel
	if cards_label:
		_create_ornate_label(cards_label, Color(0.4, 0.8, 1.0, 1.0), 18)

	# Battle title - cosmic gold
	var battle_title = $GameInfoPanel/GameInfo/BattleTitle
	if battle_title:
		_create_ornate_label(battle_title, Color(1.0, 0.9, 0.4, 1.0), 24)

func _create_ornate_label(label: Label, color: Color, size: int):
	"""Create rich label styling with glow effects"""
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)

	# Multiple shadow layers for glow effect
	label.add_theme_color_override("font_shadow_color", Color(color.r, color.g, color.b, 0.6))
	label.add_theme_constant_override("shadow_offset_x", 3)
	label.add_theme_constant_override("shadow_offset_y", 3)

func _create_advanced_progress_bars():
	"""Create visually stunning progress bars"""
	_enhance_progress_bar(enemy_hp_bar, "enemy_hp")
	_enhance_progress_bar(player_hp_bar, "player_hp")
	_enhance_progress_bar(energy_bar, "energy")

func _enhance_progress_bar(bar: ProgressBar, bar_type: String):
	"""Create rich progress bar with glow and ornate styling"""
	var bg_style = StyleBoxFlat.new()
	var fill_style = StyleBoxFlat.new()

	# Rich background
	bg_style.bg_color = Color(0.1, 0.1, 0.15, 0.9)
	bg_style.border_color = Color(0.3, 0.3, 0.4, 0.8)
	bg_style.border_width_left = 2
	bg_style.border_width_right = 2
	bg_style.border_width_top = 2
	bg_style.border_width_bottom = 2
	bg_style.corner_radius_top_left = 8
	bg_style.corner_radius_top_right = 8
	bg_style.corner_radius_bottom_left = 8
	bg_style.corner_radius_bottom_right = 8

	# Type-specific fill colors with glow
	match bar_type:
		"enemy_hp":
			fill_style.bg_color = Color(1.0, 0.2, 0.2, 0.9)  # Bright red
		"player_hp":
			fill_style.bg_color = Color(0.2, 0.8, 0.3, 0.9)  # Bright green
		"energy":
			fill_style.bg_color = Color(0.3, 0.6, 1.0, 0.9)  # Bright blue

	fill_style.corner_radius_top_left = 6
	fill_style.corner_radius_top_right = 6
	fill_style.corner_radius_bottom_left = 6
	fill_style.corner_radius_bottom_right = 6

	bar.add_theme_stylebox_override("background", bg_style)
	bar.add_theme_stylebox_override("fill", fill_style)

func _create_ornate_back_button():
	"""Make back button look dramatic and ornate"""
	var normal_style = StyleBoxFlat.new()
	var hover_style = StyleBoxFlat.new()
	var pressed_style = StyleBoxFlat.new()

	# Normal state - dark red with glow
	normal_style.bg_color = Color(0.2, 0.05, 0.05, 0.95)
	normal_style.border_color = Color(0.8, 0.2, 0.2, 1.0)
	_apply_ornate_button_styling(normal_style)

	# Hover state - bright red energy
	hover_style.bg_color = Color(0.4, 0.1, 0.1, 0.98)
	hover_style.border_color = Color(1.0, 0.4, 0.4, 1.0)
	_apply_ornate_button_styling(hover_style)

	# Pressed state - deep shadow
	pressed_style.bg_color = Color(0.1, 0.02, 0.02, 0.9)
	pressed_style.border_color = Color(0.6, 0.1, 0.1, 0.8)
	_apply_ornate_button_styling(pressed_style)

	back_btn.add_theme_stylebox_override("normal", normal_style)
	back_btn.add_theme_stylebox_override("hover", hover_style)
	back_btn.add_theme_stylebox_override("pressed", pressed_style)

	# Rich text styling
	back_btn.add_theme_color_override("font_color", Color(1.0, 0.8, 0.8, 1.0))
	back_btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	back_btn.add_theme_font_size_override("font_size", 16)

func _apply_ornate_button_styling(style_box: StyleBoxFlat):
	"""Apply rich ornate styling to buttons"""
	style_box.border_width_left = 3
	style_box.border_width_right = 3
	style_box.border_width_top = 3
	style_box.border_width_bottom = 3
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10

	# Dramatic shadow
	style_box.shadow_color = Color(0.2, 0.1, 0.2, 0.7)
	style_box.shadow_size = 6
	style_box.shadow_offset = Vector2(3, 3)

	print("⚔️ RICH Eldritch Combat Theme Applied!")
