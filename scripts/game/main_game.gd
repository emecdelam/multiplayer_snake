extends Node2D

#--------------------------------------
# EXPORTS
#--------------------------------------
@export var cell_size: Vector2 = Vector2(20, 20)
@export var border_size: Vector2 = Vector2(5, 5)
@export var number_cell_x: int = 35
@export var number_cell_y: int = 25
@export var players: Array[Player]
@export var number_fruits: int = 5
@export var number_walls: int = 10
@export var player_length: int = 3
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
var spawn_regions: Array
var param: Parameters = Parameters.new()


#--------------------------------------
# Default functions
#--------------------------------------
func _ready():
	# Initialize display
	%name.text = param.player_names[0]
	%name_2.text = param.player_names[1]
	%score.add_to_group("score_labels")
	%score.add_theme_color_override("font_color",param.player_colors[0][0])
	if len(param.player_colors) > 1:
		%score_2.add_to_group("score_labels")
		%score_2.add_theme_color_override("font_color",param.player_colors[1][0])
	else :
		print("[WARNING] only updating score for one player")


	create_map()
	create_player()
	timer  = get_parent().get_node("Timer")
	map.generate_walls(number_walls)
	map.print_map_state(players[0],players)

	


func _process(_delta):
	if not timer.is_stopped():
		return
	for player in players:
		if not player.alive:
			return
	for player in players:
		var alive = player.move_snake(map)
		if alive:
			continue
		handle_death_player(player)
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
	var labels = get_tree().get_nodes_in_group("score_labels")
	if len(labels) < len(param.player_colors):
		print("[WARNING] there are less labels than players colors")
	for i in range(len(param.player_colors)):
		var player = Player.new()
		player.initialize_player(param.spawns[i],param.player_colors[i], param.player_names[i], map, labels[i])
		players.append(player)
		add_child(player)



## Handles the death of any player
func handle_death_player(player: Player):
	print("[INFO] Player died : "+player.name)
	player.display_dead_body(map)
