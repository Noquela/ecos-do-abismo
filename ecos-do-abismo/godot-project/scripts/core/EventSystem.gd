# Sprint 13 - Sistema de Eventos
extends Node

# Tipos de eventos
enum EventType {
	NARRATIVE,
	CHOICE,
	RISK_REWARD,
	SPECIAL
}

# Pool de eventos disponíveis
func get_all_events() -> Array:
	"""Obter todos os eventos"""
	var events = []

	events.append_array(get_narrative_events())
	events.append_array(get_choice_events())
	events.append_array(get_risk_reward_events())
	events.append_array(get_special_events())

	return events

func get_narrative_events() -> Array:
	"""Eventos narrativos simples"""
	return [
		{
			"id": "ancient_shrine",
			"name": "Santuário Antigo",
			"type": EventType.NARRATIVE,
			"description": "Você encontra um santuário abandonado nas profundezas do abismo. Cristais místicos brilham fracamente nas paredes.",
			"image": "shrine",
			"choices": [
				{
					"text": "🙏 Rezar no santuário",
					"effect": {
						"type": "heal",
						"value": 10
					},
					"result_text": "Uma energia calorosa preenche seu corpo. Você se sente revigorado."
				},
				{
					"text": "💎 Examinar os cristais",
					"effect": {
						"type": "gold",
						"value": 15
					},
					"result_text": "Você encontra algumas moedas antigas entre os cristais."
				},
				{
					"text": "🚪 Seguir em frente",
					"effect": {
						"type": "none"
					},
					"result_text": "Você decide não mexer em nada e continua sua jornada."
				}
			]
		},
		{
			"id": "mysterious_merchant",
			"name": "Mercador Misterioso",
			"type": EventType.NARRATIVE,
			"description": "Uma figura encapuzada emerge das sombras, oferecendo uma troca inusitada.",
			"image": "merchant",
			"choices": [
				{
					"text": "💰 Trocar 20 moedas por HP",
					"cost": {"gold": 20},
					"effect": {
						"type": "heal",
						"value": 15
					},
					"result_text": "O mercador lhe dá uma poção curativa potente."
				},
				{
					"text": "❤️ Trocar 10 HP por moedas",
					"cost": {"hp": 10},
					"effect": {
						"type": "gold",
						"value": 30
					},
					"result_text": "O mercador extrai parte de sua força vital, mas lhe paga bem."
				},
				{
					"text": "🚶 Recusar a oferta",
					"effect": {
						"type": "none"
					},
					"result_text": "Você não confia no mercador e segue seu caminho."
				}
			]
		}
	]

func get_choice_events() -> Array:
	"""Eventos com escolhas estratégicas"""
	return [
		{
			"id": "cursed_chest",
			"name": "Baú Amaldiçoado",
			"type": EventType.CHOICE,
			"description": "Um baú ornamentado pulsa com energia sombria. Você pode sentir algo valioso dentro, mas também percebe o perigo.",
			"image": "cursed_chest",
			"choices": [
				{
					"text": "🗝️ Abrir o baú (Risco)",
					"effect": {
						"type": "random_choice",
						"options": [
							{
								"chance": 0.6,
								"effect": {"type": "gold", "value": 50},
								"result": "💰 Você encontra um tesouro valioso!"
							},
							{
								"chance": 0.4,
								"effect": {"type": "damage", "value": 15},
								"result": "💀 Uma maldição o atinge!"
							}
						]
					}
				},
				{
					"text": "🔍 Examinar cuidadosamente",
					"effect": {
						"type": "gold",
						"value": 20
					},
					"result_text": "Você encontra algumas moedas ao redor do baú sem ativá-lo."
				},
				{
					"text": "🏃 Fugir imediatamente",
					"effect": {
						"type": "none"
					},
					"result_text": "Você sente que fez a escolha certa ao evitar o baú."
				}
			]
		},
		{
			"id": "wounded_adventurer",
			"name": "Aventureiro Ferido",
			"type": EventType.CHOICE,
			"description": "Você encontra outro aventureiro gravemente ferido. Ele implora por ajuda, mas você tem recursos limitados.",
			"image": "wounded_adventurer",
			"choices": [
				{
					"text": "💚 Curar com sua poção",
					"cost": {"hp": 5},
					"effect": {
						"type": "card_reward",
						"value": "rare"
					},
					"result_text": "Grato, o aventureiro lhe ensina uma técnica especial."
				},
				{
					"text": "💰 Dar moedas para ele",
					"cost": {"gold": 25},
					"effect": {
						"type": "blessing",
						"value": "next_combat_bonus"
					},
					"result_text": "O aventureiro abençoa sua jornada."
				},
				{
					"text": "💔 Ignorar e seguir",
					"effect": {
						"type": "curse",
						"value": "guilt"
					},
					"result_text": "Você sente o peso da culpa em sua consciência."
				}
			]
		}
	]

