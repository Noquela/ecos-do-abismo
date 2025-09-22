# Sprint 11 - Pool de Cartas para Draft
extends Node

# Pool expandido de cartas para draft
enum Rarity {
	COMMON,
	UNCOMMON,
	RARE
}

func get_all_draftable_cards() -> Array:
	"""Obter todas as cartas disponíveis para draft"""
	var cards = []

	# Adicionar todas as cartas por categoria
	cards.append_array(get_attack_cards())
	cards.append_array(get_defense_cards())
	cards.append_array(get_skill_cards())
	cards.append_array(get_power_cards())

	return cards

func get_attack_cards() -> Array:
	"""Cartas de ataque"""
	return [
		# COMUM
		{
			"name": "Golpe",
			"type": "attack",
			"cost": 1,
			"damage": 6,
			"rarity": Rarity.COMMON,
			"description": "Causa 6 de dano"
		},
		{
			"name": "Pancada",
			"type": "attack",
			"cost": 2,
			"damage": 12,
			"rarity": Rarity.COMMON,
			"description": "Causa 12 de dano"
		},
		{
			"name": "Golpe Duplo",
			"type": "attack",
			"cost": 1,
			"damage": 3,
			"hits": 2,
			"rarity": Rarity.COMMON,
			"description": "Causa 3 de dano 2 vezes"
		},

		# INCOMUM
		{
			"name": "Corte Feroz",
			"type": "attack",
			"cost": 1,
			"damage": 8,
			"rarity": Rarity.UNCOMMON,
			"description": "Causa 8 de dano"
		},
		{
			"name": "Devastar",
			"type": "attack",
			"cost": 3,
			"damage": 18,
			"rarity": Rarity.UNCOMMON,
			"description": "Causa 18 de dano"
		},
		{
			"name": "Corte Giratório",
			"type": "attack",
			"cost": 2,
			"damage": 5,
			"hits": 3,
			"rarity": Rarity.UNCOMMON,
			"description": "Causa 5 de dano 3 vezes"
		},

		# RARO
		{
			"name": "Golpe Letal",
			"type": "attack",
			"cost": 2,
			"damage": 20,
			"rarity": Rarity.RARE,
			"description": "Causa 20 de dano"
		},
		{
			"name": "Fúria Berserker",
			"type": "attack",
			"cost": 3,
			"damage": 8,
			"hits": 4,
			"rarity": Rarity.RARE,
			"description": "Causa 8 de dano 4 vezes"
		}
	]

func get_defense_cards() -> Array:
	"""Cartas de defesa"""
	return [
		# COMUM
		{
			"name": "Bloqueio",
			"type": "defense",
			"cost": 1,
			"shield": 5,
			"rarity": Rarity.COMMON,
			"description": "Ganha 5 de escudo"
		},
		{
			"name": "Defesa",
			"type": "defense",
			"cost": 2,
			"shield": 12,
			"rarity": Rarity.COMMON,
			"description": "Ganha 12 de escudo"
		},

		# INCOMUM
		{
			"name": "Escudo de Ferro",
			"type": "defense",
			"cost": 1,
			"shield": 8,
			"rarity": Rarity.UNCOMMON,
			"description": "Ganha 8 de escudo"
		},
		{
			"name": "Fortaleza",
			"type": "defense",
			"cost": 3,
			"shield": 20,
			"rarity": Rarity.UNCOMMON,
			"description": "Ganha 20 de escudo"
		},

		# RARO
		{
			"name": "Muralha Impenetrável",
			"type": "defense",
			"cost": 2,
			"shield": 15,
			"rarity": Rarity.RARE,
			"description": "Ganha 15 de escudo"
		}
	]

func get_skill_cards() -> Array:
	"""Cartas de habilidade"""
	return [
		# COMUM
		{
			"name": "Poção",
			"type": "heal",
			"cost": 1,
			"heal": 5,
			"rarity": Rarity.COMMON,
			"description": "Cura 5 HP"
		},
		{
			"name": "Energia Extra",
			"type": "energy",
			"cost": 0,
			"energy": 2,
			"rarity": Rarity.COMMON,
			"description": "Ganha 2 de energia"
		},

		# INCOMUM
		{
			"name": "Regeneração",
			"type": "heal",
			"cost": 2,
			"heal": 10,
			"rarity": Rarity.UNCOMMON,
			"description": "Cura 10 HP"
		},
		{
			"name": "Concentração",
			"type": "energy",
			"cost": 1,
			"energy": 3,
			"rarity": Rarity.UNCOMMON,
			"description": "Ganha 3 de energia"
		},
		{
			"name": "Preparação",
			"type": "skill",
			"cost": 1,
			"draw_cards": 2,
			"rarity": Rarity.UNCOMMON,
			"description": "Compra 2 cartas"
		},

		# RARO
		{
			"name": "Cura Divina",
			"type": "heal",
			"cost": 2,
			"heal": 18,
			"rarity": Rarity.RARE,
			"description": "Cura 18 HP"
		},
		{
			"name": "Explosão de Energia",
			"type": "energy",
			"cost": 0,
			"energy": 4,
			"rarity": Rarity.RARE,
			"description": "Ganha 4 de energia"
		}
	]

