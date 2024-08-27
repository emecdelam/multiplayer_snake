extends Node2D

#--------------------------------------
# EXPORTS
#--------------------------------------
@export var cell_size: Vector2 = Vector2(20, 20)
@export var border_size: Vector2 = Vector2(5, 5)
@export var number_cell_x: int = 35
@export var number_cell_y: int = 25
@export var human_game: bool = true
@export var players: Array[Player]
@export var number_fruits: int = 5
#--------------------------------------
# ONREADY
#--------------------------------------
@onready var panel_position: Vector2 = position
@onready var cell: Resource = preload("res://scenes/cell.tscn")

#--------------------------------------
# GLOBAL VAR
#--------------------------------------
var map: Map = Map.new()
var timer: Timer

var param: Parameters = Parameters.new()


#--------------------------------------
# Default functions
#--------------------------------------
func _ready():
	create_map()
	create_player()
	timer  = get_parent().get_node("Timer")



func _process(delta):
	if timer.is_stopped():
		for player in players:
			var dead = player.move_snake(map)
			if not dead:
				print("player died")
		timer.start()
	


#--------------------------------------
# Custom functions
#--------------------------------------


## Creates the map
func create_map():
	map.number_cell_x = number_cell_x
	map.number_cell_y = number_cell_y
	map.cell_size = cell_size
	map.border_size = border_size
	map.panel_position = panel_position
	map.cell = cell
	map.create_map(get_parent(), self)
	map.generate_fruits(number_fruits)


## Creates the players
func create_player():
	for col in param.player_colors:
		var player = Player.new()
		player.initialize_player([Vector2(5,5),Vector2(6,5),Vector2(7,5)],col, map)
		players.append(player)
		add_child(player)

