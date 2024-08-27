extends Node2D

@export var cell_size:Vector2 = Vector2(20, 20)
@export var border_size:Vector2 = Vector2(5, 5)
@export var number_cell_x:int = 35
@export var number_cell_y:int = 25
@export var tick_rate:int = 20
@export var fruit_style:StyleBoxFlat

@onready var tickCount = 0
@onready var playerA = preload("res://player.gd")
var map:Array = []

func __var_setup():
	fruit_style = StyleBoxFlat.new()
	fruit_style.bg_color = Color(0.678, 0.239, 0.090)

func __add_fruit(pos:Vector2):
	var cell = map[pos.y][pos.x]
	cell.remove_theme_stylebox_override("panel")
	cell.add_theme_stylebox_override("panel", fruit_style)

func __generate_random_fruits():
	var rng = RandomNumberGenerator.new()
	return Vector2(rng.randi_range(0, number_cell_x - 1), rng.randi_range(0, number_cell_y - 1))

func _ready():
	__var_setup()
	var panelPosition = get_parent().position
	var cell = preload("res://cell.tscn")

	for y in range(number_cell_y):
		map.append([])

	for x in range(number_cell_x):
		for y in range(number_cell_y):
			var cellInstance = cell.instantiate()
			cellInstance.size = cell_size
			cellInstance.position = panelPosition + Vector2(
				(x * (border_size.x + cell_size.x)),
				(y * (border_size.y + cell_size.y))
			) + 2 * border_size
			map[y].append(cellInstance)  # Add the cellInstance to the corresponding row
			self.add_child(cellInstance)

	get_parent().custom_minimum_size = Vector2(
		(number_cell_x * (cell_size.x + border_size.x)) + 3 * border_size.x,
		(number_cell_y * (cell_size.y + border_size.y)) + 3 * border_size.y
	)


func _process(delta):
	tickCount += 1
	if (tickCount == tick_rate):
		tickCount = 0
		#__add_fruit(__generate_random_fruits())



func color_cell(position:Vector2, color:Color):
	var panel:Panel = map[position.y][position.x]
	var style = StyleBoxFlat.new()
	style.bg_color = color
	panel.add_theme_stylebox_override("panel", style)
	#panel.theme.set_color(color)
	#map[position.y][position.x].
