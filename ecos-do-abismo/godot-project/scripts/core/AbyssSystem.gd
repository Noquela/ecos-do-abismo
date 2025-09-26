# Sprint 17 - Sistema de Profundidade e Corrupção do Abismo
extends Node

# === CORE CONCEPT ===
# Quanto mais fundo no Abismo, mais poderoso você fica, mas também mais corrompido
# Corrupção muda fundamentalmente como o jogo funciona

signal corruption_changed(new_level)
signal depth_changed(new_depth)
signal echo_triggered(card_name, effect)

var current_depth: int = 0
var corruption_level: int = 0
var max_corruption: int = 100

# Memory Echoes - mecânica signature
var active_echoes: Array = []
var echo_history: Array = []

# Efeitos da profundidade por tier
const DEPTH_TIERS = {
	0: {"name": "Superfície", "corruption_rate": 0, "power_bonus": 0},
	5: {"name": "Penumbra", "corruption_rate": 1, "power_bonus": 10},
	10: {"name": "Trevas Leves", "corruption_rate": 2, "power_bonus": 25},
	15: {"name": "Abismo Médio", "corruption_rate": 3, "power_bonus": 40},
	20: {"name": "Profundezas Sombrias", "corruption_rate": 4, "power_bonus": 60},
	25: {"name": "Núcleo do Abismo", "corruption_rate": 5, "power_bonus": 80}
}

# Níveis de corrupção e seus efeitos
const CORRUPTION_EFFECTS = {
	0: {
		"name": "Puro",
		"description": "Sem corrupção",
		"card_transform_chance": 0,
		"energy_cost_modifier": 0,
		"damage_bonus": 0,
		"special_abilities": []
	},
	25: {
		"name": "Tocado",
		"description": "Levemente influenciado pelo Abismo",
		"card_transform_chance": 10,
		"energy_cost_modifier": 0,
		"damage_bonus": 2,
		"special_abilities": ["echo_cards"]
	},
	50: {
		"name": "Corrompido",
		"description": "O Abismo flui em suas veias",
		"card_transform_chance": 25,
		"energy_cost_modifier": -1,  # Cartas custam menos
		"damage_bonus": 5,
		"special_abilities": ["echo_cards", "shadow_mana"]
	},
	75: {
		"name": "Abissal",
		"description": "Mais Abismo que humano",
		"card_transform_chance": 50,
		"energy_cost_modifier": -1,
		"damage_bonus": 8,
		"special_abilities": ["echo_cards", "shadow_mana", "corruption_burst"]
	},
	100: {
		"name": "Avatar do Vazio",
		"description": "Completamente um com o Abismo",
		"card_transform_chance": 100,
		"energy_cost_modifier": -2,
		"damage_bonus": 15,
		"special_abilities": ["echo_cards", "shadow_mana", "corruption_burst", "void_form"]
	}
}

func _ready():
	print("🌑 AbyssSystem - Sistema de Profundidade e Corrupção inicializado")
	_reset_abyss_state()

# === DEPTH MANAGEMENT ===

func descend_depth(floors: int = 1):
	"""Descer mais fundo no abismo"""
	current_depth += floors

	# Ganhar corrupção baseado na profundidade
	var depth_tier = _get_current_depth_tier()
	if depth_tier.corruption_rate > 0:
		add_corruption(depth_tier.corruption_rate * floors)

	print("🕳️ Desceu para profundidade %d (%s)" % [current_depth, depth_tier.name])
	depth_changed.emit(current_depth)

	# Aplicar efeitos da nova profundidade
	_apply_depth_effects()

func _get_current_depth_tier() -> Dictionary:
	"""Obter tier de profundidade atual"""
	var tier_depth = 0
	for depth in DEPTH_TIERS.keys():
		if current_depth >= depth:
			tier_depth = depth

	return DEPTH_TIERS[tier_depth]

func _apply_depth_effects():
	"""Aplicar efeitos da profundidade atual"""
	var tier = _get_current_depth_tier()

	# Bonus de poder baseado na profundidade
	if tier.power_bonus > 0:
		BuffSystem.apply_buff("player", BuffSystem.BuffType.STRENGTH, tier.power_bonus, -1)  # Permanente
		print("💪 Ganhou +%d poder das profundezas" % tier.power_bonus)

# === CORRUPTION MANAGEMENT ===

func add_corruption(amount: int):
	"""Adicionar corrupção"""
	var old_level = _get_corruption_tier()
	corruption_level = min(max_corruption, corruption_level + amount)
	var new_level = _get_corruption_tier()

	print("🌑 Corrupção aumentou: %d (+%d)" % [corruption_level, amount])
	corruption_changed.emit(corruption_level)

	# Verificar mudança de tier
	if new_level != old_level:
		_on_corruption_tier_changed(old_level, new_level)

func remove_corruption(amount: int):
	"""Remover corrupção (raro)"""
	corruption_level = max(0, corruption_level - amount)
	print("✨ Corrupção purificada: %d (-%d)" % [corruption_level, amount])
	corruption_changed.emit(corruption_level)