func get_power_cards() -> Array:
	"""Cartas de poder (modificadores persistentes)"""
	return [
		# INCOMUM
		{
			"name": "Força Interior",
			"type": "power",
			"cost": 1,
			"damage_bonus": 2,
			"rarity": Rarity.UNCOMMON,
			"description": "Aumenta dano de ataques em 2 pelo resto do combate"
		},
		{
			"name": "Armadura Resistente",
			"type": "power",
			"cost": 2,
			"shield_bonus": 3,
			"rarity": Rarity.UNCOMMON,
			"description": "Aumenta escudo em 3 pelo resto do combate"
		},

		# RARO
		{
			"name": "Fúria de Batalha",
			"type": "power",
			"cost": 2,
			"damage_bonus": 4,
			"rarity": Rarity.RARE,
			"description": "Aumenta dano de ataques em 4 pelo resto do combate"
		},
		{
			"name": "Maestria Energética",
			"type": "power",
			"cost": 1,
			"energy_bonus": 1,
			"rarity": Rarity.RARE,
			"description": "Ganha +1 energia por turno pelo resto do combate"
		}
	]

func get_cards_by_rarity(rarity: Rarity) -> Array:
	"""Obter cartas por raridade"""
	var all_cards = get_all_draftable_cards()
	var filtered_cards = []

	for card in all_cards:
		if card.rarity == rarity:
			filtered_cards.append(card)

	return filtered_cards

func get_random_draft_options(count: int = 3) -> Array:
	"""Gerar opções aleatórias para draft"""
	var options = []

	# Probabilidades por raridade
	var rarity_weights = {
		Rarity.COMMON: 0.7,    # 70%
		Rarity.UNCOMMON: 0.25, # 25%
		Rarity.RARE: 0.05      # 5%
	}

	for i in range(count):
		var rand = randf()
		var chosen_rarity = Rarity.COMMON

		if rand <= rarity_weights[Rarity.RARE]:
			chosen_rarity = Rarity.RARE
		elif rand <= rarity_weights[Rarity.RARE] + rarity_weights[Rarity.UNCOMMON]:
			chosen_rarity = Rarity.UNCOMMON
		else:
			chosen_rarity = Rarity.COMMON

		var rarity_cards = get_cards_by_rarity(chosen_rarity)
		if rarity_cards.size() > 0:
			var random_card = rarity_cards[randi() % rarity_cards.size()]
			options.append(random_card.duplicate())

	return options

func get_rarity_name(rarity: Rarity) -> String:
	"""Obter nome da raridade"""
	match rarity:
		Rarity.COMMON: return "Comum"
		Rarity.UNCOMMON: return "Incomum"
		Rarity.RARE: return "Raro"
		_: return "Desconhecido"

func get_rarity_color(rarity: Rarity) -> Color:
	"""Obter cor da raridade"""
	match rarity:
		Rarity.COMMON: return Color.WHITE
		Rarity.UNCOMMON: return Color.CYAN
		Rarity.RARE: return Color.GOLD
		_: return Color.GRAY

func get_random_shop_card() -> Dictionary:
	"""Obter carta aleatória para a loja"""
	var all_cards = get_all_draftable_cards()

	# Probabilidades baseadas na raridade
	var rand = randf()
	var filtered_cards = []

	if rand < 0.6:  # 60% chance de comum
		filtered_cards = all_cards.filter(func(card): return card.rarity == Rarity.COMMON)
	elif rand < 0.85:  # 25% chance de incomum
		filtered_cards = all_cards.filter(func(card): return card.rarity == Rarity.UNCOMMON)
	else:  # 15% chance de rara
		filtered_cards = all_cards.filter(func(card): return card.rarity == Rarity.RARE)

	# Fallback para qualquer carta se não houver da raridade desejada
	if filtered_cards.is_empty():
		filtered_cards = all_cards

	return filtered_cards[randi() % filtered_cards.size()].duplicate()