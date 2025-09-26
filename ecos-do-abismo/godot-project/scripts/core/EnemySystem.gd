# Sprint 17 - Sistema de Inimigos e Intenções
extends Node

enum EnemyType {
	CULTISTA,      # Buffa outros inimigos, aplica debuffs
	JAW_WORM,      # Ganha força quando ataca
	RED_LOUSE,     # Aplica Weak ao morrer
	GREMLIN_NOB,   # Ganha força quando usa skills
	HEXAGHOST,     # Boss com múltiplas fases
	SLIME_BOSS,    # Boss que se divide
	SPIRE_GROWTH,  # Elite que cura e buffa
	BOOK_OF_STABBING # Elite que ataca mais forte com mais HP
}

enum EnemyIntent {
	ATTACK,        # Vai atacar
	DEFEND,        # Vai ganhar bloqueio
	BUFF,          # Vai se bufar
	DEBUFF,        # Vai debufar o jogador
	HEAL,          # Vai se curar
	UNKNOWN,       # Intenção desconhecida (primeiro turno)
	STUN,          # Vai tentar stunning
	MULTI_ATTACK   # Múltiplos ataques pequenos
}

const INTENT_DATA = {
	EnemyIntent.ATTACK: {
		"icon": "⚔️",
		"color": Color.RED,
		"description": "Vai atacar por {value} de dano"
	},
	EnemyIntent.DEFEND: {
		"icon": "🛡️",
		"color": Color.BLUE,
		"description": "Vai ganhar {value} de bloqueio"
	},
	EnemyIntent.BUFF: {
		"icon": "💪",
		"color": Color.GREEN,
		"description": "Vai se fortalecer"
	},
	EnemyIntent.DEBUFF: {
		"icon": "💔",
		"color": Color.PURPLE,
		"description": "Vai aplicar debuff"
	},
	EnemyIntent.HEAL: {
		"icon": "💚",
		"color": Color.CYAN,
		"description": "Vai se curar por {value} HP"
	},
	EnemyIntent.UNKNOWN: {
		"icon": "❓",
		"color": Color.GRAY,
		"description": "Intenção desconhecida"
	},
	EnemyIntent.STUN: {
		"icon": "💫",
		"color": Color.YELLOW,
		"description": "Vai tentar stunning"
	},
	EnemyIntent.MULTI_ATTACK: {
		"icon": "⚔️⚔️",
		"color": Color.ORANGE,
		"description": "Vai atacar {hits}x por {value} cada"
	}
}

const ENEMY_DATA = {
	EnemyType.CULTISTA: {
		"name": "Cultista",
		"base_hp": 48,
		"hp_scaling": 8,
		"behaviors": [
			{"intent": EnemyIntent.DEBUFF, "priority": 3, "cooldown": 3},
			{"intent": EnemyIntent.ATTACK, "priority": 2, "damage": 6},
			{"intent": EnemyIntent.BUFF, "priority": 1, "cooldown": 4}
		],
		"description": "Cultista que enfraquece e buffa ritualisticamente"
	},
	EnemyType.JAW_WORM: {
		"name": "Jaw Worm",
		"base_hp": 40,
		"hp_scaling": 5,
		"behaviors": [
			{"intent": EnemyIntent.ATTACK, "priority": 3, "damage": 11},
			{"intent": EnemyIntent.DEFEND, "priority": 1, "block": 6},
			{"intent": EnemyIntent.BUFF, "priority": 2, "strength": 3}
		],
		"passive": "ganha_forca_ao_atacar",
		"description": "Verme que fica mais forte a cada ataque"
	},
	EnemyType.RED_LOUSE: {
		"name": "Red Louse",
		"base_hp": 11,
		"hp_scaling": 3,
		"behaviors": [
			{"intent": EnemyIntent.ATTACK, "priority": 4, "damage": 5},
			{"intent": EnemyIntent.DEFEND, "priority": 1, "block": 4}
		],
		"death_effect": "apply_weakness",
		"description": "Piolho que enfraquece ao morrer"
	},
	EnemyType.GREMLIN_NOB: {
		"name": "Gremlin Nob",
		"base_hp": 82,
		"hp_scaling": 15,
		"behaviors": [
			{"intent": EnemyIntent.ATTACK, "priority": 4, "damage": 14},
			{"intent": EnemyIntent.MULTI_ATTACK, "priority": 2, "hits": 2, "damage": 8},
			{"intent": EnemyIntent.BUFF, "priority": 1, "strength": 2}
		],
		"passive": "odeia_skills",
		"description": "Elite que ganha força quando você usa skills"
	},
	EnemyType.HEXAGHOST: {
		"name": "Hexaghost",
		"base_hp": 250,
		"hp_scaling": 30,
		"is_boss": true,
		"phases": 3,
		"behaviors": [
			# Fase 1: Agressivo
			{"intent": EnemyIntent.ATTACK, "priority": 4, "damage": 18, "phase": 1},
			{"intent": EnemyIntent.MULTI_ATTACK, "priority": 3, "hits": 6, "damage": 4, "phase": 1},
			# Fase 2: Defensivo
			{"intent": EnemyIntent.DEFEND, "priority": 3, "block": 12, "phase": 2},
			{"intent": EnemyIntent.HEAL, "priority": 2, "heal": 20, "phase": 2},
			# Fase 3: Desesperado
			{"intent": EnemyIntent.ATTACK, "priority": 5, "damage": 45, "phase": 3}
		],
		"description": "Boss fantasma com múltiplas fases"
	}
}

