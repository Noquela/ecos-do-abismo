# Sprint 10 - Sistema de Runs em Árvore & Permadeath
extends Node

signal run_started
signal run_completed(victory: bool)
signal node_completed(node_type: String)
signal relic_added(relic: Dictionary)

# Estados da run atual
var current_run_active := false
var current_floor := 1
var max_floors := 3
var current_layer := 0  # Layer atual (0 a layers_per_floor-1)
var current_node_choices := []  # Opções de nodes disponíveis na layer atual
var player_hp := 100
var player_max_hp := 100
var nodes_completed := []

# Dados da run
var run_deck := []
var run_relics := []
var run_gold := 0

# Tipos de nodes
enum NodeType {
	COMBAT,
	ELITE,
	BOSS,
	EVENT,
	REST,
	SHOP
}

# Estrutura do mapa em árvore (3 andares, múltiplas opções por layer)
var floor_maps := []  # Array de floors, cada floor tem múltiplas layers
var layers_per_floor := 7  # Quantas layers por andar
var selected_path := []  # Path escolhido pelo jogador (índices dos nodes)

func _ready():
	print("🗺️ RunManager inicializado - Sprint 10: Árvore & Permadeath")

func start_new_run():
	"""Iniciar nova run"""
	print("🚀 Iniciando nova run!")

	# Reset do estado
	current_run_active = true
	current_floor = 1
	current_layer = 0
	nodes_completed.clear()
	selected_path.clear()

	# Stats do jogador baseados em upgrades
	var stats = GameData.get_player_stats()
	player_hp = stats.max_hp
	player_max_hp = stats.max_hp
	run_gold = 0

	# Inicializar deck da run com cartas básicas
	_initialize_run_deck()

	# Gerar mapas dos 3 andares
	floor_maps.clear()
	for floor_num in range(1, max_floors + 1):
		_generate_floor_map(floor_num)

	# Inicializar primeira layer
	_setup_current_layer()

	run_started.emit()
	print("🎯 Run iniciada - Andar %d, HP %d/%d" % [current_floor, player_hp, player_max_hp])
	print("🃏 Deck da run: %d cartas" % run_deck.size())

func _initialize_run_deck():
	"""Inicializar deck da run com cartas básicas"""
	run_deck.clear()

	# Deck starter básico (similar ao Slay the Spire)
	# 5x Ataque básico, 4x Defesa básica, 1x especial
	for i in range(5):
		run_deck.append(_create_basic_attack_card())
	for i in range(4):
		run_deck.append(_create_basic_defense_card())
	run_deck.append(_create_basic_heal_card())

	print("🎴 Deck inicial criado: %d cartas" % run_deck.size())

func _create_basic_attack_card() -> Dictionary:
	"""Criar carta de ataque básico"""
	return {
		"name": "Golpe",
		"type": "attack",
		"cost": 1,
		"damage": 6,
		"description": "Causa 6 de dano"
	}

func _create_basic_defense_card() -> Dictionary:
	"""Criar carta de defesa básico"""
	return {
		"name": "Bloqueio",
		"type": "defense",
		"cost": 1,
		"shield": 5,
		"description": "Ganha 5 de escudo"
	}

func _create_basic_heal_card() -> Dictionary:
	"""Criar carta de cura básica"""
	return {
		"name": "Poção",
		"type": "heal",
		"cost": 1,
		"heal": 5,
		"description": "Cura 5 HP"
	}

func _generate_floor_map(floor_level: int):
	"""Gerar mapa em árvore de um andar"""
	var tree_map = []  # Array de layers, cada layer tem múltiplos nodes

	# Gerar 7 layers por andar
	for layer in range(layers_per_floor):
		var layer_nodes = []
		var nodes_in_layer = 0

		match layer:
			0:  # Primeira layer - sempre 1 node (entrada)
				nodes_in_layer = 1
				layer_nodes.append(NodeType.COMBAT)
			6:  # Última layer - sempre 1 node (boss)
				nodes_in_layer = 1
				layer_nodes.append(NodeType.BOSS)
			_:  # Layers do meio - 2-4 opções
				nodes_in_layer = randi_range(2, 4)
				for i in range(nodes_in_layer):
					layer_nodes.append(_generate_node_for_floor_and_layer(floor_level, layer))

		tree_map.append(layer_nodes)

	floor_maps.append(tree_map)
	print("🗺️ Mapa árvore do andar %d gerado: %d layers" % [floor_level, layers_per_floor])

