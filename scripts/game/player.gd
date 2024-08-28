extends Node

class_name Player

#--------------------------------------
# Vars
#--------------------------------------
var body: Array[Vector2] = []
var color: Color
var tail_color: Color
var alive: bool = false
var score: Label
var human: bool = true
# Directions
enum Direction { UP, DOWN, LEFT, RIGHT, NULL}

# The last input is stored to avoid someone going UP -> DOWN killing himself
var direction = Direction.RIGHT
var new_direction = Direction.RIGHT

#--------------------------------------
# Functions
#--------------------------------------
func _process(delta):
	if not alive:
		return

	if human:
		check_inputs()


## Initialize positions and color for the cells
func initialize_player(coordinates:Array, panel_colors: Array, player_name: String, map: Map, label: Label):
	# Initializing variables
	color = panel_colors[0]
	tail_color = panel_colors[1]
	alive = true
	score = label
	name = player_name
	for coor in coordinates:
		body.append(coor)
		map.add_player_pos(coor, self)
	# Setting the score and color
	update_score()
	update_player_gradient(map)
	# Defining the direction
	if len(body) < 2:
		print("[WARNING] less than two points are used to place the snake originally")
		return
	direction = match_vector_direction(body[-1] - body[-2])
	new_direction = direction
	if direction == Direction.NULL :
		print("[WARNING] direction is NULL, the head is not direclty adjacent to the segment before")
		


## The function moving the snake returns false if the snake dies
func move_snake(map: Map) -> bool:
	if not alive:
		return false
	var snake_head: Vector2 = body[-1]
	var new_snake_pos: Vector2 = snake_head + match_direction_vector(direction)

	# Collides
	if map.check_player_collision(new_snake_pos):
		alive = false
		return false

	body.append(new_snake_pos)
	# Hits a fruit
	if map.check_fruit_collision(new_snake_pos):
		map.add_player_pos(new_snake_pos, self)
		update_score()
		update_player_gradient(map)
		return true
	map.add_player_pos(new_snake_pos, self)
	# Doesn't collide
	var tail = body.pop_front()
	map.remove_player_pos(tail, self)
	update_player_gradient(map)

	return true

## The function cleaning up the snake on the map
func clear_from_map(map: Map):
	for pos in body:
		map.remove_player_pos(pos, self)

## The function dispalying a dead snake
func display_dead_body(map: Map):
	for pos in body:
		var cell = map.get_cell(pos)
		cell.modulate = cell.color + Color(0, 0, 0, 0.5)

## A function to extract the coordinate change from a Direction
func match_direction_vector(dir: Direction) -> Vector2:
	match dir:
		Direction.UP:
			return Vector2(0, -1)
		Direction.DOWN:
			return Vector2(0, 1)
		Direction.LEFT:
			return Vector2(-1, 0)
		Direction.RIGHT:
			return Vector2(1, 0)
		Direction.NULL:
			return Vector2(0, 0)
		_:
			return Vector2(0, 0)


## A function to extract the direction change from a coordinates
func match_vector_direction(vec: Vector2) -> Direction:
	match vec:
		Vector2(0, -1):
			return Direction.UP
		Vector2(0, 1):
			return Direction.DOWN
		Vector2(-1, 0):
			return Direction.LEFT
		Vector2(1, 0):
			return Direction.RIGHT
		_:
			return Direction.NULL
		
	
## Checks for user inputs, not usefull for ai
func check_inputs():
	if Input.is_action_pressed("move_up") and direction != Direction.DOWN:
		new_direction = Direction.UP
	elif Input.is_action_pressed("move_down") and direction != Direction.UP:
		new_direction = Direction.DOWN
	elif Input.is_action_pressed("move_left") and direction != Direction.RIGHT:
		new_direction = Direction.LEFT
	elif Input.is_action_pressed("move_right") and direction != Direction.LEFT:
		new_direction = Direction.RIGHT
	direction = new_direction


## Updates the label used to display the score
func update_score():
	score.text = str(len(body))


## Updates the color for the player on the map
func update_player_gradient(map: Map):
	var colors = generate_gradient(tail_color, color, len(body))
	for i in range(len(body)):
		map.change_cell_color(body[i], colors[i])


## Function to generate a list of colors forming a gradient between two colors returns from b to a
func generate_gradient(color_a: Color, color_b: Color, steps: int) -> Array:
	var gradient_colors = []
	for i in range(steps):
		var t = float(i) / float(steps - 1)
		var lerp_color = color_a.lerp(color_b, steep_change_ease(t, 3))
		gradient_colors.append(lerp_color)

	return gradient_colors

## Eases the changes
func steep_change_ease(t: float, power: float) -> float:
	return pow(t, power)