var active_enemies := {}  # {enemy_id: enemy_data}
var turn_counter := 0

func _ready():
	print("👹 EnemySystem - Sprint 17: Sistema de intenções inicializado")

# === ENEMY CREATION ===

func create_enemy(enemy_type: EnemyType, enemy_id: String, floor_level: int = 1) -> Dictionary:
	"""Criar um inimigo com dados baseados no tipo e andar"""
	var enemy_template = ENEMY_DATA[enemy_type]
	var enemy = enemy_template.duplicate(true)

	# Calcular HP baseado no andar
	enemy.max_hp = enemy_template.base_hp + (floor_level * enemy_template.hp_scaling)
	enemy.current_hp = enemy.max_hp
	enemy.id = enemy_id
	enemy.type = enemy_type
	enemy.floor = floor_level

	# Estado do inimigo
	enemy.block = 0
	enemy.buffs = {}
	enemy.current_intent = EnemyIntent.UNKNOWN
	enemy.intent_value = 0
	enemy.intent_hits = 1
	enemy.behavior_cooldowns = {}
	enemy.last_behaviors = []
	enemy.phase = 1
	enemy.turns_alive = 0

	# Inicializar cooldowns
	for behavior in enemy.behaviors:
		if behavior.has("cooldown"):
			enemy.behavior_cooldowns[behavior.intent] = 0

	active_enemies[enemy_id] = enemy
	print("👹 Inimigo criado: %s (HP: %d)" % [enemy.name, enemy.max_hp])

	return enemy

func get_enemy(enemy_id: String) -> Dictionary:
	"""Obter dados de um inimigo"""
	return active_enemies.get(enemy_id, {})

func remove_enemy(enemy_id: String):
	"""Remover inimigo (quando morre)"""
	if active_enemies.has(enemy_id):
		var enemy = active_enemies[enemy_id]
		_trigger_death_effect(enemy)
		active_enemies.erase(enemy_id)
		print("💀 Inimigo removido: %s" % enemy.name)

# === INTENT SYSTEM ===

