# Sprint 15 - Sistema de Descanso/Fogueira
extends Node

# Tipos de ações na fogueira
enum CampfireAction {
	REST,
	UPGRADE_CARD,
	MEDITATE,
	COOK_MEAL,
	SHARPEN_WEAPONS
}

# Estrutura das opções disponíveis
func get_campfire_options() -> Array:
	"""Obter opções disponíveis na fogueira"""
	var options = []

	# Sempre disponível: Descansar
	options.append({
		"action": CampfireAction.REST,
		"name": "🔥 Descansar",
		"description": "Cure 30% do seu HP máximo",
		"icon": "🛌",
		"always_available": true
	})

	# Sempre disponível se houver cartas: Melhorar carta
	var deck = RunManager.get_run_deck()
	if deck.size() > 0:
		options.append({
			"action": CampfireAction.UPGRADE_CARD,
			"name": "⬆️ Melhorar Carta",
			"description": "Melhore permanentemente uma carta do seu deck",
			"icon": "🔧",
			"requires_cards": true
		})

	# 40% chance: Meditar (benefício temporário)
	if randf() < 0.4:
		options.append({
			"action": CampfireAction.MEDITATE,
			"name": "🧘 Meditar",
			"description": "Ganha +1 energia no próximo combate",
			"icon": "✨",
			"temporary_benefit": true
		})

	# 30% chance: Cozinhar refeição (cura + buff)
	if randf() < 0.3:
		options.append({
			"action": CampfireAction.COOK_MEAL,
			"name": "🍖 Cozinhar Refeição",
			"description": "Cure 20% HP + ganhe 3 de escudo no próximo combate",
			"icon": "🍗",
			"combo_benefit": true
		})

	# 25% chance: Afiar armas (buff de dano)
	if randf() < 0.25:
		options.append({
			"action": CampfireAction.SHARPEN_WEAPONS,
			"name": "⚔️ Afiar Armas",
			"description": "Seus ataques causam +2 dano no próximo combate",
			"icon": "🗡️",
			"combat_buff": true
		})

	print("🔥 Opções de fogueira geradas: %d opções" % options.size())
	return options

func execute_campfire_action(action: CampfireAction) -> Dictionary:
	"""Executar ação da fogueira"""
	var result = {"success": true, "message": "", "needs_card_selection": false}

	match action:
		CampfireAction.REST:
			var heal_amount = int(RunManager.player_max_hp * 0.3)
			RunManager.heal_player(heal_amount)
			result.message = "🛌 Você descansou e recuperou %d HP" % heal_amount

		CampfireAction.UPGRADE_CARD:
			result.message = "⬆️ Escolha uma carta para melhorar"
			result.needs_card_selection = true

		CampfireAction.MEDITATE:
			_apply_temporary_buff("meditation_energy", 1)
			result.message = "🧘 Você medita e sente sua energia crescer. +1 energia no próximo combate"

		CampfireAction.COOK_MEAL:
			var heal_amount = int(RunManager.player_max_hp * 0.2)
			RunManager.heal_player(heal_amount)
			_apply_temporary_buff("meal_shield", 3)
			result.message = "🍗 Refeição deliciosa! Curou %d HP e ganhará 3 de escudo no próximo combate" % heal_amount

		CampfireAction.SHARPEN_WEAPONS:
			_apply_temporary_buff("sharpened_weapons", 2)
			result.message = "⚔️ Armas afiadas! Seus ataques causarão +2 dano no próximo combate"

	print("🔥 Ação executada: %s" % result.message)
	return result

func _apply_temporary_buff(buff_name: String, value: int):
	"""Aplicar buff temporário para o próximo combate"""
	# Implementar sistema de buffs temporários
	if not RunManager.has_method("add_temporary_buff"):
		print("⚠️ Sistema de buffs temporários ainda não implementado")
		return

	RunManager.add_temporary_buff(buff_name, value)

func upgrade_card(card_index: int) -> Dictionary:
	"""Melhorar uma carta específica"""
	var deck = RunManager.get_run_deck()
	var result = {"success": false, "message": ""}

	if card_index < 0 or card_index >= deck.size():
		result.message = "❌ Carta inválida selecionada"
		return result

	var card = deck[card_index]
	var upgraded_card = _create_upgraded_card(card)

	# Substituir carta no deck
	deck[card_index] = upgraded_card

	result.success = true
	result.message = "⬆️ Carta '%s' foi melhorada!" % card.name

	print("🔧 Carta melhorada: %s → %s" % [card.name, upgraded_card.name])
	return result

