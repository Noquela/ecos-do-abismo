# Sprint 12 - Sistema de Relíquias
extends Node

# Tipos de relíquias
enum RelicType {
	COMMON,
	RARE,
	BOSS
}

# Pool de relíquias disponíveis
func get_all_relics() -> Array:
	"""Obter todas as relíquias"""
	var relics = []

	relics.append_array(get_common_relics())
	relics.append_array(get_rare_relics())
	relics.append_array(get_boss_relics())

	return relics

func get_common_relics() -> Array:
	"""Relíquias comuns - drops de elites"""
	return [
		{
			"name": "Anel de Força",
			"type": RelicType.COMMON,
			"description": "Seus ataques causam +2 de dano",
			"effect": "damage_bonus",
			"value": 2
		},
		{
			"name": "Armadura Reforçada",
			"type": RelicType.COMMON,
			"description": "Ganha +3 de escudo no início de cada combate",
			"effect": "start_combat_shield",
			"value": 3
		},
		{
			"name": "Poção Energética",
			"type": RelicType.COMMON,
			"description": "Começa cada combate com +1 energia",
			"effect": "start_combat_energy",
			"value": 1
		},
		{
			"name": "Amuleto da Sorte",
			"type": RelicType.COMMON,
			"description": "Ganha +25% mais moedas em combates",
			"effect": "gold_bonus",
			"value": 0.25
		},
		{
			"name": "Cristal de Cura",
			"type": RelicType.COMMON,
			"description": "Cura 3 HP no final de cada combate não-boss",
			"effect": "post_combat_heal",
			"value": 3
		},
		{
			"name": "Lâmina Afiada",
			"type": RelicType.COMMON,
			"description": "O primeiro ataque de cada combate causa +5 dano",
			"effect": "first_attack_bonus",
			"value": 5
		}
	]

func get_rare_relics() -> Array:
	"""Relíquias raras - drops especiais"""
	return [
		{
			"name": "Coração de Dragão",
			"type": RelicType.RARE,
			"description": "Ganha +1 energia máxima permanentemente",
			"effect": "max_energy_bonus",
			"value": 1
		},
		{
			"name": "Escudo Místico",
			"type": RelicType.RARE,
			"description": "Ao final do turno, ganha escudo igual à energia não usada",
			"effect": "energy_to_shield",
			"value": 1
		},
		{
			"name": "Gema da Vida",
			"type": RelicType.RARE,
			"description": "Aumenta HP máximo em +15",
			"effect": "max_hp_bonus",
			"value": 15
		},
		{
			"name": "Medalhão do Berserker",
			"type": RelicType.RARE,
			"description": "Dano aumenta em +1 para cada 10 HP perdido",
			"effect": "low_hp_damage",
			"value": 1
		},
		{
			"name": "Orbe de Concentração",
			"type": RelicType.RARE,
			"description": "Cartas de custo 0 podem ser jogadas uma vez extra por turno",
			"effect": "free_card_extra_use",
			"value": 1
		},
		{
			"name": "Espelho Mágico",
			"type": RelicType.RARE,
			"description": "A primeira carta jogada a cada turno é duplicada",
			"effect": "duplicate_first_card",
			"value": 1
		},
		{
			"name": "Relógio de Areia",
			"type": RelicType.RARE,
			"description": "Desenha uma carta extra no início de cada turno",
			"effect": "extra_draw",
			"value": 1
		}
	]

func get_boss_relics() -> Array:
	"""Relíquias de boss - muito poderosas"""
	return [
		{
			"name": "Coroa do Imperador",
			"type": RelicType.BOSS,
			"description": "Ganha +1 energia máxima, mas perde 5 HP máximo",
			"effect": "energy_hp_trade",
			"value": 1
		},
		{
			"name": "Fragmento de Alma",
			"type": RelicType.BOSS,
			"description": "No início do combate, cura totalmente se HP < 50%",
			"effect": "emergency_heal",
			"value": 0.5
		},
		{
			"name": "Cajado do Mago",
			"type": RelicType.BOSS,
			"description": "Cartas não-ataque custam 1 energia a menos",
			"effect": "non_attack_discount",
			"value": 1
		},
		{
			"name": "Martelo do Titã",
			"type": RelicType.BOSS,
			"description": "Ataques custam 1 energia a mais, mas causam +8 dano",
			"effect": "attack_power_trade",
			"value": 8
		}
	]

func get_random_relic(relic_type: RelicType) -> Dictionary:
	"""Obter relíquia aleatória por tipo"""
	var relics_pool = []

	match relic_type:
		RelicType.COMMON:
			relics_pool = get_common_relics()
		RelicType.RARE:
			relics_pool = get_rare_relics()
		RelicType.BOSS:
			relics_pool = get_boss_relics()

	if relics_pool.size() > 0:
		return relics_pool[randi() % relics_pool.size()].duplicate()
	else:
		return {}

func get_relic_color(relic_type: RelicType) -> Color:
	"""Obter cor da relíquia por tipo"""
	match relic_type:
		RelicType.COMMON: return Color.SILVER
		RelicType.RARE: return Color.GOLD
		RelicType.BOSS: return Color.PURPLE
		_: return Color.WHITE

func get_relic_type_name(relic_type: RelicType) -> String:
	"""Obter nome do tipo de relíquia"""
	match relic_type:
		RelicType.COMMON: return "Comum"
		RelicType.RARE: return "Rara"
		RelicType.BOSS: return "Boss"
		_: return "Desconhecida"