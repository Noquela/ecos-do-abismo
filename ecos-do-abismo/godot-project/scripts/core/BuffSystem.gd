# Sprint 16 - Sistema de Buffs Temporários
extends Node

enum BuffType {
	STRENGTH,      # +Dano de ataque
	DEFENSE,       # +Defesa/Bloqueio
	ENERGY,        # +Energia por turno
	REGENERATION,  # +HP por turno
	POISON,        # -HP por turno
	WEAKNESS,      # -Dano de ataque
	VULNERABLE,    # +Dano recebido
	DEXTERITY,     # +Bloqueio
	FOCUS,         # +Orb effects
	RITUAL         # +Mana por turno
}

const BUFF_DATA = {
	BuffType.STRENGTH: {
		"name": "Força",
		"icon": "💪",
		"description": "Aumenta o dano de ataques em {value}",
		"color": Color.RED,
		"is_positive": true
	},
	BuffType.DEFENSE: {
		"name": "Defesa",
		"icon": "🛡️",
		"description": "Aumenta a defesa em {value}",
		"color": Color.BLUE,
		"is_positive": true
	},
	BuffType.ENERGY: {
		"name": "Energia",
		"icon": "⚡",
		"description": "Ganha {value} energia adicional por turno",
		"color": Color.YELLOW,
		"is_positive": true
	},
	BuffType.REGENERATION: {
		"name": "Regeneração",
		"icon": "💚",
		"description": "Recupera {value} HP por turno",
		"color": Color.GREEN,
		"is_positive": true
	},
	BuffType.POISON: {
		"name": "Veneno",
		"icon": "☠️",
		"description": "Perde {value} HP por turno",
		"color": Color.PURPLE,
		"is_positive": false
	},
	BuffType.WEAKNESS: {
		"name": "Fraqueza",
		"icon": "💔",
		"description": "Reduz o dano de ataques em {value}",
		"color": Color.ORANGE,
		"is_positive": false
	},
	BuffType.VULNERABLE: {
		"name": "Vulnerável",
		"icon": "🎯",
		"description": "Recebe {value}% mais dano",
		"color": Color.MAGENTA,
		"is_positive": false
	},
	BuffType.DEXTERITY: {
		"name": "Destreza",
		"icon": "🤸",
		"description": "Aumenta o bloqueio em {value}",
		"color": Color.CYAN,
		"is_positive": true
	},
	BuffType.FOCUS: {
		"name": "Foco",
		"icon": "🔮",
		"description": "Aumenta efeitos de orbes em {value}",
		"color": Color.PINK,
		"is_positive": true
	},
	BuffType.RITUAL: {
		"name": "Ritual",
		"icon": "🕯️",
		"description": "Ganha {value} mana adicional por turno",
		"color": Color.GOLD,
		"is_positive": true
	}
}

var active_buffs := {}  # {target_id: {buff_type: {value: int, duration: int}}}

func _ready():
	print("🔮 BuffSystem - Sprint 16: Sistema de buffs temporários inicializado")

# === CORE BUFF MANAGEMENT ===

func apply_buff(target_id: String, buff_type: BuffType, value: int, duration: int = -1):
	"""Aplicar um buff a um alvo"""
	if not active_buffs.has(target_id):
		active_buffs[target_id] = {}

	var buffs = active_buffs[target_id]

	# Se o buff já existe, somar valores ou substituir duração
	if buffs.has(buff_type):
		var existing = buffs[buff_type]

		# Para buffs de duração, pegar a maior duração
		if duration > 0:
			existing.duration = max(existing.duration, duration)

		# Para buffs stackables, somar valores
		if _is_stackable_buff(buff_type):
			existing.value += value
		else:
			existing.value = max(existing.value, value)
	else:
		buffs[buff_type] = {
			"value": value,
			"duration": duration
		}

	print("🔮 Buff aplicado: %s recebeu %s (%d) por %d turnos" % [
		target_id,
		get_buff_name(buff_type),
		value,
		duration
	])

func remove_buff(target_id: String, buff_type: BuffType):
	"""Remover um buff específico"""
	if not active_buffs.has(target_id):
		return

	if active_buffs[target_id].has(buff_type):
		active_buffs[target_id].erase(buff_type)
		print("🔮 Buff removido: %s perdeu %s" % [target_id, get_buff_name(buff_type)])

