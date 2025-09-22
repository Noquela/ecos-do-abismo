# Protótipo Mínimo - Sistema de Combate
# Validar mecânicas principais e progressão

extends Control

@onready var player_hp_label = $TopBar/PlayerHP
@onready var player_willpower_label = $TopBar/PlayerWillpower
@onready var energy_label = $TopBar/Energy

@onready var enemy_hp_label = $CombatArea/EnemyInfo/HPLabel
@onready var enemy_status_label = $CombatArea/EnemyInfo/StatusLabel

@onready var hand_container = $HandArea/HandContainer
@onready var end_turn_btn = $HandArea/EndTurnButton
@onready var menu_btn = $TopBar/MenuButton

# Estado do combate
var combat_data = {
	"player_hp": 80,
	"player_max_hp": 100,
	"player_willpower": 60,
	"player_max_willpower": 100,
	"player_energy": 5,
	"player_max_energy": 5,

	"enemy_hp": 50,
	"enemy_max_hp": 50,
	"enemy_name": "Cultista Sombrio",
	"enemy_attack": 15,

	"turn_count": 1,
	"player_turn": true
}

# Cartas na mão (simulado)
var hand_cards = [
	{"name": "Ataque Básico", "cost": 2, "damage": 15, "type": "attack"},
	{"name": "Cura Rápida", "cost": 3, "heal": 20, "type": "heal"},
	{"name": "Escudo", "cost": 1, "defense": 10, "type": "defense"},
	{"name": "Golpe Forte", "cost": 4, "damage": 25, "type": "attack"},
	{"name": "Foco Mental", "cost": 2, "willpower": 15, "type": "buff"}
]

func _ready():
	# Conectar botões
	end_turn_btn.pressed.connect(_on_end_turn_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)

	# Inicializar combate
	_start_combat()

func _start_combat():
	print("⚔️ INICIANDO COMBATE")
	print("   Inimigo: %s (HP: %d)" % [combat_data.enemy_name, combat_data.enemy_hp])

	_update_ui()
	_create_hand_cards()

func _update_ui():
	# Atualizar status do jogador
	player_hp_label.text = "HP: %d/%d" % [combat_data.player_hp, combat_data.player_max_hp]
	player_willpower_label.text = "Vontade: %d/%d" % [combat_data.player_willpower, combat_data.player_max_willpower]
	energy_label.text = "Energia: %d/%d" % [combat_data.player_energy, combat_data.player_max_energy]

	# Atualizar inimigo
	enemy_hp_label.text = "%s\nHP: %d/%d" % [combat_data.enemy_name, combat_data.enemy_hp, combat_data.enemy_max_hp]
	enemy_status_label.text = "ATK: %d" % combat_data.enemy_attack

	# Habilitar/desabilitar botão de turno
	end_turn_btn.disabled = not combat_data.player_turn

func _create_hand_cards():
	# Limpar mão anterior
	for child in hand_container.get_children():
		child.queue_free()

	# Criar botões para cada carta
	for i in range(hand_cards.size()):
		var card = hand_cards[i]
		var btn = Button.new()
		btn.text = "%s\nCusto: %d" % [card.name, card.cost]
		btn.custom_minimum_size = Vector2(100, 80)

		# Conectar sinal com índice da carta
		btn.pressed.connect(_on_card_played.bind(i))

		# Desabilitar se não tem energia suficiente
		if card.cost > combat_data.player_energy:
			btn.disabled = true
			btn.modulate = Color.GRAY

		hand_container.add_child(btn)

func _on_card_played(card_index: int):
	var card = hand_cards[card_index]

	# Verificar se tem energia
	if card.cost > combat_data.player_energy:
		print("❌ Energia insuficiente para jogar %s" % card.name)
		return

	# Gastar energia
	combat_data.player_energy -= card.cost

	print("🃏 CARTA JOGADA: %s" % card.name)

	# Aplicar efeito da carta
	match card.type:
		"attack":
			_deal_damage_to_enemy(card.damage)
		"heal":
			_heal_player(card.heal)
		"defense":
			print("   🛡 Defesa aumentada em %d" % card.defense)
		"buff":
			_restore_willpower(card.willpower)

	# Remover carta da mão
	hand_cards.remove_at(card_index)

	# Atualizar UI
	_update_ui()
	_create_hand_cards()

	# Verificar condições de vitória/derrota
	_check_combat_end()

func _deal_damage_to_enemy(damage: int):
	combat_data.enemy_hp -= damage
	combat_data.enemy_hp = max(0, combat_data.enemy_hp)
	print("   ⚔️ Dano causado: %d (HP inimigo: %d)" % [damage, combat_data.enemy_hp])