func get_risk_reward_events() -> Array:
	"""Eventos de risco vs recompensa"""
	return [
		{
			"id": "unstable_portal",
			"name": "Portal Instável",
			"type": EventType.RISK_REWARD,
			"description": "Um portal mágico crepita com energia instável. Você pode vislumbrar tesouros do outro lado, mas a passagem parece perigosa.",
			"image": "portal",
			"choices": [
				{
					"text": "⚡ Entrar no portal (Alto risco)",
					"effect": {
						"type": "random_choice",
						"options": [
							{
								"chance": 0.3,
								"effect": {"type": "relic", "value": "rare"},
								"result": "✨ Você encontra uma relíquia poderosa!"
							},
							{
								"chance": 0.4,
								"effect": {"type": "gold", "value": 40},
								"result": "💰 Você encontra um tesouro!"
							},
							{
								"chance": 0.3,
								"effect": {"type": "damage", "value": 20},
								"result": "💥 O portal explode, causando danos!"
							}
						]
					}
				},
				{
					"text": "🤏 Tentar pegar algo rapidamente",
					"effect": {
						"type": "random_choice",
						"options": [
							{
								"chance": 0.7,
								"effect": {"type": "gold", "value": 15},
								"result": "💰 Você consegue algumas moedas."
							},
							{
								"chance": 0.3,
								"effect": {"type": "damage", "value": 8},
								"result": "⚡ Você leva um choque."
							}
						]
					}
				},
				{
					"text": "🚫 Evitar completamente",
					"effect": {
						"type": "none"
					},
					"result_text": "Você escolhe a segurança e continua seu caminho."
				}
			]
		}
	]

func get_special_events() -> Array:
	"""Eventos especiais únicos"""
	return [
		{
			"id": "mirror_of_souls",
			"name": "Espelho das Almas",
			"type": EventType.SPECIAL,
			"description": "Um espelho antigo reflete não sua aparência, mas a essência de sua alma. Você pode ver diferentes versões de si mesmo.",
			"image": "mirror",
			"choices": [
				{
					"text": "🔥 Abraçar sua natureza guerreira",
					"effect": {
						"type": "permanent_buff",
						"value": {"damage_bonus": 2}
					},
					"result_text": "Você sente sua força interior crescer permanentemente."
				},
				{
					"text": "🛡️ Abraçar sua natureza protetiva",
					"effect": {
						"type": "permanent_buff",
						"value": {"max_hp_bonus": 10}
					},
					"result_text": "Sua resistência interior se fortalece permanentemente."
				},
				{
					"text": "⚡ Abraçar sua natureza mágica",
					"effect": {
						"type": "permanent_buff",
						"value": {"energy_bonus": 1}
					},
					"result_text": "Sua conexão com a energia mística se aprofunda."
				},
				{
					"text": "💔 Quebrar o espelho",
					"effect": {
						"type": "random_choice",
						"options": [
							{
								"chance": 0.5,
								"effect": {"type": "gold", "value": 25},
								"result": "💎 Fragmentos valiosos caem do espelho."
							},
							{
								"chance": 0.5,
								"effect": {"type": "curse", "value": "bad_luck"},
								"result": "💀 Você sente que a má sorte o seguirá."
							}
						]
					}
				}
			]
		},
		{
			"id": "ancient_library",
			"name": "Biblioteca Antiga",
			"type": EventType.SPECIAL,
			"description": "Você encontra uma biblioteca há muito esquecida. Tomos antigos contêm conhecimentos perdidos.",
			"image": "library",
			"choices": [
				{
					"text": "📚 Estudar tomo de combate",
					"effect": {
						"type": "upgrade_random_attack_card"
					},
					"result_text": "Você aprende técnicas de combate avançadas."
				},
				{
					"text": "📖 Estudar tomo de defesa",
					"effect": {
						"type": "upgrade_random_defense_card"
					},
					"result_text": "Você aprende técnicas defensivas superiores."
				},
				{
					"text": "🔮 Estudar tomo místico",
					"effect": {
						"type": "transform_random_card"
					},
					"result_text": "Uma de suas cartas é transformada magicamente."
				},
				{
					"text": "💨 Sair rapidamente",
					"effect": {
						"type": "none"
					},
					"result_text": "Você decide não mexer com conhecimentos antigos."
				}
			]
		}
	]