func _create_upgraded_card(card: Dictionary) -> Dictionary:
	"""Criar versão melhorada de uma carta"""
	var upgraded = card.duplicate()

	# Marcar como melhorada
	upgraded.upgraded = true
	upgraded.name += "+"

	# Melhorar estatísticas baseado no tipo
	match card.type:
		"attack":
			if card.has("damage"):
				upgraded.damage += 3
			if card.has("hits") and card.hits > 1:
				upgraded.hits += 1

		"defense":
			if card.has("shield"):
				upgraded.shield += 2

		"heal":
			if card.has("heal"):
				upgraded.heal += 3

		"energy":
			if card.has("energy"):
				upgraded.energy += 1

		"power":
			if card.has("damage_bonus"):
				upgraded.damage_bonus += 1
			elif card.has("shield_bonus"):
				upgraded.shield_bonus += 1
			elif card.has("energy_bonus"):
				upgraded.energy_bonus += 1

		"skill":
			if card.has("draw_cards"):
				upgraded.draw_cards += 1

	# Reduzir custo em 1 (mínimo 0) para algumas cartas
	if card.cost > 0 and randf() < 0.3:
		upgraded.cost = max(0, card.cost - 1)

	# Atualizar descrição
	upgraded.description = _generate_upgraded_description(upgraded)

	return upgraded

func _generate_upgraded_description(card: Dictionary) -> String:
	"""Gerar descrição atualizada para carta melhorada"""
	var desc = ""

	match card.type:
		"attack":
			if card.has("hits") and card.hits > 1:
				desc = "Causa %d de dano %d vezes" % [card.damage, card.hits]
			else:
				desc = "Causa %d de dano" % card.damage

		"defense":
			desc = "Ganha %d de escudo" % card.shield

		"heal":
			desc = "Cura %d HP" % card.heal

		"energy":
			desc = "Ganha %d de energia" % card.energy

		"power":
			if card.has("damage_bonus"):
				desc = "Aumenta permanentemente o dano em %d" % card.damage_bonus
			elif card.has("shield_bonus"):
				desc = "Aumenta permanentemente o escudo em %d" % card.shield_bonus
			elif card.has("energy_bonus"):
				desc = "Aumenta permanentemente a energia em %d" % card.energy_bonus

		"skill":
			if card.has("draw_cards"):
				desc = "Compra %d cartas" % card.draw_cards

	# Adicionar nota de melhoria
	desc += " (Melhorada)"
	return desc

func get_campfire_ambiance_text() -> String:
	"""Obter texto de ambientação aleatório"""
	var ambiance_texts = [
		"🔥 As chamas dançam suavemente, oferecendo calor e conforto nas profundezas frias do abismo.",
		"🔥 O fogo crepita, criando sombras que dançam nas paredes rochosas ao seu redor.",
		"🔥 A fogueira oferece um momento de paz em sua jornada perigosa.",
		"🔥 As brasas brilham intensamente, irradiando uma energia reconfortante.",
		"🔥 O calor da fogueira aquece não apenas seu corpo, mas também seu espírito."
	]
	return ambiance_texts[randi() % ambiance_texts.size()]

func can_use_campfire() -> bool:
	"""Verificar se pode usar a fogueira"""
	# Sempre pode usar durante uma run ativa
	return RunManager.current_run_active

func get_rest_recommendation() -> String:
	"""Obter recomendação baseada no estado do jogador"""
	var hp_percentage = float(RunManager.player_hp) / float(RunManager.player_max_hp)

	if hp_percentage < 0.5:
		return "💡 Recomendação: Você está ferido. Considere descansar para recuperar HP."
	elif hp_percentage < 0.8:
		return "💡 Recomendação: Você poderia se beneficiar de um descanso."
	else:
		return "💡 Recomendação: Você está saudável. Talvez seja melhor melhorar uma carta."

func get_upgrade_candidates() -> Array:
	"""Obter cartas candidatas a melhoria (ainda não melhoradas)"""
	var deck = RunManager.get_run_deck()
	var candidates = []

	for i in range(deck.size()):
		var card = deck[i]
		if not card.has("upgraded") or not card.upgraded:
			candidates.append({"index": i, "card": card})

	return candidates