func _get_corruption_tier() -> int:
	"""Obter tier de corrupção atual"""
	for tier in [100, 75, 50, 25, 0]:
		if corruption_level >= tier:
			return tier
	return 0

func get_corruption_effects() -> Dictionary:
	"""Obter efeitos da corrupção atual"""
	var tier = _get_corruption_tier()
	return CORRUPTION_EFFECTS[tier]

func _on_corruption_tier_changed(old_tier: int, new_tier: int):
	"""Quando muda de tier de corrupção"""
	var effects = CORRUPTION_EFFECTS[new_tier]
	print("🌑 TRANSFORMAÇÃO: %s → %s" % [CORRUPTION_EFFECTS[old_tier].name, effects.name])
	print("📜 %s" % effects.description)

	# Aplicar novas habilidades especiais
	_unlock_corruption_abilities(effects.special_abilities)

func _unlock_corruption_abilities(abilities: Array):
	"""Desbloquear habilidades da corrupção"""
	for ability in abilities:
		match ability:
			"echo_cards":
				print("🔮 NOVA HABILIDADE: Memory Echo - Cartas deixam ecos")
			"shadow_mana":
				print("🌙 NOVA HABILIDADE: Shadow Mana - Corrupção gera mana")
			"corruption_burst":
				print("💥 NOVA HABILIDADE: Corruption Burst - Explosões de poder")
			"void_form":
				print("👤 NOVA HABILIDADE: Void Form - Forma final do Abismo")

# === MEMORY ECHO SYSTEM ===

func create_echo(card_data: Dictionary):
	"""Criar eco de uma carta jogada"""
	if not _can_create_echo():
		return

	var echo = {
		"card_name": card_data.name,
		"card_type": card_data.type,
		"effect_power": _calculate_echo_power(card_data),
		"turns_remaining": 3,
		"triggered": false
	}

	active_echoes.append(echo)
	echo_history.append(card_data.name)

	print("🔮 Eco criado: %s (poder %d)" % [echo.card_name, echo.effect_power])

func _can_create_echo() -> bool:
	"""Verificar se pode criar ecos"""
	var effects = get_corruption_effects()
	return "echo_cards" in effects.special_abilities

func _calculate_echo_power(card_data: Dictionary) -> int:
	"""Calcular poder do eco baseado na carta e corrupção"""
	var base_power = 0

	match card_data.type:
		"attack":
			base_power = card_data.get("damage", 5)
		"heal":
			base_power = card_data.get("heal", 3)
		"defense":
			base_power = card_data.get("shield", 4)
		_:
			base_power = 3

	# Modificar baseado na corrupção
	var corruption_multiplier = 1.0 + (corruption_level / 100.0)
	return int(base_power * corruption_multiplier)

func trigger_echoes():
	"""Ativar ecos disponíveis no início do turno"""
	if active_echoes.is_empty():
		return

	print("🔮 === ATIVANDO ECOS ===")

	for echo in active_echoes:
		if echo.turns_remaining > 0 and not echo.triggered:
			_activate_echo(echo)
			echo.triggered = true

	# Decrementar durações
	for echo in active_echoes:
		echo.turns_remaining -= 1

	# Remover ecos expirados
	active_echoes = active_echoes.filter(func(echo): return echo.turns_remaining > 0)

func _activate_echo(echo: Dictionary):
	"""Ativar um eco específico"""
	var effect_applied = false

	match echo.card_type:
		"attack":
			# Eco de ataque: dano no inimigo
			print("⚔️ Eco de %s: %d dano sombrio" % [echo.card_name, echo.effect_power])
			effect_applied = true
		"heal":
			# Eco de cura: regeneração
			RunManager.heal_player(echo.effect_power)
			print("💚 Eco de %s: %d cura sombria" % [echo.card_name, echo.effect_power])
			effect_applied = true
		"defense":
			# Eco de defesa: escudo temporal
			BuffSystem.apply_buff("player", BuffSystem.BuffType.DEFENSE, echo.effect_power, 1)
			print("🛡️ Eco de %s: %d defesa sombria" % [echo.card_name, echo.effect_power])
			effect_applied = true
		"power":
			# Eco de poder: buff temporário
			BuffSystem.apply_buff("player", BuffSystem.BuffType.STRENGTH, echo.effect_power, 2)
			print("💪 Eco de %s: %d força sombria" % [echo.card_name, echo.effect_power])
			effect_applied = true

	if effect_applied:
		echo_triggered.emit(echo.card_name, echo.effect_power)

# === SHADOW MANA SYSTEM ===

func get_shadow_mana() -> int:
	"""Obter mana sombria disponível (baseada na corrupção)"""
	var effects = get_corruption_effects()
	if "shadow_mana" in effects.special_abilities:
		return int(corruption_level / 20)  # 1 mana a cada 20 de corrupção
	return 0

