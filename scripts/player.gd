extends Node

class_name Player

#--------------------------------------
# Vars
#--------------------------------------
var body: Array[Vector2] = []
var color: Color
var alive: bool = false
var score: Label
# Directions
enum Direction { UP, DOWN, LEFT, RIGHT }

# The last input is stored to avoid someone going UP -> DOWN killing himself
var direction = Direction.RIGHT
var new_direction = Direction.RIGHT

#--------------------------------------
# Functions
#--------------------------------------

func _process(_delta):
	check_inputs()


## Initialize positions and color for the cells
func initialize_player(coordinates:Array, panel_color: Color, map: Map, label:Label):
	color = panel_color
	alive = true
	score = label
	for coor in coordinates:
		body.append(coor)
		map.add_player_pos(coor, self)
	update_score()



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
		return true
	map.add_player_pos(new_snake_pos, self)
	# Doesn't collide
	var tail = body.pop_front()
	map.remove_player_pos(tail, self)
	return true

	


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
		_:
			return Vector2(0, 0)


## Checks for user inputs, not usefull
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