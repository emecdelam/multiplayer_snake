extends Node2D

@export var cell_size:Vector2 = Vector2(20, 20)
@export var border_size:Vector2 = Vector2(5, 5)
@export var number_cell_x:int = 35
@export var number_cell_y:int = 25
@export var tick_rate:int = 20
@export var fruit_style:StyleBoxFlat
@export var food_rate:int = 200

var started = false
@onready var tick_count = 0
@onready var cell = preload("res://scenes/cell.tscn")
@onready var panel_position = get_parent().position
var map:Array = []

func __var_setup():
	fruit_style = StyleBoxFlat.new()
	fruit_style.bg_color = Color(0.678, 0.239, 0.090)

func __add_fruit(pos:Vector2):
	var fruit_cell = map[pos.y][pos.x]
	fruit_cell.remove_theme_stylebox_override("panel")
	fruit_cell.add_theme_stylebox_override("panel", fruit_style)

func __generate_random_fruits():
	var rng = RandomNumberGenerator.new()
	return Vector2(rng.randi_range(0, number_cell_x - 1), rng.randi_range(0, number_cell_y - 1))

func _ready():
	__var_setup()
	create_map()

func create_map():
	for y in range(number_cell_y):
		map.append([])

	for x in range(number_cell_x):
		for y in range(number_cell_y):
			var cell_instance = cell.instantiate()
			cell_instance.size = cell_size
			cell_instance.position = panel_position + Vector2((x * (border_size.x + cell_size.x)),(y * (border_size.y + cell_size.y))) + 2 * border_size
			map[y].append(cell_instance)  # Add the cell_instance to the corresponding row
			self.add_child(cell_instance)

	get_parent().custom_minimum_size = Vector2(
		(number_cell_x * (cell_size.x + border_size.x)) + 3 * border_size.x,
		(number_cell_y * (cell_size.y + border_size.y)) + 3 * border_size.y
	)

func _process(delta):
	if not started:
		return
	tick_count += 1
	if (tick_count == food_rate):
		tick_count = 0
		__add_fruit(__generate_random_fruits())


func clear_map():
	for x in range(number_cell_x):
		for y in range(number_cell_y):
			map[y][x].queue_free()
	map = []
	create_map()
	__add_fruit(__generate_random_fruits())

func _on_button_toggled(toggled_on:bool):

	started = toggled_on
	if started:
		clear_map()
		tick_count = 0
	
		