func get_random_event(exclude_ids: Array = []) -> Dictionary:
	"""Obter evento aleatório"""
	var all_events = get_all_events()
	var available_events = []

	# Filtrar eventos já usados
	for event in all_events:
		if not exclude_ids.has(event.id):
			available_events.append(event)

	if available_events.size() > 0:
		return available_events[randi() % available_events.size()].duplicate(true)
	else:
		return {}

func get_event_by_id(event_id: String) -> Dictionary:
	"""Obter evento específico por ID"""
	var all_events = get_all_events()
	for event in all_events:
		if event.id == event_id:
			return event.duplicate(true)
	return {}

func apply_event_effect(effect: Dictionary, player_stats: Dictionary) -> Dictionary:
	"""Aplicar efeito de evento"""
	var result = {"success": true, "message": ""}

	match effect.type:
		"heal":
			RunManager.heal_player(effect.value)
			result.message = "💚 Curou %d HP" % effect.value

		"damage":
			var new_hp = RunManager.player_hp - effect.value
			RunManager.set_player_hp(new_hp)
			result.message = "💀 Perdeu %d HP" % effect.value

		"gold":
			GameData.add_coins(effect.value)
			result.message = "💰 Ganhou %d moedas" % effect.value

		"relic":
			match effect.value:
				"common":
					var relic = RelicSystem.get_random_relic(RelicSystem.RelicType.COMMON)
					RunManager.add_relic(relic)
					result.message = "💎 Ganhou relíquia: %s" % relic.name
				"rare":
					var relic = RelicSystem.get_random_relic(RelicSystem.RelicType.RARE)
					RunManager.add_relic(relic)
					result.message = "💎 Ganhou relíquia rara: %s" % relic.name

		"card_reward":
			# Implementar recompensa de carta baseada no valor
			result.message = "🃏 Ganhou uma nova carta!"

		"permanent_buff":
			# Aplicar buff permanente
			for stat in effect.value:
				GameData.upgrade_stat(stat, effect.value[stat])
			result.message = "✨ Buff permanente aplicado!"

		"none":
			result.message = "Nada aconteceu."

		"random_choice":
			# Implementar escolha aleatória baseada em chances
			var rand = randf()
			var cumulative_chance = 0.0

			for option in effect.options:
				cumulative_chance += option.chance
				if rand <= cumulative_chance:
					var _sub_result = apply_event_effect(option.effect, player_stats)
					result.message = option.result
					break

	return result

func can_afford_choice(choice: Dictionary) -> bool:
	"""Verificar se o jogador pode pagar o custo da escolha"""
	if not choice.has("cost"):
		return true

	var cost = choice.cost

	if cost.has("gold") and GameData.player_data.coins < cost.gold:
		return false

	if cost.has("hp") and RunManager.player_hp <= cost.hp:
		return false

	return true

func pay_choice_cost(choice: Dictionary):
	"""Pagar o custo da escolha"""
	if not choice.has("cost"):
		return

	var cost = choice.cost

	if cost.has("gold"):
		GameData.add_coins(-cost.gold)

	if cost.has("hp"):
		var new_hp = RunManager.player_hp - cost.hp
		RunManager.set_player_hp(new_hp)