extends Node2D

# Debug Grid Isométrico - Sprint 1
# Roadmap: Debug visual adaptado para perspectiva isométrica

func _draw():
	print("[IsometricDebugGrid] Drawing isometric reference grid")

	# Grid isométrico para validação visual
	var grid_size = 100
	var grid_range = 10

	for x in range(-grid_range, grid_range + 1):
		for y in range(-grid_range, grid_range + 1):
			var world_pos = Vector2(x * grid_size, y * grid_size)
			var iso_pos = IsometricUtils.world_to_iso(world_pos)

			# Desenhar pontos de grid em coordenadas isométricas
			var color = Color.WHITE
			if x == 0 and y == 0:
				color = Color.RED  # Origem
			elif x == 0 or y == 0:
				color = Color.GREEN  # Eixos

			# Desenhar losango pequeno para cada ponto
			var diamond_points = PackedVector2Array([
				iso_pos + Vector2(0, -5),
				iso_pos + Vector2(8, 0),
				iso_pos + Vector2(0, 5),
				iso_pos + Vector2(-8, 0)
			])

			draw_colored_polygon(diamond_points, color)

func _ready():
	print("[IsometricDebugGrid] Isometric grid system initialized")