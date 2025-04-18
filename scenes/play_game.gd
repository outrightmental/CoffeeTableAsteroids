extends Node2D

# Enum for whether a grid square is empty, block, or gem
enum GridType {
	EMPTY,
	BLOCK,
}
# Spawn blocks in a grid pattern, 32 blocks wide and 18 blocks tall, starting at (16, 16) and spaced 32 pixels apart
# The blocks are 32x32 pixels, so the grid is 1024x576 pixels
const BLOCK_SIZE: int             = 32
const BLOCK_CENTER: int           = BLOCK_SIZE/2
const GRID_COLS = 30
const GRID_ROWS = 16
const GRID_MARGIN = 32
const BLOCK_SHIP_CLEARANCE_RADIUS = 100
const GAP_COUNT = 8
var grid: Dictionary              = {}


# Instantiate a models/ships/ship.gd for each player, so set player_num = 1 or 2 respectively, and Player 1 is 10% in from the left, vertical center, and Player 2 is 10% in from the right, vertical center.
func _ready() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var player_1               = _spawn_player(1, Vector2(viewport_size.x * 0.1, viewport_size.y * 0.5), 0)
	var player_2               = _spawn_player(2, Vector2(viewport_size.x * 0.9, viewport_size.y * 0.5), PI)
	
	# Randomly pick locations for 3 gaps
	var gap_positions: Array[Vector2] = [player_1.position, player_2.position]
	for i in range(GAP_COUNT):
		var gap_x: int = randi() % (GRID_COLS / 2)
		var gap_y: int = randi() % GRID_ROWS
		gap_positions.append(_grid_position(gap_x, gap_y))
		gap_positions.append(_grid_position(GRID_COLS - gap_x, GRID_ROWS - gap_y))

	#	var grid_pos: Vector2
	for x in range(GRID_COLS):
		for y in range(GRID_ROWS):
			if (!grid.has(x)):
				grid[x] = {}
			if (_is_clear_of_all(BLOCK_SHIP_CLEARANCE_RADIUS, _grid_position(x, y), gap_positions)):
				grid[x][y] = GridType.BLOCK
			else:
				grid[x][y] = GridType.EMPTY

	for x in range(GRID_COLS):
		for y in range(GRID_ROWS):
			if grid[x][y] == GridType.BLOCK:
				# Spawn a block at the grid position
				# The blocks are 32x32 pixels, so the grid is 1024x576 pixels
				# The center of the block is at (BLOCK_CENTER + x * BLOCK_SIZE, BLOCK_CENTER + y * BLOCK_SIZE)
				_spawn_block(_grid_position(x, y))

	pass


func _is_clear_of_all(distance: int, source: Vector2, targets: Array[Vector2]):
	for target in targets:
		if (source.distance_to(target) < distance):
			return false
	return true


func _grid_position(x: int, y: int) -> Vector2:
	# Convert grid coordinates to world coordinates
	return Vector2(GRID_MARGIN + BLOCK_CENTER + x * BLOCK_SIZE, GRID_MARGIN + BLOCK_CENTER + y * BLOCK_SIZE)


func _spawn_player(num: int, start_position: Vector2, start_rotation: float) -> Node:
	var ship_scene: Node = preload('res://models/ships/ship.tscn').instantiate()
	ship_scene.position = start_position
	ship_scene.player_num = num
	ship_scene.rotation = start_rotation
	self.add_child(ship_scene)
	return ship_scene


func _spawn_block(start_position: Vector2) -> Node:
	var block_scene: Node = preload('res://models/blocks/block.tscn').instantiate()
	block_scene.position = start_position
	self.add_child(block_scene)
	return block_scene
