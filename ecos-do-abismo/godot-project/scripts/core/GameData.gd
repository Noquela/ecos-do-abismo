# Sprint 5 - Sistema de progressão global
extends Node

# Dados persistentes do jogador
var player_level = 1
var player_xp = 0
var player_coins = 50
var total_victories = 0
var current_streak = 0
var best_streak = 0

# Cartas desbloqueadas (índices das cartas disponíveis)
var unlocked_cards = [0, 1, 2, 3]  # Começa com 4 cartas básicas

# Upgrades permanentes
var permanent_upgrades = {
	"max_hp_bonus": 0,
	"starting_energy_bonus": 0,
	"cards_per_turn_bonus": 0,
	"damage_bonus": 0
}

func _ready():
	print("💾 GameData inicializado")
	load_game()

# Sistema de XP e Level
func add_xp(amount: int):
	player_xp += amount
	print("⭐ +%d XP (Total: %d)" % [amount, player_xp])

	var xp_needed = get_xp_for_next_level()
	while player_xp >= xp_needed:
		level_up()
		xp_needed = get_xp_for_next_level()

func get_xp_for_next_level() -> int:
	return player_level * 100 + (player_level - 1) * 25

func level_up():
	player_level += 1
	player_xp -= get_xp_for_next_level()
	print("🎉 LEVEL UP! Nível %d" % player_level)

	# Unlock cartas por nível
	match player_level:
		2:
			unlock_card(4)  # Combo
		3:
			unlock_card(5)  # Foco
		4:
			unlock_card(6)  # Devastar
		5:
			unlock_card(7)  # Regenerar

func unlock_card(card_index: int):
	if card_index not in unlocked_cards:
		unlocked_cards.append(card_index)
		print("🆕 Nova carta desbloqueada!")

# Sistema de moedas
func add_coins(amount: int):
	player_coins += amount
	print("💰 +%d moedas (Total: %d)" % [amount, player_coins])

func spend_coins(amount: int) -> bool:
	if player_coins >= amount:
		player_coins -= amount
		print("💸 -%d moedas (Restam: %d)" % [amount, player_coins])
		return true
	return false

# Upgrades permanentes
func buy_upgrade(upgrade_type: String, cost: int) -> bool:
	if spend_coins(cost):
		match upgrade_type:
			"max_hp":
				permanent_upgrades.max_hp_bonus += 10
			"starting_energy":
				permanent_upgrades.starting_energy_bonus += 1
			"damage":
				permanent_upgrades.damage_bonus += 2
		print("🔧 Upgrade comprado: %s" % upgrade_type)
		return true
	return false

# Registrar vitória
func register_victory():
	total_victories += 1
	current_streak += 1
	if current_streak > best_streak:
		best_streak = current_streak

	# XP baseado na streak (melhor balanceamento)
	var xp_reward = 30 + (current_streak * 8)
	add_xp(xp_reward)

	# Moedas baseadas no level e streak
	var coin_reward = 15 + (player_level * 3) + (current_streak * 2)
	add_coins(coin_reward)

func register_defeat():
	current_streak = 0
	print("💀 Streak perdida")

# Sistema de save/load
func save_game():
	var save_data = {
		"player_level": player_level,
		"player_xp": player_xp,
		"player_coins": player_coins,
		"total_victories": total_victories,
		"current_streak": current_streak,
		"best_streak": best_streak,
		"unlocked_cards": unlocked_cards,
		"permanent_upgrades": permanent_upgrades
	}

	var file = FileAccess.open("user://ecos_save.dat", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("💾 Jogo salvo")

func load_game():
	var file = FileAccess.open("user://ecos_save.dat", FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()

		player_level = save_data.get("player_level", 1)
		player_xp = save_data.get("player_xp", 0)
		player_coins = save_data.get("player_coins", 50)
		total_victories = save_data.get("total_victories", 0)
		current_streak = save_data.get("current_streak", 0)
		best_streak = save_data.get("best_streak", 0)
		unlocked_cards = save_data.get("unlocked_cards", [0, 1, 2, 3])
		permanent_upgrades = save_data.get("permanent_upgrades", {
			"max_hp_bonus": 0,
			"starting_energy_bonus": 0,
			"cards_per_turn_bonus": 0,
			"damage_bonus": 0
		})

		print("📂 Progresso carregado - Nível %d" % player_level)

func get_available_cards() -> Array:
	"""Retorna apenas cartas desbloqueadas"""
	var all_cards = [
		{"name": "Ataque", "cost": 1, "damage": 10, "type": "attack", "artwork": "res://assets/generated/cards/card_attack_golpe.png", "description": "Inflige {damage} de dano sombrio"},
		{"name": "Golpe Forte", "cost": 3, "damage": 18, "type": "attack", "artwork": "res://assets/generated/cards/card_attack_raio.png", "description": "Um golpe poderoso que inflige {damage} de dano"},
		{"name": "Cura", "cost": 2, "heal": 15, "type": "heal", "artwork": "res://assets/generated/cards/card_heal_pocao.png", "description": "Restaura {heal} pontos de vida"},
		{"name": "Defesa", "cost": 1, "shield": 8, "type": "defense", "artwork": "res://assets/generated/cards/card_defense_escudo.png", "description": "Ganha {shield} pontos de escudo"},
		{"name": "Combo", "cost": 2, "damage": 12, "energy": 1, "type": "combo", "artwork": "res://assets/generated/cards/card_corruption_maldicao.png", "description": "Inflige {damage} dano e ganha {energy} energia"},
		{"name": "Foco", "cost": 1, "energy": 2, "type": "energy", "artwork": "res://assets/generated/cards/card_echo_memoria.png", "description": "Ganha {energy} pontos de energia"},
		{"name": "Devastar", "cost": 4, "damage": 25, "type": "attack", "artwork": "res://assets/generated/cards/card_corruption_sombra.png", "description": "Um ataque devastador que inflige {damage} de dano"},
		{"name": "Regenerar", "cost": 3, "heal": 20, "shield": 5, "type": "heal", "artwork": "res://assets/generated/cards/card_heal_regeneracao.png", "description": "Restaura {heal} vida e ganha {shield} escudo"}
	]

	var available = []
	for index in unlocked_cards:
		if index < all_cards.size():
			available.append(all_cards[index])

	return available

func get_player_stats() -> Dictionary:
	return {
		"level": player_level,
		"xp": player_xp,
		"xp_needed": get_xp_for_next_level(),
		"coins": player_coins,
		"victories": total_victories,
		"current_streak": current_streak,
		"best_streak": best_streak,
		"max_hp": 100 + permanent_upgrades.max_hp_bonus,
		"starting_energy": 4 + permanent_upgrades.starting_energy_bonus,
		"damage_bonus": permanent_upgrades.damage_bonus
	}