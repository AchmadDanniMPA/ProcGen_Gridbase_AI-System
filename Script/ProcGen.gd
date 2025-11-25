extends Node2D

@onready var ground: TileMapLayer = $Ground

const SOURCE_GROUND := 0
const TILE_GROUND   := Vector2i(0, 0)

@export var size: int = 40
@export var origin: Vector2i = Vector2i(0, 0)

# Cellular Automata testv7
@export var use_ca_water: bool = true
@export var ca_initial_water_chance: float = 0.45
@export var ca_iterations: int = 5
@export var ca_birth_limit: int = 5
@export var ca_survival_limit: int = 4
@export var ca_edge_counts_as_water: bool = true
@export var seed: int = 0

var side: int
var water_mask: Array
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	side = 2 * size + 1
	_init_rng()
	generate()

func regenerate(with_new_random_seed: bool = true) -> void:
	if with_new_random_seed:
		seed = 0
	_init_rng()
	generate()

func _init_rng() -> void:
	if seed == 0:
		rng.randomize()
	else:
		rng.seed = seed

func generate() -> void:
	water_mask = []
	water_mask.resize(side)
	for y in range(side):
		var row: Array = []
		row.resize(side)
		for x in range(side):
			var w: bool = use_ca_water and (rng.randf() < ca_initial_water_chance)
			row[x] = w
		water_mask[y] = row

	if use_ca_water:
		for _i in range(ca_iterations):
			water_mask = _ca_step(water_mask, side, side)

	_paint_ground()

func _ca_step(grid: Array, w: int, h: int) -> Array:
	var out: Array = []; out.resize(h)
	for y in range(h):
		var row: Array = []; row.resize(w)
		for x in range(w):
			var n: int = _count_water_neighbors(grid, x, y, w, h)
			var is_water: bool = grid[y][x]
			row[x] = (n >= ca_survival_limit) if is_water else (n >= ca_birth_limit)
		out[y] = row
	return out

func _count_water_neighbors(grid: Array, x: int, y: int, w: int, h: int) -> int:
	var c: int = 0
	for ny in range(y - 1, y + 2):
		for nx in range(x - 1, x + 2):
			if nx == x and ny == y:
				continue
			if nx < 0 or nx >= w or ny < 0 or ny >= h:
				if ca_edge_counts_as_water:
					c += 1
			elif grid[ny][nx]:
				c += 1
	return c

func _paint_ground() -> void:
	ground.clear()
	for dy in range(-size, size + 1):
		for dx in range(-size, size + 1):
			var lx: int = dx + size
			var ly: int = dy + size
			if water_mask[ly][lx]:
				continue
			var cell: Vector2i = origin + Vector2i(dx, dy)
			ground.set_cell(cell, SOURCE_GROUND, TILE_GROUND)

#func get_water_mask() -> Array:
	#return water_mask
#
#func get_side() -> int:
	#return side