func _generate_node_for_floor_and_layer(floor_level: int, layer: int) -> NodeType:
	"""Gerar tipo de node baseado no andar e layer"""
	var rand = randf()

	match floor_level:
		1:  # Primeiro andar - mais fácil
			match layer:
				1, 2:  # Layers iniciais
					if rand < 0.6: return NodeType.COMBAT
					elif rand < 0.8: return NodeType.EVENT
					elif rand < 0.9: return NodeType.REST
					else: return NodeType.SHOP
				3, 4:  # Layers médias
					if rand < 0.5: return NodeType.COMBAT
					elif rand < 0.65: return NodeType.EVENT
					elif rand < 0.8: return NodeType.REST
					elif rand < 0.9: return NodeType.SHOP
					else: return NodeType.ELITE
				5:  # Layer antes do boss
					if rand < 0.4: return NodeType.COMBAT
					elif rand < 0.6: return NodeType.ELITE
					elif rand < 0.8: return NodeType.REST
					else: return NodeType.SHOP

		2:  # Segundo andar - médio
			if rand < 0.4: return NodeType.COMBAT
			elif rand < 0.6: return NodeType.ELITE
			elif rand < 0.75: return NodeType.EVENT
			elif rand < 0.9: return NodeType.REST
			else: return NodeType.SHOP

		3:  # Terceiro andar - difícil
			if rand < 0.3: return NodeType.COMBAT
			elif rand < 0.65: return NodeType.ELITE
			elif rand < 0.8: return NodeType.EVENT
			elif rand < 0.95: return NodeType.REST
			else: return NodeType.SHOP

	return NodeType.COMBAT  # Fallback

func _setup_current_layer():
	"""Configurar opções da layer atual"""
	if not current_run_active or floor_maps.is_empty():
		return

	var current_floor_map = floor_maps[current_floor - 1]
	if current_layer >= current_floor_map.size():
		return

	current_node_choices = current_floor_map[current_layer]
	print("🎯 Layer %d: %d opções disponíveis" % [current_layer, current_node_choices.size()])

func get_current_layer_choices() -> Array:
	"""Obter opções de nodes na layer atual"""
	return current_node_choices

func choose_node(choice_index: int) -> NodeType:
	"""Escolher um node da layer atual"""
	if choice_index < 0 or choice_index >= current_node_choices.size():
		print("❌ Escolha inválida: %d" % choice_index)
		return NodeType.COMBAT

	var chosen_node = current_node_choices[choice_index]
	selected_path.append(choice_index)
	print("✅ Node escolhido: %s (índice %d)" % [get_node_type_name(chosen_node), choice_index])
	return chosen_node

func complete_current_node():
	"""Completar node atual e avançar"""
	nodes_completed.append(current_layer)

	# Avançar para próxima layer
	current_layer += 1

	# Verificar se terminou o andar
	if current_layer >= layers_per_floor:
		_complete_floor()
	else:
		_setup_current_layer()

	node_completed.emit(get_node_type_name(get_current_node_type()))

func _complete_floor():
	"""Completar andar atual"""
	print("🎉 Andar %d completado!" % current_floor)

	# Avançar para próximo andar
	current_floor += 1
	current_layer = 0

	if current_floor > max_floors:
		# Run completada com sucesso!
		_complete_run(true)
	else:
		# Continuar para próximo andar
		_setup_current_layer()
		print("🆙 Avançando para andar %d" % current_floor)

func _complete_run(victory: bool):
	"""Completar run atual"""
	if victory:
		print("🏆 RUN COMPLETADA COM SUCESSO!")
		GameData.register_victory()
	else:
		print("💀 RUN FALHOU - PERMADEATH")
		GameData.register_defeat()

	# Reset estado
	current_run_active = false
	current_floor = 1
	current_layer = 0
	floor_maps.clear()
	selected_path.clear()

	GameData.save_game()
	run_completed.emit(victory)

func get_current_node_type() -> NodeType:
	"""Obter tipo do node atual (primeira opção se não escolhido ainda)"""
	if current_node_choices.is_empty():
		return NodeType.COMBAT
	return current_node_choices[0]

func get_node_type_name(node_type: NodeType) -> String:
	"""Obter nome do tipo de node"""
	match node_type:
		NodeType.COMBAT: return "⚔️ Combate"
		NodeType.ELITE: return "💀 Elite"
		NodeType.BOSS: return "👹 Boss"
		NodeType.EVENT: return "📖 Evento"
		NodeType.REST: return "🔥 Fogueira"
		NodeType.SHOP: return "🛒 Loja"
		_: return "❓ Desconhecido"