func calculate_intent(enemy_id: String) -> Dictionary:
	"""Calcular próxima intenção do inimigo"""
	var enemy = get_enemy(enemy_id)
	if enemy.is_empty():
		return {}

	enemy.turns_alive += 1

	# Atualizar fase para bosses
	if enemy.has("phases"):
		var hp_percent = float(enemy.current_hp) / float(enemy.max_hp)
		if hp_percent <= 0.33:
			enemy.phase = 3
		elif hp_percent <= 0.66:
			enemy.phase = 2
		else:
			enemy.phase = 1

	# Filtrar comportamentos disponíveis
	var available_behaviors = []
	for behavior in enemy.behaviors:
		# Verificar fase (para bosses)
		if behavior.has("phase") and behavior.phase != enemy.phase:
			continue

		# Verificar cooldown
		if behavior.has("cooldown"):
			var cooldown_key = behavior.intent
			if enemy.behavior_cooldowns.get(cooldown_key, 0) > 0:
				continue

		# Evitar repetir último comportamento
		if enemy.last_behaviors.size() > 0 and behavior.intent == enemy.last_behaviors[-1]:
			behavior.priority -= 1  # Reduzir prioridade temporariamente

		available_behaviors.append(behavior)

	# Escolher comportamento baseado em prioridade e randomização
	if available_behaviors.is_empty():
		return _create_intent_data(EnemyIntent.UNKNOWN, 0, 1)

	# Ordenar por prioridade (maior primeiro)
	available_behaviors.sort_custom(func(a, b): return a.priority > b.priority)

	# Pegar os comportamentos de maior prioridade
	var max_priority = available_behaviors[0].priority
	var top_behaviors = available_behaviors.filter(func(b): return b.priority == max_priority)

	# Escolher aleatoriamente entre os de maior prioridade
	var chosen_behavior = top_behaviors[randi() % top_behaviors.size()]

	# Aplicar cooldown
	if chosen_behavior.has("cooldown"):
		enemy.behavior_cooldowns[chosen_behavior.intent] = chosen_behavior.cooldown

	# Decrementar cooldowns
	for key in enemy.behavior_cooldowns.keys():
		enemy.behavior_cooldowns[key] = max(0, enemy.behavior_cooldowns[key] - 1)

	# Salvar último comportamento
	enemy.last_behaviors.append(chosen_behavior.intent)
	if enemy.last_behaviors.size() > 3:
		enemy.last_behaviors.pop_front()

	# Determinar valor da intenção
	var intent_value = 0
	var intent_hits = 1

	match chosen_behavior.intent:
		EnemyIntent.ATTACK:
			intent_value = chosen_behavior.damage
		EnemyIntent.DEFEND:
			intent_value = chosen_behavior.block
		EnemyIntent.HEAL:
			intent_value = chosen_behavior.heal
		EnemyIntent.MULTI_ATTACK:
			intent_value = chosen_behavior.damage
			intent_hits = chosen_behavior.hits
		EnemyIntent.BUFF:
			intent_value = chosen_behavior.get("strength", 2)
		EnemyIntent.DEBUFF:
			intent_value = chosen_behavior.get("weakness", 2)

	# Salvar intenção atual
	enemy.current_intent = chosen_behavior.intent
	enemy.intent_value = intent_value
	enemy.intent_hits = intent_hits

	return _create_intent_data(chosen_behavior.intent, intent_value, intent_hits)

func _create_intent_data(intent: EnemyIntent, value: int, hits: int = 1) -> Dictionary:
	"""Criar dados de intenção formatados"""
	var intent_info = INTENT_DATA[intent]
	var description = intent_info.description

	if intent == EnemyIntent.MULTI_ATTACK:
		description = description.format({"hits": hits, "value": value})
	else:
		description = description.format({"value": value})

	return {
		"intent": intent,
		"icon": intent_info.icon,
		"color": intent_info.color,
		"description": description,
		"value": value,
		"hits": hits
	}

# === INTENT EXECUTION ===

func execute_intent(enemy_id: String) -> Dictionary:
	"""Executar intenção do inimigo"""
	var enemy = get_enemy(enemy_id)
	if enemy.is_empty():
		return {"success": false, "message": "Inimigo não encontrado"}

	var result = {"success": true, "message": "", "effects": []}

	match enemy.current_intent:
		EnemyIntent.ATTACK:
			result = _execute_attack(enemy)
		EnemyIntent.DEFEND:
			result = _execute_defend(enemy)
		EnemyIntent.BUFF:
			result = _execute_buff(enemy)
		EnemyIntent.DEBUFF:
			result = _execute_debuff(enemy)
		EnemyIntent.HEAL:
			result = _execute_heal(enemy)
		EnemyIntent.MULTI_ATTACK:
			result = _execute_multi_attack(enemy)
		EnemyIntent.STUN:
			result = _execute_stun(enemy)
		_:
			result.message = "Inimigo hesita..."

	# Aplicar efeitos passivos
	_apply_passive_effects(enemy)

	print("👹 %s executou: %s" % [enemy.name, result.message])
	return result