func clear_all_buffs(target_id: String):
	"""Limpar todos os buffs de um alvo"""
	if active_buffs.has(target_id):
		active_buffs.erase(target_id)
		print("🔮 Todos os buffs removidos de %s" % target_id)

func get_buff_value(target_id: String, buff_type: BuffType) -> int:
	"""Obter valor atual de um buff"""
	if not active_buffs.has(target_id):
		return 0

	var buffs = active_buffs[target_id]
	if not buffs.has(buff_type):
		return 0

	return buffs[buff_type].value

func has_buff(target_id: String, buff_type: BuffType) -> bool:
	"""Verificar se um alvo tem um buff específico"""
	if not active_buffs.has(target_id):
		return false

	return active_buffs[target_id].has(buff_type)

func get_all_buffs(target_id: String) -> Dictionary:
	"""Obter todos os buffs de um alvo"""
	if not active_buffs.has(target_id):
		return {}

	return active_buffs[target_id].duplicate()

# === BUFF PROCESSING ===

func process_turn_start_buffs(target_id: String):
	"""Processar buffs no início do turno"""
	if not active_buffs.has(target_id):
		return

	var buffs = active_buffs[target_id]
	var effects_applied = []

	# Aplicar efeitos per-turn
	for buff_type in buffs.keys():
		var buff = buffs[buff_type]
		var effect = _apply_turn_effect(target_id, buff_type, buff.value)

		if effect != "":
			effects_applied.append(effect)

	# Decrementar durações
	_decrement_buff_durations(target_id)

	if not effects_applied.is_empty():
		print("🔮 Efeitos de turno aplicados em %s: %s" % [target_id, ", ".join(effects_applied)])

func process_turn_end_buffs(target_id: String):
	"""Processar buffs no final do turno"""
	if not active_buffs.has(target_id):
		return

	# Remover buffs expirados
	_remove_expired_buffs(target_id)

func _apply_turn_effect(target_id: String, buff_type: BuffType, value: int) -> String:
	"""Aplicar efeito per-turn de um buff"""
	match buff_type:
		BuffType.REGENERATION:
			if target_id == "player":
				RunManager.heal_player(value)
				return "Regenerou %d HP" % value

		BuffType.POISON:
			if target_id == "player":
				RunManager.damage_player(value)
				return "Perdeu %d HP por veneno" % value

		BuffType.ENERGY:
			if target_id == "player":
				# Será aplicado pelo combat system
				return "Ganha %d energia extra" % value

		BuffType.RITUAL:
			if target_id == "player":
				# Será aplicado pelo combat system
				return "Ganha %d mana extra" % value

	return ""

func _decrement_buff_durations(target_id: String):
	"""Decrementar durações dos buffs"""
	if not active_buffs.has(target_id):
		return

	var buffs = active_buffs[target_id]

	for buff_type in buffs.keys():
		var buff = buffs[buff_type]
		if buff.duration > 0:
			buff.duration -= 1

func _remove_expired_buffs(target_id: String):
	"""Remover buffs expirados"""
	if not active_buffs.has(target_id):
		return

	var buffs = active_buffs[target_id]
	var expired_buffs = []

	for buff_type in buffs.keys():
		var buff = buffs[buff_type]
		if buff.duration == 0:
			expired_buffs.append(buff_type)

	for buff_type in expired_buffs:
		buffs.erase(buff_type)
		print("🔮 Buff expirado: %s perdeu %s" % [target_id, get_buff_name(buff_type)])

# === COMBAT MODIFIERS ===

func modify_damage_dealt(target_id: String, base_damage: int) -> int:
	"""Modificar dano causado baseado em buffs"""
	var modified_damage = base_damage

	# Aplicar Força (aumenta dano)
	var strength = get_buff_value(target_id, BuffType.STRENGTH)
	if strength > 0:
		modified_damage += strength

	# Aplicar Fraqueza (reduz dano)
	var weakness = get_buff_value(target_id, BuffType.WEAKNESS)
	if weakness > 0:
		modified_damage = max(0, modified_damage - weakness)

	return modified_damage

func modify_damage_received(target_id: String, base_damage: int) -> int:
	"""Modificar dano recebido baseado em buffs"""
	var modified_damage = base_damage

	# Aplicar Vulnerável (aumenta dano recebido)
	var vulnerable = get_buff_value(target_id, BuffType.VULNERABLE)
	if vulnerable > 0:
		modified_damage = int(modified_damage * (1.0 + vulnerable / 100.0))

	return modified_damage

