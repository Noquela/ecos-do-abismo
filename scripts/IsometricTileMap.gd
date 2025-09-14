extends TileMap

# Sistema de TileMap Isométrico - Sprint 4
# Tiles em formato diamante para perspectiva isométrica

# Configurações isométricas
const TILE_SIZE = Vector2i(64, 32)  # Tamanho isométrico padrão
const ISOMETRIC_ANGLE = 30.0  # Graus

# Tipos de tiles
enum TileType {
	FLOOR,
	WALL,
	PILLAR,
	DECORATION
}

# Layer assignments conforme project.godot
const COLLISION_LAYER = 4  # Environment layer

func _ready():
	print("[IsometricTileMap] Initializing isometric tile system")
	setup_isometric_tilemap()
	generate_basic_room()
	setup_camera_bounds()

func setup_isometric_tilemap():
	# Configurar TileMap para perspectiva isométrica
	tile_set = create_isometric_tileset()

	# Z-index para rendering order
	z_index = -10  # Background

	print("[IsometricTileMap] Isometric tilemap configured")

func create_isometric_tileset() -> TileSet:
	var tileset = TileSet.new()

	# Configurar para tiles isométricos
	tileset.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	tileset.tile_size = TILE_SIZE

	# Criar source básico para placeholders
	var source = TileSetAtlasSource.new()
	source.texture = create_placeholder_texture()
	source.texture_region_size = TILE_SIZE

	# Adicionar tiles básicos
	create_floor_tile(source, Vector2i(0, 0))
	create_wall_tile(source, Vector2i(1, 0))
	create_pillar_tile(source, Vector2i(2, 0))

	tileset.add_source(source, 0)
	return tileset

func create_placeholder_texture() -> ImageTexture:
	# Criar textura placeholder para tiles isométricos
	var image = Image.create(192, 96, false, Image.FORMAT_RGBA8)

	# Floor tile (0,0) - Cinza claro
	draw_diamond_on_image(image, Vector2i(0, 0), Color.LIGHT_GRAY)

	# Wall tile (1,0) - Cinza escuro
	draw_diamond_on_image(image, Vector2i(64, 0), Color.DARK_GRAY)

	# Pillar tile (2,0) - Marrom
	draw_diamond_on_image(image, Vector2i(128, 0), Color.SADDLE_BROWN)

	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func draw_diamond_on_image(image: Image, offset: Vector2i, color: Color):
	# Desenhar tile em formato diamante para perspectiva isométrica
	var center_x = offset.x + TILE_SIZE.x / 2
	var center_y = offset.y + TILE_SIZE.y / 2

	# Pontos do diamante isométrico
	var points = [
		Vector2i(center_x, offset.y),                    # Top
		Vector2i(offset.x + TILE_SIZE.x, center_y),      # Right
		Vector2i(center_x, offset.y + TILE_SIZE.y),      # Bottom
		Vector2i(offset.x, center_y)                     # Left
	]

	# Preencher diamante
	for y in range(offset.y, offset.y + TILE_SIZE.y):
		for x in range(offset.x, offset.x + TILE_SIZE.x):
			if is_point_in_diamond(Vector2i(x, y), points):
				image.set_pixel(x, y, color)

func is_point_in_diamond(point: Vector2i, diamond_points: Array) -> bool:
	# Verificar se ponto está dentro do diamante
	var center = Vector2i(
		(diamond_points[0].x + diamond_points[2].x) / 2,
		(diamond_points[0].y + diamond_points[2].y) / 2
	)

	# Usar distância simples para formato diamante
	var dx = abs(point.x - center.x)
	var dy = abs(point.y - center.y)

	return (dx / float(TILE_SIZE.x / 2)) + (dy / float(TILE_SIZE.y / 2)) <= 1.0

func create_floor_tile(source: TileSetAtlasSource, atlas_coords: Vector2i):
	# Tile de chão - sem colisão
	source.create_tile(atlas_coords)

func create_wall_tile(source: TileSetAtlasSource, atlas_coords: Vector2i):
	# Tile de parede - com colisão simples
	source.create_tile(atlas_coords)

func create_pillar_tile(source: TileSetAtlasSource, atlas_coords: Vector2i):
	# Tile de pilar - com colisão simples
	source.create_tile(atlas_coords)

func generate_basic_room():
	# Gerar layout básico de sala para teste
	var room_size = Vector2i(15, 10)

	# Limpar mapa
	clear()

	# Desenhar chão
	for x in range(-room_size.x/2, room_size.x/2):
		for y in range(-room_size.y/2, room_size.y/2):
			set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))  # Floor tile

	# Desenhar paredes externas
	for x in range(-room_size.x/2, room_size.x/2):
		set_cell(0, Vector2i(x, -room_size.y/2), 0, Vector2i(1, 0))  # Top wall
		set_cell(0, Vector2i(x, room_size.y/2 - 1), 0, Vector2i(1, 0))  # Bottom wall

	for y in range(-room_size.y/2, room_size.y/2):
		set_cell(0, Vector2i(-room_size.x/2, y), 0, Vector2i(1, 0))  # Left wall
		set_cell(0, Vector2i(room_size.x/2 - 1, y), 0, Vector2i(1, 0))  # Right wall

	# Adicionar alguns pilares para teste
	set_cell(0, Vector2i(-3, -2), 0, Vector2i(2, 0))  # Pillar
	set_cell(0, Vector2i(3, 2), 0, Vector2i(2, 0))   # Pillar
	set_cell(0, Vector2i(-3, 2), 0, Vector2i(2, 0))  # Pillar
	set_cell(0, Vector2i(3, -2), 0, Vector2i(2, 0))  # Pillar

	print("[IsometricTileMap] Basic room generated with isometric tiles")

func get_tile_world_position(tile_coords: Vector2i) -> Vector2:
	# Converter coordenadas de tile para posição mundial isométrica
	return map_to_local(tile_coords)

func get_world_tile_position(world_pos: Vector2) -> Vector2i:
	# Converter posição mundial para coordenadas de tile isométrico
	return local_to_map(world_pos)

func setup_camera_bounds():
	# Configurar bounds da câmera baseado no tamanho da sala
	var camera = get_node("../IsometricCamera") as Camera2D
	if camera and camera.has_method("set_room_bounds"):
		# Calcular bounds baseado nos tiles gerados
		var room_bounds = Rect2(-480, -320, 960, 640)  # Baseado na sala 15x10
		camera.set_room_bounds(room_bounds)