# Sprint 14 - Sistema de Lojas
extends Node

# Tipos de itens da loja
enum ItemType {
	CARD,
	RELIC,
	REMOVAL,
	HEAL,
	UPGRADE
}

# Preços base dos itens
const BASE_PRICES = {
	ItemType.CARD: 50,
	ItemType.RELIC: 150,
	ItemType.REMOVAL: 75,
	ItemType.HEAL: 60,
	ItemType.UPGRADE: 80
}

func generate_shop_inventory() -> Array:
	"""Gerar inventário da loja"""
	var inventory = []

	# Sempre ter 1 poção de cura
	inventory.append({
		"type": ItemType.HEAL,
		"name": "Poção de Cura",
		"description": "Cura 25% do HP máximo",
		"price": BASE_PRICES[ItemType.HEAL],
		"value": 0.25,
		"icon": "💚"
	})

	# Sempre ter remoção de carta
	inventory.append({
		"type": ItemType.REMOVAL,
		"name": "Remoção de Carta",
		"description": "Remove uma carta do seu deck permanentemente",
		"price": BASE_PRICES[ItemType.REMOVAL],
		"value": 1,
		"icon": "🗑️"
	})

	# 2-3 cartas aleatórias
	var cards_count = randi_range(2, 3)
	for i in range(cards_count):
		var card = CardPool.get_random_shop_card()
		var card_item = {
			"type": ItemType.CARD,
			"name": card.name,
			"description": card.description,
			"price": _calculate_card_price(card),
			"card_data": card,
			"icon": "🃏"
		}
		inventory.append(card_item)

	# 30% chance de ter relíquia
	if randf() < 0.3:
		var relic = RelicSystem.get_random_relic(RelicSystem.RelicType.COMMON)
		var relic_item = {
			"type": ItemType.RELIC,
			"name": relic.name,
			"description": relic.description,
			"price": BASE_PRICES[ItemType.RELIC],
			"relic_data": relic,
			"icon": "💎"
		}
		inventory.append(relic_item)

	# 40% chance de ter upgrade de carta
	if randf() < 0.4:
		inventory.append({
			"type": ItemType.UPGRADE,
			"name": "Upgrade de Carta",
			"description": "Melhora permanentemente uma carta do seu deck",
			"price": BASE_PRICES[ItemType.UPGRADE],
			"value": 1,
			"icon": "⬆️"
		})

	print("🛒 Inventário da loja gerado: %d itens" % inventory.size())
	return inventory

func _calculate_card_price(card: Dictionary) -> int:
	"""Calcular preço da carta baseado na raridade"""
	var base_price = BASE_PRICES[ItemType.CARD]

	match card.rarity:
		CardPool.Rarity.COMMON:
			return base_price
		CardPool.Rarity.UNCOMMON:
			return int(base_price * 1.5)
		CardPool.Rarity.RARE:
			return int(base_price * 2.0)
		_:
			return base_price

func can_afford_item(item: Dictionary) -> bool:
	"""Verificar se o jogador pode comprar o item"""
	return GameData.player_data.coins >= item.price

func buy_item(item: Dictionary) -> Dictionary:
	"""Comprar item da loja"""
	var result = {"success": false, "message": ""}

	if not can_afford_item(item):
		result.message = "💰 Moedas insuficientes! Precisa de %d moedas." % item.price
		return result

	# Deduzir moedas
	GameData.add_coins(-item.price)

	# Aplicar efeito do item
	match item.type:
		ItemType.HEAL:
			var heal_amount = int(RunManager.player_max_hp * item.value)
			RunManager.heal_player(heal_amount)
			result.message = "💚 Curou %d HP!" % heal_amount

		ItemType.CARD:
			RunManager.add_card_to_deck(item.card_data)
			result.message = "🃏 Carta '%s' adicionada ao deck!" % item.name

		ItemType.RELIC:
			RunManager.add_relic(item.relic_data)
			result.message = "💎 Relíquia '%s' adquirida!" % item.name

		ItemType.REMOVAL:
			# Será implementado na interface - precisa escolher carta
			result.message = "🗑️ Selecione uma carta para remover"
			result["needs_card_selection"] = true

		ItemType.UPGRADE:
			# Será implementado na interface - precisa escolher carta
			result.message = "⬆️ Selecione uma carta para melhorar"
			result["needs_card_selection"] = true

	result.success = true
	print("💰 Item comprado: %s por %d moedas" % [item.name, item.price])
	return result

func get_item_affordable_status(inventory: Array) -> Array:
	"""Obter status de acessibilidade dos itens"""
	var status = []
	for item in inventory:
		status.append(can_afford_item(item))
	return status

func get_shop_greeting() -> String:
	"""Obter saudação aleatória do lojista"""
	var greetings = [
		"🛒 Bem-vindo à minha loja! Tenho os melhores itens do abismo.",
		"💰 Olhe só o que chegou hoje! Itens frescos e poderosos.",
		"🎯 Aventureiro! Você parece precisar de algo especial.",
		"✨ Minha loja tem exatamente o que você precisa para sobreviver.",
		"🔮 Ah, outro explorador corajoso! Vamos negociar?"
	]
	return greetings[randi() % greetings.size()]

func get_item_display_text(item: Dictionary) -> String:
	"""Obter texto de exibição do item"""
	var text = "%s %s\n" % [item.icon, item.name]
	text += "💰 %d moedas\n\n" % item.price
	text += item.description

	# Informações extras baseadas no tipo
	match item.type:
		ItemType.CARD:
			if item.has("card_data"):
				var card = item.card_data
				text += "\n\n⚡ Custo: %d energia" % card.cost
				text += "\n⭐ %s" % CardPool.get_rarity_name(card.rarity)

		ItemType.RELIC:
			if item.has("relic_data"):
				var relic = item.relic_data
				text += "\n\n⭐ %s" % RelicSystem.get_relic_type_name(relic.type)

		ItemType.HEAL:
			var heal_amount = int(RunManager.player_max_hp * item.value)
			text += "\n\n💚 Cura: %d HP" % heal_amount

	return text

func format_price(price: int) -> String:
	"""Formatar preço para exibição"""
	return "💰 %d" % price

func get_discount_chance() -> float:
	"""Obter chance de desconto baseada em relíquias"""
	# Verificar se tem relíquias que dão desconto
	var discount = 0.0

	# Exemplo: Amuleto da Sorte poderia dar desconto
	if RunManager.has_relic("Amuleto da Sorte"):
		discount += 0.1  # 10% de desconto

	return min(discount, 0.3)  # Máximo 30% de desconto

func apply_discounts(inventory: Array) -> Array:
	"""Aplicar descontos ao inventário"""
	var discount_chance = get_discount_chance()

	if discount_chance > 0:
		for item in inventory:
			if randf() < discount_chance:
				var old_price = item.price
				item.price = int(item.price * (1.0 - discount_chance))
				item["discounted"] = true
				item["original_price"] = old_price
				print("💸 Desconto aplicado a %s: %d → %d" % [item.name, old_price, item.price])

	return inventory