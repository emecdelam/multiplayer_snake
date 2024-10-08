## A class for the map data structure
class_name Map


var number_cell_x: int
var number_cell_y: int
var cell_size: Vector2
var border_size: Vector2
var panel_position: Vector2
var cell: Resource
var map: Array[Array] = []
var wall: Array[Vector2] = []
var param = Parameters.new()


## Creates the map and stores it in the map array
func create_map(parent:Node, container:Node):
	for y in range(number_cell_y):
		map.append([])

	for x in range(number_cell_x):
		for y in range(number_cell_y):
			var cell_instance: Cell = cell.instantiate()
			cell_instance.name = "cell: %s, %s" % [str(x), str(y)]
			cell_instance.size = cell_size
			cell_instance.position = panel_position + Vector2((x * (border_size.x + cell_size.x)),(y * (border_size.y + cell_size.y))) + 2 * border_size
			map[y].append(cell_instance)
			container.add_child(cell_instance)

	parent.custom_minimum_size = Vector2(
		(number_cell_x * (cell_size.x + border_size.x)) + 3 * border_size.x,
		(number_cell_y * (cell_size.y + border_size.y)) + 3 * border_size.y
	)


## Return the Cell at {pos}
func get_cell(pos: Vector2) -> Cell:
	return map[pos.y][pos.x]


## Changes the color of the cell at {pos} to {color}
func change_cell_color(pos: Vector2, color: Color):
	if pos.x >= number_cell_x or pos.x < 0 or pos.y >= number_cell_y or pos.y < 0:
		print("[WARNING] trying to change a cell outside of the map")
		return
	get_cell(pos).color = color


## Generate the {number} of walls
func generate_walls(number: int, spawns: Array):
	for i in range(number):
		# Random position in the scope
		var pos: Vector2 = Vector2(randi_range(0, number_cell_x-1), randi_range(0, number_cell_y-1))
		if is_in_spawn_region(pos, spawns):
			i-=1
			continue
		# Check if the cell has the "good" color, being empty
		if get_cell(pos).color == param.empty_cell_color:
			change_cell_color(pos, param.wall_cell_color)
			wall.append(pos)
		# Wrong color cell, if the cell is already occupied
		else:
			pass
## A function to determine if the pos in 2 block away from a player, it is optimised by taking profit of the fact that snake are colinear and adjacent
func is_in_spawn_region(pos: Vector2, spawns: Array) -> bool:
	for spawn in spawns:
		if pos in spawn:
			return true
		var start = spawn[0]
		var end = spawn[-1]
		if end.x == start.x and end.y == start.y:
			print("[WARNING] seems like a snake is of length one or as conflicting head and tail, might create error in spawn box")
		# Calculate bounds of the segment
		var min_x = min(start.x, end.x) - 2
		var max_x = max(start.x, end.x) + 2
		var min_y = min(start.y, end.y) - 2
		var max_y = max(start.y, end.y) + 2

		# Check if the point is within the expanded bounds
		if pos.x >= min_x and pos.x <= max_x and pos.y >= min_y and pos.y <= max_y:
			return true
	return false

## Generate the {number} of fruits
func generate_fruits(number: int):
	for i in range(number):
		if not generate_fruit(number_cell_x * number_cell_y):
			print("[WARNING] Couldn't generate fruit")
			continue
			
##Generate a single fruit
func generate_fruit(max_ite: int) -> bool:
	for i in range(max_ite):
		var pos: Vector2 = Vector2(randi_range(0, number_cell_x-1), randi_range(0, number_cell_y-1))
		if get_cell(pos).color == param.empty_cell_color:
			change_cell_color(pos, param.fruit_cell_color)
			return true
	return false


## Checks if at {pos} there is a wall or a border
func check_player_collision(pos: Vector2) -> bool:
	if pos.x < 0 or pos.x >= number_cell_x:
		return true
	elif pos.y < 0 or pos.y >= number_cell_y:
		return true
	var cell_color = get_cell(pos).color
	if cell_color == param.fruit_cell_color:
		return false
	if cell_color == param.wall_cell_color:
		return true
	if cell_color != param.empty_cell_color:
		return true
	return false

## Checks for fruit collisions
func check_fruit_collision(pos: Vector2) -> bool:
	if get_cell(pos).color == param.fruit_cell_color:
		generate_fruits(1)
		return true
	return false


## Changes the cell color at {pos} to the {player}.color
func add_player_pos(pos: Vector2, player: Player):
	if pos.x >= number_cell_x or pos.x < 0 or pos.y >= number_cell_y or pos.y < 0:
		print("[WARNING] trying to create a player outside of the map")
		return
	get_cell(pos).color = player.color

## Return a boolean descibing if a color is in a gradient
func is_color_between(color_a: Color, color_b: Color, target_color: Color) -> bool:
	for channel in range(3):
		var min_val = min(color_a[channel], color_b[channel])
		var max_val = max(color_a[channel], color_b[channel])
		if target_color[channel] < min_val or target_color[channel] > max_val:
			return false
	return true


## Changes the cell color at {pos} to the defautl color
func remove_player_pos(pos: Vector2, player: Player):
	if is_color_between(player.color, player.tail_color, get_cell(pos).color):
		change_cell_color(pos, param.empty_cell_color)
	else:
		print("[WARNING] trying to remove a player cell that didn't belong")

## A function to get the whole map state as a string
func dump_map_state(player_a: Player, players: Array[Player]) -> String:
	var ret = []
	var empty_color = param.empty_cell_color
	var wall_color = param.wall_cell_color
	var fruit_color = param.fruit_cell_color
	var player_color = player_a.color
	var player_tail_color = player_a.tail_color

	for y in range(number_cell_y):
		var row = []
		for x in range(number_cell_x):
			var cell_color = get_cell(Vector2(x, y)).color
			if cell_color == empty_color:
				row.append("0")
			elif cell_color == wall_color:
				row.append("2")
			elif cell_color == fruit_color:
				row.append("1")
			elif cell_color == player_color:
				row.append("*")
			elif is_color_between(player_color, player_tail_color, cell_color):
				row.append("-")
			else:
				row.append("_")
		
		ret.append(",".join(row))
	ret = ";".join(ret)
	# player head part
	ret += "|"
	var player_states = []
	for p in players:
		if p.alive:
			player_states.append(str(p.body[-1]))
	ret += ",".join(player_states)

	return ret


## Simple print of the dump
func print_map_state(player_a: Player, players: Array[Player]):
	var dump = dump_map_state(player_a, players)
	dump = dump.replace(";","\n")
	dump = dump.replace(","," ")
	print(dump)

