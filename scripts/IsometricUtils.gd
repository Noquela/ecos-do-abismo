extends Node

# Sistema de conversão de coordenadas isométricas
# Conforme roadmap: Funções world_to_iso() e iso_to_world()

# Ângulo isométrico padrão (30° ou 26.565°)
const ISOMETRIC_ANGLE = PI / 6  # 30 graus

# Converte input WASD para movimento diagonal isométrico
static func convert_input_to_isometric(input: Vector2) -> Vector2:
	# Roadmap: Input vector conversion para diagonal movement
	var iso_x = input.x * cos(ISOMETRIC_ANGLE) - input.y * sin(ISOMETRIC_ANGLE)
	var iso_y = input.x * sin(ISOMETRIC_ANGLE) + input.y * cos(ISOMETRIC_ANGLE)
	return Vector2(iso_x, iso_y).normalized()

# Converte coordenadas do mundo para isométricas
static func world_to_iso(world_pos: Vector2) -> Vector2:
	var iso_x = world_pos.x * cos(ISOMETRIC_ANGLE) - world_pos.y * sin(ISOMETRIC_ANGLE)
	var iso_y = world_pos.x * sin(ISOMETRIC_ANGLE) + world_pos.y * cos(ISOMETRIC_ANGLE)
	return Vector2(iso_x, iso_y)

# Converte coordenadas isométricas para o mundo
static func iso_to_world(iso_pos: Vector2) -> Vector2:
	var world_x = iso_pos.x * cos(ISOMETRIC_ANGLE) + iso_pos.y * sin(ISOMETRIC_ANGLE)
	var world_y = -iso_pos.x * sin(ISOMETRIC_ANGLE) + iso_pos.y * cos(ISOMETRIC_ANGLE)
	return Vector2(world_x, world_y)