func _execute_attack(enemy: Dictionary) -> Dictionary:
	"""Executar ataque simples"""
	var damage = enemy.intent_value
	# Aplicar modificadores de buff
	damage = BuffSystem.modify_damage_dealt(enemy.id, damage)

	# Aplicar passive do Jaw Worm
	if enemy.type == EnemyType.JAW_WORM:
		BuffSystem.apply_buff(enemy.id, BuffSystem.BuffType.STRENGTH, 3, -1)  # Permanente

	return {
		"success": true,
		"message": "%s atacou por %d de dano" % [enemy.name, damage],
		"effects": [{"type": "damage_player", "value": damage}]
	}

func _execute_multi_attack(enemy: Dictionary) -> Dictionary:
	"""Executar múltiplos ataques"""
	var damage_per_hit = enemy.intent_value
	var hits = enemy.intent_hits
	var total_damage = 0

	for i in range(hits):
		var hit_damage = BuffSystem.modify_damage_dealt(enemy.id, damage_per_hit)
		total_damage += hit_damage

	return {
		"success": true,
		"message": "%s atacou %dx por %d (%d total)" % [enemy.name, hits, damage_per_hit, total_damage],
		"effects": [{"type": "damage_player", "value": total_damage}]
	}

func _execute_defend(enemy: Dictionary) -> Dictionary:
	"""Executar defesa"""
	var block = enemy.intent_value
	block = BuffSystem.modify_block_gained(enemy.id, block)
	enemy.block += block

	return {
		"success": true,
		"message": "%s ganhou %d de bloqueio" % [enemy.name, block],
		"effects": []
	}

func _execute_buff(enemy: Dictionary) -> Dictionary:
	"""Executar auto-buff"""
	var strength = enemy.intent_value
	BuffSystem.apply_buff(enemy.id, BuffSystem.BuffType.STRENGTH, strength, 3)

	return {
		"success": true,
		"message": "%s ganhou +%d Força" % [enemy.name, strength],
		"effects": []
	}

func _execute_debuff(enemy: Dictionary) -> Dictionary:
	"""Executar debuff no jogador"""
	var weakness = enemy.intent_value
	BuffSystem.apply_buff("player", BuffSystem.BuffType.WEAKNESS, weakness, 2)

	return {
		"success": true,
		"message": "%s aplicou Fraqueza no jogador" % enemy.name,
		"effects": [{"type": "apply_debuff", "buff": BuffSystem.BuffType.WEAKNESS, "value": weakness}]
	}

func _execute_heal(enemy: Dictionary) -> Dictionary:
	"""Executar cura"""
	var heal = enemy.intent_value
	enemy.current_hp = min(enemy.max_hp, enemy.current_hp + heal)

	return {
		"success": true,
		"message": "%s se curou por %d HP" % [enemy.name, heal],
		"effects": []
	}

func _execute_stun(enemy: Dictionary) -> Dictionary:
	"""Executar stunning (remove energia do jogador)"""
	return {
		"success": true,
		"message": "%s tenta stunning" % enemy.name,
		"effects": [{"type": "lose_energy", "value": 1}]
	}

func _apply_passive_effects(enemy: Dictionary):
	"""Aplicar efeitos passivos específicos do inimigo"""
	match enemy.type:
		EnemyType.GREMLIN_NOB:
			# Passive: Odeia skills - ganha força quando jogador usa skill
			pass  # Será implementado no Combat.gd

func _trigger_death_effect(enemy: Dictionary):
	"""Aplicar efeito de morte do inimigo"""
	match enemy.type:
		EnemyType.RED_LOUSE:
			BuffSystem.apply_buff("player", BuffSystem.BuffType.WEAKNESS, 2, 2)
			print("💔 Red Louse aplicou Fraqueza ao morrer")

# === UTILITY FUNCTIONS ===