func _heal_player(amount: int):
	combat_data.player_hp += amount
	combat_data.player_hp = min(combat_data.player_max_hp, combat_data.player_hp)
	print("   💚 HP restaurado: %d (HP atual: %d)" % [amount, combat_data.player_hp])

func _restore_willpower(amount: int):
	combat_data.player_willpower += amount
	combat_data.player_willpower = min(combat_data.player_max_willpower, combat_data.player_willpower)
	print("   🧠 Vontade restaurada: %d (Vontade atual: %d)" % [amount, combat_data.player_willpower])

func _on_end_turn_pressed():
	if not combat_data.player_turn:
		return

	print("🔄 FIM DO TURNO DO JOGADOR")

	# Turno do inimigo
	combat_data.player_turn = false
	_enemy_turn()

func _enemy_turn():
	print("👹 TURNO DO INIMIGO")

	# IA simples: sempre ataca
	var damage = combat_data.enemy_attack
	combat_data.player_hp -= damage
	combat_data.player_hp = max(0, combat_data.player_hp)

	print("   💥 Inimigo ataca! Dano: %d (HP jogador: %d)" % [damage, combat_data.player_hp])

	# Verificar se jogador morreu
	if combat_data.player_hp <= 0:
		_game_over()
		return

	# Próximo turno do jogador
	await get_tree().create_timer(1.5).timeout
	_start_player_turn()

func _start_player_turn():
	print("🎮 TURNO DO JOGADOR")

	combat_data.player_turn = true
	combat_data.turn_count += 1

	# Restaurar energia
	combat_data.player_energy = combat_data.player_max_energy

	# Comprar novas cartas (simplificado)
	if hand_cards.size() < 5:
		_draw_cards()

	_update_ui()
	_create_hand_cards()

func _draw_cards():
	# Cartas disponíveis para comprar
	var available_cards = [
		{"name": "Golpe Rápido", "cost": 1, "damage": 8, "type": "attack"},
		{"name": "Concentração", "cost": 1, "willpower": 10, "type": "buff"},
		{"name": "Ataque Duplo", "cost": 3, "damage": 12, "type": "attack"}
	]

	# Adicionar carta aleatória
	var new_card = available_cards[randi() % available_cards.size()]
	hand_cards.append(new_card)
	print("   📥 Nova carta: %s" % new_card.name)

func _check_combat_end():
	if combat_data.enemy_hp <= 0:
		_victory()
	elif combat_data.player_hp <= 0:
		_game_over()

func _victory():
	print("🎉 VITÓRIA!")
	print("   Turnos utilizados: %d" % combat_data.turn_count)

	# Calcular recompensas
	var base_xp = 100
	var base_coins = 50
	var bonus_xp = max(0, (10 - combat_data.turn_count) * 10)  # Bonus por rapidez

	print("   Recompensas:")
	print("   💰 Moedas: %d" % base_coins)
	print("   ⭐ XP: %d (Bonus: %d)" % [base_xp, bonus_xp])

	# Simular próximo combate com dificuldade aumentada
	await get_tree().create_timer(2.0).timeout
	_next_combat()

func _next_combat():
	print("🔄 PRÓXIMO COMBATE")

	# Aumentar dificuldade
	combat_data.enemy_hp = int(combat_data.enemy_max_hp * 1.2)
	combat_data.enemy_max_hp = combat_data.enemy_hp
	combat_data.enemy_attack = int(combat_data.enemy_attack * 1.1)
	combat_data.enemy_name = "Cultista Veterano"

	print("   ⚡ Dificuldade aumentada!")
	print("   Novo inimigo: %s (HP: %d, ATK: %d)" % [combat_data.enemy_name, combat_data.enemy_hp, combat_data.enemy_attack])

	# Resetar estado do combate
	combat_data.turn_count = 1
	combat_data.player_turn = true
	combat_data.player_energy = combat_data.player_max_energy

	# Curar parcialmente o jogador
	combat_data.player_hp = min(combat_data.player_max_hp, combat_data.player_hp + 20)

	_update_ui()
	_create_hand_cards()

func _game_over():
	print("💀 GAME OVER")
	print("   Turnos sobrevividos: %d" % combat_data.turn_count)

	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://prototype/main_menu_prototype.tscn")

func _on_menu_pressed():
	print("📋 MENU PAUSADO")
	get_tree().change_scene_to_file("res://prototype/player_hub_prototype.tscn")