extends Node2D

func _draw():
	# Draw a grid of reference points in the world
	# These points stay fixed, so when player moves you'll see them moving relative to camera

	# Draw origin marker (big red cross)
	draw_line(Vector2(-50, 0), Vector2(50, 0), Color.RED, 4)
	draw_line(Vector2(0, -50), Vector2(0, 50), Color.RED, 4)

	# Draw grid markers every 100 pixels
	for x in range(-10, 11):
		for y in range(-10, 11):
			var pos = Vector2(x * 100, y * 100)

			if pos == Vector2.ZERO:
				continue  # Skip origin (already drawn)

			# Different colors for different distances
			var color = Color.WHITE
			var dist = pos.length()
			if dist < 200:
				color = Color.CYAN
			elif dist < 400:
				color = Color.GREEN
			else:
				color = Color.BLUE

			# Draw small cross at each grid point
			draw_line(pos + Vector2(-10, 0), pos + Vector2(10, 0), color, 2)
			draw_line(pos + Vector2(0, -10), pos + Vector2(0, 10), Color.WHITE, 2)

func _ready():
	print("[WorldMarkers] Grid markers created - you should see them move when player moves!")