func heal_player(amount: int):
	"""Curar jogador"""
	var old_hp = player_hp
	player_hp = min(player_max_hp, player_hp + amount)
	var healed = player_hp - old_hp
	print("💚 Jogador curou %d HP - HP: %d/%d" % [healed, player_hp, player_max_hp])

func get_run_progress() -> Dictionary:
	"""Obter progresso atual da run"""
	return {
		"active": current_run_active,
		"floor": current_floor,
		"max_floors": max_floors,
		"layer": current_layer,
		"layers_per_floor": layers_per_floor,
		"hp": player_hp,
		"max_hp": player_max_hp,
		"nodes_completed": nodes_completed.size(),
		"deck_size": run_deck.size(),
		"relics": run_relics.size(),
		"gold": run_gold
	}

func set_player_hp(new_hp: int):
	"""Definir HP atual do jogador"""
	player_hp = max(0, min(player_max_hp, new_hp))
	print("❤️ HP do jogador atualizado: %d/%d" % [player_hp, player_max_hp])

	# PERMADEATH: Se HP chegou a 0, run falha
	if player_hp <= 0:
		print("💀 PERMADEATH ATIVADO - HP chegou a 0")
		_complete_run(false)

func can_advance() -> bool:
	"""Verificar se pode avançar"""
	return current_run_active and player_hp > 0 and not current_node_choices.is_empty()

func get_current_map() -> Array:
	"""Obter mapa atual (para compatibilidade com código antigo)"""
	if not current_run_active or floor_maps.is_empty():
		return []

	# Retornar array simplificado das escolhas atuais
	return current_node_choices

func get_floor_preview() -> Array:
	"""Obter preview de todas as layers do andar atual"""
	if not current_run_active or floor_maps.is_empty():
		return []

	var current_floor_map = floor_maps[current_floor - 1]
	var preview = []

	for layer_idx in range(current_floor_map.size()):
		var layer_data = {
			"layer": layer_idx,
			"is_current": layer_idx == current_layer,
			"is_completed": layer_idx < current_layer,
			"is_future": layer_idx > current_layer,
			"nodes": current_floor_map[layer_idx]
		}
		preview.append(layer_data)

	return preview

func get_run_deck() -> Array:
	"""Obter deck atual da run"""
	return run_deck.duplicate()

func add_card_to_deck(card: Dictionary):
	"""Adicionar carta ao deck da run"""
	run_deck.append(card)
	print("🃏 Carta adicionada ao deck: %s" % card.name)

func remove_card_from_deck(card_index: int):
	"""Remover carta do deck da run"""
	if card_index >= 0 and card_index < run_deck.size():
		var removed_card = run_deck.pop_at(card_index)
		print("🗑️ Carta removida do deck: %s" % removed_card.name)

func add_relic(relic: Dictionary):
	"""Adicionar relíquia à run"""
	run_relics.append(relic)
	print("💎 Relíquia adquirida: %s" % relic.name)

	# Aplicar efeitos imediatos
	_apply_relic_immediate_effects(relic)

	# Emitir sinal
	relic_added.emit(relic)

func _apply_relic_immediate_effects(relic: Dictionary):
	"""Aplicar efeitos imediatos da relíquia"""
	match relic.effect:
		"max_energy_bonus":
			# Aumentar energia máxima permanentemente
			GameData.upgrade_stat("starting_energy", relic.value)
			print("⚡ Energia máxima aumentada em +%d" % relic.value)
		"max_hp_bonus":
			# Aumentar HP máximo
			player_max_hp += relic.value
			player_hp += relic.value  # Cura também
			print("❤️ HP máximo aumentado em +%d" % relic.value)
		"energy_hp_trade":
			# Boss relic: +energia, -hp
			GameData.upgrade_stat("starting_energy", 1)
			player_max_hp -= 5
			player_hp = min(player_hp, player_max_hp)
			print("⚡ +1 energia, -5 HP máximo")

func get_run_relics() -> Array:
	"""Obter relíquias da run atual"""
	return run_relics.duplicate()

func has_relic(relic_name: String) -> bool:
	"""Verificar se tem relíquia específica"""
	for relic in run_relics:
		if relic.name == relic_name:
			return true
	return false

func get_relic_effect_value(effect_name: String) -> int:
	"""Obter valor total de um efeito das relíquias"""
	var total_value = 0
	for relic in run_relics:
		if relic.effect == effect_name:
			total_value += relic.value
	return total_value