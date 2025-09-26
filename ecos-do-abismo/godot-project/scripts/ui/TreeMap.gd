# Sistema de mapa visual em árvore - Inspirado em Slay the Spire
extends Control
class_name TreeMap

signal node_selected(node_data: Dictionary)

var nodes: Array = []
var lines: Array[Line2D] = []
var map_data: Array = []

@onready var nodes_container = $NodesContainer
@onready var lines_container = $LinesContainer

const LAYER_HEIGHT = 120
const NODE_SPACING = 100
const MAP_HEIGHT = 7  # 7 layers como no sistema atual

func generate_tree_map(floor_data: Array):
	"""Gerar mapa visual em árvore"""
	print("🌳 TreeMap: Gerando mapa com %d layers" % floor_data.size())
	map_data = floor_data
	_clear_existing_map()
	_generate_node_positions()
	_create_connections()
	_update_availability()
	print("🌳 TreeMap: Mapa gerado com %d nodes" % nodes.size())

func _clear_existing_map():
	"""Limpar mapa existente"""
	for node in nodes:
		if is_instance_valid(node):
			node.queue_free()
	for line in lines:
		if is_instance_valid(line):
			line.queue_free()
	nodes.clear()
	lines.clear()

func _generate_node_positions():
	"""Gerar posições dos nodes em formato de árvore"""
	var tree_map_scene = preload("res://scenes/ui/TreeMapNode.tscn")

	# Wait for ready to get proper size
	if not nodes_container:
		await ready

	for layer_index in range(map_data.size()):
		var layer = map_data[layer_index]
		var y_pos = layer_index * LAYER_HEIGHT + 50

		# Usar tamanho fixo ao invés de size dinâmico
		var map_width = 800  # Largura fixa
		var node_count = layer.size()

		print("🌳 Layer %d: %d nodes" % [layer_index, node_count])

		for node_index in range(layer.size()):
			var node_data = layer[node_index]

			# Criar node visual
			var tree_node = tree_map_scene.instantiate()

			# Calcular posição baseada na distribuição uniforme
			var x_pos = 100  # Margem esquerda
			if node_count > 1:
				var spacing = (map_width - 200) / (node_count - 1)  # 200 = margens esquerda + direita
				x_pos += node_index * spacing
			else:
				x_pos = map_width / 2 - 40  # Centralizar se só tem 1 node

			tree_node.position = Vector2(x_pos, y_pos)
			print("🌳 Node %d-%d posicionado em (%d, %d)" % [layer_index, node_index, x_pos, y_pos])

			# Configurar node
			tree_node.setup_node(node_data)
			tree_node.node_selected.connect(_on_node_selected)

			# Adicionar à cena
			nodes_container.add_child(tree_node)
			nodes.append(tree_node)

			# Armazenar referência no data
			node_data["visual_node"] = tree_node
			node_data["layer"] = layer_index
			node_data["index"] = node_index

func _create_connections():
	"""Criar conexões visuais entre nodes"""
	for layer_index in range(map_data.size() - 1):
		var current_layer = map_data[layer_index]
		var next_layer = map_data[layer_index + 1]

		for current_node_data in current_layer:
			var current_visual = current_node_data.get("visual_node")
			if not current_visual:
				continue

			# Conectar com nodes da próxima layer
			var connections = current_node_data.get("connections", [])
			for connection_index in connections:
				if connection_index < next_layer.size():
					var target_node_data = next_layer[connection_index]
					var target_visual = target_node_data.get("visual_node")

					if target_visual:
						# Criar linha visual
						_create_connection_line(current_visual, target_visual)
						# Adicionar conexão lógica
						current_visual.add_connection(target_visual)

func _create_connection_line(from_node, to_node):
	"""Criar linha visual entre dois nodes"""
	var line = Line2D.new()
	line.width = 3.0
	line.default_color = Color(0.4, 0.4, 0.6, 0.8)
	line.z_index = -1

	# Calcular pontos da linha
	var start_pos = from_node.position + Vector2(40, 40)  # Centro do node
	var end_pos = to_node.position + Vector2(40, 40)

	line.add_point(start_pos)
	line.add_point(end_pos)

	lines_container.add_child(line)
	lines.append(line)

func _update_availability():
	"""Atualizar disponibilidade dos nodes baseado no progresso"""
	var current_layer = RunManager.get_current_layer()
	var completed_nodes = RunManager.get_completed_nodes()

	print("🎯 Atualizando disponibilidade - Layer atual: %d" % current_layer)

	for layer_index in range(map_data.size()):
		var layer = map_data[layer_index]

		for node_data in layer:
			var visual_node = node_data.get("visual_node")
			if not visual_node:
				continue

			var node_id = "%d_%d" % [layer_index, node_data.get("index", 0)]

			# Verificar se está completado
			var is_completed = node_id in completed_nodes
			visual_node.set_completed(is_completed)

			# Verificar disponibilidade
			var is_available = false
			if layer_index == 0:
				# Primeira layer sempre disponível
				is_available = not is_completed
				print("🎯 Layer 0 node: disponível=%s, completado=%s" % [is_available, is_completed])
			elif layer_index == current_layer:
				# Layer atual - verificar se tem conexão com node completado
				is_available = _is_node_reachable(node_data) and not is_completed
				print("🎯 Layer atual (%d) node: disponível=%s" % [layer_index, is_available])
			elif layer_index < current_layer:
				# Layers anteriores - completadas
				is_available = false

			visual_node.set_availability(is_available)

func _is_node_reachable(node_data: Dictionary) -> bool:
	"""Verificar se um node é acessível baseado nas conexões"""
	var layer_index = node_data.get("layer", 0)
	if layer_index == 0:
		return true

	var completed_nodes = RunManager.get_completed_nodes()
	var previous_layer = map_data[layer_index - 1]

	# Verificar se algum node da layer anterior que conecta a este foi completado
	for prev_node_data in previous_layer:
		var prev_node_id = "%d_%d" % [layer_index - 1, prev_node_data.get("index", 0)]
		if prev_node_id in completed_nodes:
			var connections = prev_node_data.get("connections", [])
			if node_data.get("index", 0) in connections:
				return true

	return false

func _on_node_selected(node_data: Dictionary):
	"""Handle seleção de node"""
	node_selected.emit(node_data)

func highlight_current_position():
	"""Destacar posição atual do jogador"""
	var current_position = RunManager.get_current_position()

	for node in nodes:
		var is_current = (node.node_data.get("layer") == current_position.get("layer") and
						 node.node_data.get("index") == current_position.get("index"))
		node.set_current(is_current)