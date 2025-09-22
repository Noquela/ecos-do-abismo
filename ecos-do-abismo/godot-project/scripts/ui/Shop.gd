# Sprint 14 - Interface da Loja
extends Control

@onready var greeting_label = $ShopPanel/ShopContainer/GreetingLabel
@onready var player_gold_label = $ShopPanel/ShopContainer/PlayerGoldLabel
@onready var items_container = $ShopPanel/ShopContainer/ItemsContainer
@onready var leave_btn = $LeaveButton

var shop_inventory := []
var item_buttons := []

func _ready():
	print("🛒 Shop - Sprint 14: Sistema de lojas")

	# Conectar botão sair
	leave_btn.pressed.connect(_on_leave_pressed)

	# Gerar inventário da loja
	_generate_shop_inventory()

	# Atualizar interface
	_update_ui()

func _generate_shop_inventory():
	"""Gerar inventário da loja"""
	shop_inventory = ShopSystem.generate_shop_inventory()

	# Aplicar descontos se houver
	shop_inventory = ShopSystem.apply_discounts(shop_inventory)

	print("🛒 Loja carregada com %d itens" % shop_inventory.size())

func _update_ui():
	"""Atualizar interface da loja"""
	# Saudação do lojista
	greeting_label.text = ShopSystem.get_shop_greeting()

	# Moedas do jogador
	player_gold_label.text = "💰 Suas moedas: %d" % GameData.player_data.coins

	# Limpar botões de itens existentes
	for btn in item_buttons:
		btn.queue_free()
	item_buttons.clear()

	# Criar botões para cada item
	for i in range(shop_inventory.size()):
		var item = shop_inventory[i]
		var item_btn = Button.new()

		# Configurar botão
		item_btn.text = ShopSystem.get_item_display_text(item)
		item_btn.custom_minimum_size = Vector2(250, 150)
		item_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# Verificar se pode comprar
		if not ShopSystem.can_afford_item(item):
			item_btn.disabled = true
			item_btn.modulate = Color.GRAY
			item_btn.tooltip_text = "💰 Moedas insuficientes"

		# Mostrar desconto se houver
		if item.has("discounted"):
			item_btn.modulate = Color.LIGHT_GREEN
			var discount_text = "\n💸 DESCONTO! Era %d moedas" % item.original_price
			item_btn.text += discount_text

		# Conectar sinal
		item_btn.pressed.connect(_on_item_pressed.bind(i))

		items_container.add_child(item_btn)
		item_buttons.append(item_btn)

	print("🛒 Interface atualizada - %d itens disponíveis" % shop_inventory.size())

func _on_item_pressed(item_index: int):
	"""Quando um item é pressionado"""
	var item = shop_inventory[item_index]

	print("🛒 Tentando comprar: %s" % item.name)

	# Tentar comprar o item
	var result = ShopSystem.buy_item(item)

	if result.success:
		print("✅ Compra realizada: %s" % result.message)

		# Verificar se precisa de seleção de carta
		if result.has("needs_card_selection"):
			_handle_card_selection(item)
		else:
			# Mostrar mensagem de sucesso
			_show_purchase_result(result.message)

		# Remover item do inventário (não pode comprar novamente)
		shop_inventory.remove_at(item_index)

		# Atualizar interface
		_update_ui()
	else:
		print("❌ Compra falhou: %s" % result.message)
		_show_purchase_result(result.message)

func _handle_card_selection(item: Dictionary):
	"""Lidar com seleção de carta para remoção/upgrade"""
	var deck = RunManager.get_run_deck()

	if deck.is_empty():
		_show_purchase_result("❌ Seu deck está vazio!")
		return

	# Criar popup de seleção de carta
	var card_selection = _create_card_selection_popup(deck, item.type)
	add_child(card_selection)

func _create_card_selection_popup(deck: Array, operation_type: ShopSystem.ItemType) -> Control:
	"""Criar popup para seleção de carta"""
	var popup = Control.new()
	popup.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Background escuro
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.7)
	popup.add_child(bg)

	# Panel principal
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.size = Vector2(800, 600)
	panel.position = Vector2(-400, -300)
	popup.add_child(panel)

	# Container
	var container = VBoxContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 20)
	panel.add_child(container)

	# Título
	var title = Label.new()
	match operation_type:
		ShopSystem.ItemType.REMOVAL:
			title.text = "🗑️ Escolha uma carta para REMOVER"
		ShopSystem.ItemType.UPGRADE:
			title.text = "⬆️ Escolha uma carta para MELHORAR"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(title)

	# Scroll container para cartas
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(scroll)

	var cards_grid = GridContainer.new()
	cards_grid.columns = 3
	scroll.add_child(cards_grid)

	# Criar botões para cada carta
	for i in range(deck.size()):
		var card = deck[i]
		var card_btn = Button.new()
		card_btn.text = "🃏 %s\n⚡ %d energia\n%s" % [card.name, card.cost, card.description]
		card_btn.custom_minimum_size = Vector2(200, 120)
		card_btn.pressed.connect(_on_card_selected.bind(i, operation_type, popup))
		cards_grid.add_child(card_btn)

	# Botão cancelar
	var cancel_btn = Button.new()
	cancel_btn.text = "❌ Cancelar"
	cancel_btn.pressed.connect(_on_card_selection_canceled.bind(popup))
	container.add_child(cancel_btn)

	return popup

func _on_card_selected(card_index: int, operation_type: ShopSystem.ItemType, popup: Control):
	"""Quando uma carta é selecionada"""
	var deck = RunManager.get_run_deck()
	var card = deck[card_index]

	match operation_type:
		ShopSystem.ItemType.REMOVAL:
			RunManager.remove_card_from_deck(card_index)
			_show_purchase_result("🗑️ Carta '%s' removida do deck!" % card.name)

		ShopSystem.ItemType.UPGRADE:
			# Implementar upgrade de carta no futuro
			_show_purchase_result("⬆️ Carta '%s' melhorada! (Feature em desenvolvimento)" % card.name)

	popup.queue_free()

func _on_card_selection_canceled(popup: Control):
	"""Quando seleção de carta é cancelada"""
	popup.queue_free()
	_show_purchase_result("❌ Operação cancelada")

func _show_purchase_result(message: String):
	"""Mostrar resultado da compra"""
	print("📢 %s" % message)

	# Criar label temporário para mostrar resultado
	var result_label = Label.new()
	result_label.text = message
	result_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	result_label.position.y = 50
	result_label.modulate = Color.YELLOW
	add_child(result_label)

	# Remover após 3 segundos
	await get_tree().create_timer(3.0).timeout
	if result_label and is_instance_valid(result_label):
		result_label.queue_free()

func _on_leave_pressed():
	"""Sair da loja"""
	print("🚪 Saindo da loja...")

	# Completar node se estivermos em uma run
	if RunManager.current_run_active:
		RunManager.complete_current_node()

	# Salvar progresso
	GameData.save_game()

	# Voltar ao mapa ou hub
	if RunManager.current_run_active:
		get_tree().change_scene_to_file("res://scenes/ui/RunMap.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ui/Hub.tscn")