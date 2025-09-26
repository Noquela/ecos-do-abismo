# Node visual para mapa em árvore - Estilo Slay the Spire
extends Button
class_name TreeMapNode

signal node_selected(node_data: Dictionary)

var node_data: Dictionary
var connections: Array = []
var is_available: bool = false
var is_completed: bool = false
var is_current: bool = false

@onready var background = $Background
@onready var icon_label = $Icon
@onready var node_label = $Label

func setup_node(data: Dictionary):
	"""Configurar node com dados"""
	node_data = data

	# Wait for _ready if nodes aren't available yet
	if not icon_label:
		await ready

	# Configurar visual baseado no tipo
	match data.get("type", "combat"):
		"combat":
			if icon_label:
				icon_label.text = "⚔️"
			if background:
				background.color = Color(0.8, 0.3, 0.3, 0.8)  # Vermelho
		"elite":
			if icon_label:
				icon_label.text = "👹"
			if background:
				background.color = Color(0.9, 0.5, 0.2, 0.8)  # Laranja
		"campfire":
			if icon_label:
				icon_label.text = "🔥"
			if background:
				background.color = Color(0.3, 0.7, 0.3, 0.8)  # Verde
		"treasure":
			if icon_label:
				icon_label.text = "💰"
			if background:
				background.color = Color(1.0, 0.8, 0.2, 0.8)  # Dourado
		"shop":
			if icon_label:
				icon_label.text = "🛒"
			if background:
				background.color = Color(0.4, 0.4, 0.8, 0.8)  # Azul
		"mystery":
			if icon_label:
				icon_label.text = "❓"
			if background:
				background.color = Color(0.6, 0.3, 0.8, 0.8)  # Roxo
		"boss":
			if icon_label:
				icon_label.text = "💀"
			if background:
				background.color = Color(0.2, 0.2, 0.2, 0.9)  # Preto

	if node_label:
		node_label.text = data.get("name", "Node")
	_update_visual_state()

func set_availability(available: bool):
	"""Definir se o node está disponível"""
	is_available = available
	_update_visual_state()

func set_completed(completed: bool):
	"""Definir se o node foi completado"""
	is_completed = completed
	_update_visual_state()

func set_current(current: bool):
	"""Definir se é o node atual"""
	is_current = current
	_update_visual_state()

func _update_visual_state():
	"""Atualizar estado visual do node"""
	if is_current:
		background.color.a = 1.0
		modulate = Color(1.2, 1.2, 1.0)  # Destaque dourado
		z_index = 10
	elif is_completed:
		background.color.a = 0.5
		modulate = Color(0.7, 0.7, 0.7)  # Acinzentado
	elif is_available:
		background.color.a = 0.8
		modulate = Color.WHITE
		z_index = 5
	else:
		background.color.a = 0.3
		modulate = Color(0.5, 0.5, 0.5)  # Muito escuro
		z_index = 1

func add_connection(target_node):
	"""Adicionar conexão com outro node"""
	if target_node not in connections:
		connections.append(target_node)


func _ready():
	# Conectar sinal de pressed do Button
	pressed.connect(_on_button_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	print("🔘 TreeMapNode (Button) criado e pronto para input")

func _on_button_pressed():
	"""Handle button press"""
	print("🖱️ Button pressionado! Disponível: %s" % is_available)
	if is_available:
		print("✅ Emitindo node_selected para node: %s" % node_data.get("name", "Unknown"))
		node_selected.emit(node_data)
	else:
		print("❌ Node não disponível para seleção")

func _on_mouse_entered():
	"""Visual feedback no hover"""
	if is_available:
		scale = Vector2(1.1, 1.1)

func _on_mouse_exited():
	"""Reset visual feedback"""
	scale = Vector2(1.0, 1.0)