func get_intent_icon(intent: EnemyIntent) -> String:
	"""Obter ícone da intenção"""
	return INTENT_DATA[intent].icon

func get_intent_color(intent: EnemyIntent) -> Color:
	"""Obter cor da intenção"""
	return INTENT_DATA[intent].color

func get_all_active_enemies() -> Array:
	"""Obter lista de todos os inimigos ativos"""
	return active_enemies.values()

func damage_enemy(enemy_id: String, damage: int) -> bool:
	"""Aplicar dano a um inimigo"""
	var enemy = get_enemy(enemy_id)
	if enemy.is_empty():
		return false

	# Aplicar bloqueio primeiro
	if enemy.block > 0:
		var blocked = min(enemy.block, damage)
		enemy.block -= blocked
		damage -= blocked
		print("🛡️ %s bloqueou %d de dano" % [enemy.name, blocked])

	# Aplicar dano restante
	enemy.current_hp -= damage
	print("💔 %s recebeu %d de dano (HP: %d/%d)" % [enemy.name, damage, enemy.current_hp, enemy.max_hp])

	# Verificar morte
	if enemy.current_hp <= 0:
		remove_enemy(enemy_id)
		return true  # Inimigo morreu

	return false  # Inimigo ainda vivo

func heal_enemy(enemy_id: String, heal: int):
	"""Curar um inimigo"""
	var enemy = get_enemy(enemy_id)
	if enemy.is_empty():
		return

	enemy.current_hp = min(enemy.max_hp, enemy.current_hp + heal)
	print("💚 %s se curou por %d HP" % [enemy.name, heal])

# === ENCOUNTER GENERATION ===

func generate_encounter(floor_level: int, node_type: int) -> Array:
	"""Gerar encontro de inimigos baseado no andar e tipo de node"""
	var enemies = []

	match node_type:
		RunManager.NodeType.COMBAT:
			enemies = _generate_normal_encounter(floor_level)
		RunManager.NodeType.ELITE:
			enemies = _generate_elite_encounter(floor_level)
		RunManager.NodeType.BOSS:
			enemies = _generate_boss_encounter(floor_level)

	return enemies

func _generate_normal_encounter(floor_level: int) -> Array:
	"""Gerar encontro normal"""
	var encounters = [
		[EnemyType.CULTISTA],
		[EnemyType.RED_LOUSE, EnemyType.RED_LOUSE],
		[EnemyType.JAW_WORM],
		[EnemyType.CULTISTA, EnemyType.RED_LOUSE]
	]

	var chosen_encounter = encounters[randi() % encounters.size()]
	var enemies = []

	for i in range(chosen_encounter.size()):
		var enemy_type = chosen_encounter[i]
		var enemy_id = "enemy_%d" % i
		enemies.append(create_enemy(enemy_type, enemy_id, floor_level))

	return enemies

func _generate_elite_encounter(floor_level: int) -> Array:
	"""Gerar encontro elite"""
	var elite_types = [EnemyType.GREMLIN_NOB]
	var chosen_type = elite_types[randi() % elite_types.size()]

	return [create_enemy(chosen_type, "elite_0", floor_level)]

func _generate_boss_encounter(floor_level: int) -> Array:
	"""Gerar encontro de boss"""
	var boss_types = [EnemyType.HEXAGHOST]
	var chosen_type = boss_types[randi() % boss_types.size()]

	return [create_enemy(chosen_type, "boss_0", floor_level)]

# === DEBUG ===

func debug_print_enemy_state(enemy_id: String):
	"""Debug: imprimir estado completo do inimigo"""
	var enemy = get_enemy(enemy_id)
	if enemy.is_empty():
		return

	print("👹 === %s ===" % enemy.name)
	print("  HP: %d/%d" % [enemy.current_hp, enemy.max_hp])
	print("  Bloqueio: %d" % enemy.block)
	print("  Intenção: %s (%d)" % [INTENT_DATA[enemy.current_intent].icon, enemy.intent_value])
	print("  Fase: %d" % enemy.phase)
	print("  Turnos vivo: %d" % enemy.turns_alive)
	BuffSystem.debug_print_all_buffs()  # Mostrar buffs também