func modify_block_gained(target_id: String, base_block: int) -> int:
	"""Modificar bloqueio ganhado baseado em buffs"""
	var modified_block = base_block

	# Aplicar Destreza (aumenta bloqueio)
	var dexterity = get_buff_value(target_id, BuffType.DEXTERITY)
	if dexterity > 0:
		modified_block += dexterity

	# Aplicar Defesa (aumenta bloqueio)
	var defense = get_buff_value(target_id, BuffType.DEFENSE)
	if defense > 0:
		modified_block += defense

	return modified_block

func get_extra_energy(target_id: String) -> int:
	"""Obter energia extra por buffs"""
	return get_buff_value(target_id, BuffType.ENERGY)

func get_extra_mana(target_id: String) -> int:
	"""Obter mana extra por buffs"""
	return get_buff_value(target_id, BuffType.RITUAL)

# === UTILITY FUNCTIONS ===

func get_buff_name(buff_type: BuffType) -> String:
	"""Obter nome do buff"""
	return BUFF_DATA[buff_type].name

func get_buff_icon(buff_type: BuffType) -> String:
	"""Obter ícone do buff"""
	return BUFF_DATA[buff_type].icon

func get_buff_description(buff_type: BuffType, value: int) -> String:
	"""Obter descrição do buff com valor"""
	var template = BUFF_DATA[buff_type].description
	return template.format({"value": value})

func get_buff_color(buff_type: BuffType) -> Color:
	"""Obter cor do buff"""
	return BUFF_DATA[buff_type].color

func is_positive_buff(buff_type: BuffType) -> bool:
	"""Verificar se é um buff positivo"""
	return BUFF_DATA[buff_type].is_positive

func _is_stackable_buff(buff_type: BuffType) -> bool:
	"""Verificar se buff é acumulável"""
	# A maioria dos buffs são stackables, exceto alguns especiais
	match buff_type:
		BuffType.VULNERABLE:
			return false  # Vulnerável não stacka
		_:
			return true

# === PRESET BUFF COMBINATIONS ===

func apply_strength_combo(target_id: String, duration: int = 3):
	"""Aplicar combo de força (Força + Energia)"""
	apply_buff(target_id, BuffType.STRENGTH, 3, duration)
	apply_buff(target_id, BuffType.ENERGY, 1, duration)

func apply_defense_combo(target_id: String, duration: int = 3):
	"""Aplicar combo defensivo (Defesa + Regeneração)"""
	apply_buff(target_id, BuffType.DEFENSE, 2, duration)
	apply_buff(target_id, BuffType.REGENERATION, 2, duration)

func apply_poison_combo(target_id: String, duration: int = 5):
	"""Aplicar combo de veneno (Veneno + Fraqueza)"""
	apply_buff(target_id, BuffType.POISON, 3, duration)
	apply_buff(target_id, BuffType.WEAKNESS, 2, duration)

func apply_vulnerability_combo(target_id: String, duration: int = 2):
	"""Aplicar combo de vulnerabilidade"""
	apply_buff(target_id, BuffType.VULNERABLE, 50, duration)  # 50% mais dano

# === DEBUG & ADMIN ===

func debug_print_all_buffs():
	"""Debug: imprimir todos os buffs ativos"""
	print("🔮 === BUFFS ATIVOS ===")
	for target_id in active_buffs.keys():
		print("🎯 %s:" % target_id)
		var buffs = active_buffs[target_id]
		for buff_type in buffs.keys():
			var buff = buffs[buff_type]
			print("  %s %s: %d (dur: %d)" % [
				get_buff_icon(buff_type),
				get_buff_name(buff_type),
				buff.value,
				buff.duration
			])
	print("🔮 ==================")

func get_buff_summary(target_id: String) -> Array:
	"""Obter resumo dos buffs para UI"""
	var summary = []

	if not active_buffs.has(target_id):
		return summary

	var buffs = active_buffs[target_id]

	for buff_type in buffs.keys():
		var buff = buffs[buff_type]
		summary.append({
			"type": buff_type,
			"name": get_buff_name(buff_type),
			"icon": get_buff_icon(buff_type),
			"value": buff.value,
			"duration": buff.duration,
			"description": get_buff_description(buff_type, buff.value),
			"color": get_buff_color(buff_type),
			"is_positive": is_positive_buff(buff_type)
		})

	# Ordenar por tipo (positivos primeiro)
	summary.sort_custom(func(a, b): return a.is_positive and not b.is_positive)

	return summary