func spend_shadow_mana(amount: int) -> bool:
	"""Gastar mana sombria (reduz corrupção temporariamente)"""
	var available = get_shadow_mana()
	if amount <= available:
		# Não remove corrupção permanentemente, apenas "gasta" o poder
		print("🌙 Usou %d de mana sombria" % amount)
		return true
	return false

# === CARD TRANSFORMATION ===

func should_transform_card(_card: Dictionary) -> bool:
	"""Verificar se carta deve ser transformada pela corrupção"""
	var effects = get_corruption_effects()
	return randf() * 100 < effects.card_transform_chance

func transform_card(card: Dictionary) -> Dictionary:
	"""Transformar carta em versão corrompida"""
	var corrupted_card = card.duplicate(true)

	# Adicionar prefixo sombrio
	corrupted_card.name = "Sombrio " + card.name
	corrupted_card.description += " [CORROMPIDO]"

	# Modificar estatísticas
	var effects = get_corruption_effects()

	# Reduzir custo de energia
	corrupted_card.cost = max(0, corrupted_card.cost + effects.energy_cost_modifier)

	# Aumentar poder
	if corrupted_card.has("damage"):
		corrupted_card.damage += effects.damage_bonus
	if corrupted_card.has("heal"):
		corrupted_card.heal += effects.damage_bonus
	if corrupted_card.has("shield"):
		corrupted_card.shield += effects.damage_bonus

	# Adicionar efeito especial de corrupção
	corrupted_card.corruption_effect = true

	print("🌑 Carta transformada: %s → %s" % [card.name, corrupted_card.name])
	return corrupted_card

# === COMBAT INTEGRATION ===

func modify_combat_damage(base_damage: int) -> int:
	"""Modificar dano de combate baseado na corrupção"""
	var effects = get_corruption_effects()
	return base_damage + effects.damage_bonus

func get_energy_cost_modifier() -> int:
	"""Obter modificador de custo de energia"""
	var effects = get_corruption_effects()
	return effects.energy_cost_modifier

# === ABYSS EVENTS ===

func trigger_corruption_event():
	"""Gatilhar evento especial de corrupção"""
	var events = [
		{
			"name": "Sussurros do Vazio",
			"description": "Vozes antigas oferecem poder...",
			"corruption_gain": 10,
			"reward": "carta_corrompida"
		},
		{
			"name": "Altar Sombrio",
			"description": "Um altar pulsa com energia sombria",
			"corruption_gain": 15,
			"reward": "mana_sombria"
		},
		{
			"name": "Espelho das Almas",
			"description": "Você vê reflexos de quem poderia se tornar",
			"corruption_gain": 5,
			"reward": "echo_permanente"
		}
	]

	var event = events[randi() % events.size()]
	print("🌑 EVENTO DO ABISMO: %s" % event.name)
	print("📜 %s" % event.description)

	add_corruption(event.corruption_gain)
	_apply_corruption_reward(event.reward)

func _apply_corruption_reward(reward_type: String):
	"""Aplicar recompensa de evento de corrupção"""
	match reward_type:
		"carta_corrompida":
			print("🃏 Você ganha uma carta corrompida!")
		"mana_sombria":
			print("🌙 Você ganha acesso a mana sombria!")
		"echo_permanente":
			print("🔮 Você ganha um eco permanente!")

# === UTILITY & DEBUG ===

func _reset_abyss_state():
	"""Resetar estado do abismo (novo jogo)"""
	current_depth = 0
	corruption_level = 0
	active_echoes.clear()
	echo_history.clear()

func get_abyss_status() -> Dictionary:
	"""Obter status completo do abismo"""
	var tier = _get_current_depth_tier()
	var effects = get_corruption_effects()

	return {
		"depth": current_depth,
		"depth_tier": tier.name,
		"corruption": corruption_level,
		"corruption_tier": effects.name,
		"shadow_mana": get_shadow_mana(),
		"active_echoes": active_echoes.size(),
		"can_echo": _can_create_echo()
	}

func debug_print_abyss_state():
	"""Debug: imprimir estado completo do abismo"""
	var status = get_abyss_status()
	print("🌑 === ESTADO DO ABISMO ===")
	print("  Profundidade: %d (%s)" % [status.depth, status.depth_tier])
	print("  Corrupção: %d (%s)" % [status.corruption, status.corruption_tier])
	print("  Mana Sombria: %d" % status.shadow_mana)
	print("  Ecos Ativos: %d" % status.active_echoes)
	print("  Pode Ecoar: %s" % status.can_echo)
	print("🌑 =========================")

# === SAVE/LOAD INTEGRATION ===

func get_save_data() -> Dictionary:
	"""Obter dados para save"""
	return {
		"current_depth": current_depth,
		"corruption_level": corruption_level,
		"active_echoes": active_echoes,
		"echo_history": echo_history
	}

func load_save_data(data: Dictionary):
	"""Carregar dados do save"""
	current_depth = data.get("current_depth", 0)
	corruption_level = data.get("corruption_level", 0)
	active_echoes = data.get("active_echoes", [])
	echo_history = data.get("echo_history", [])