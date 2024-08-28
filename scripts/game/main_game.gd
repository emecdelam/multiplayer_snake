extends Node2D

#--------------------------------------
# EXPORTS
#--------------------------------------
@export var cell_size: Vector2 = Vector2(20, 20)
@export var border_size: Vector2 = Vector2(5, 5)
@export var number_cell_x: int = 35
@export var number_cell_y: int = 25

@export var number_fruits: int = 5
@export var number_walls: int = 0
@export var player_length: int = 3
#--------------------------------------
# ONREADY
#--------------------------------------
@onready var panel_position: Vector2 = position
@onready var cell: Resource = preload("res://scenes/cell.tscn")
@onready var console: ServerConsole = %console
#--------------------------------------
# GLOBAL VAR
#--------------------------------------
var map := Map.new()
var timer: Timer
var spawns: Array[Array]
var players: Array[Player]
var servers: Array[Server]
var param := Parameters.new()
var thread_manager := ThreadManager.new(param.number_of_players)
var connections: Array[bool] = []

#--------------------------------------
# Default functions
#--------------------------------------
func _ready():
	# Initialize display
	%name.text = param.player_names[0]
	%name_2.text = param.player_names[1]
	%score.add_to_group("score_labels")
	%score.add_theme_color_override("font_color",param.player_colors[0][0])
	if param.number_of_players > 1:
		%score_2.add_to_group("score_labels")
		%score_2.add_theme_color_override("font_color",param.player_colors[1][0])
	else :
		%score_2.get_parent().hide()
		print("[WARNING] only updating score for one player")
	# Initialize map
	spawns = create_spawns(param.number_of_players)
	create_map()
	create_player()
	create_servers()
	timer  = get_parent().get_node("Timer")
	map.generate_walls(number_walls, spawns)
	

	


func _process(_delta):
	for i in connections:
		if not i: # Checks that every node is connected
			return
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
	if len(labels) < param.number_of_players:
		print("[WARNING] there are less labels than players colors")
	for i in range(param.number_of_players):
		var player = Player.new()
		player.initialize_player(spawns[i],param.player_colors[i], param.player_names[i], map, labels[i])
		players.append(player)
		add_child(player)

## Create websocket servers for every player
func create_servers():
	var available_ports = []
	for port in range(34001, 34196 + 1):
		available_ports.append(port)
	available_ports.shuffle()
	for i in range(param.number_of_players):
		var server = Server.new()
		randi_range(34001, 34196)
		if not server.initialize_server(available_ports.pop_front(), self, players[i], console):
			print("[WARNING] Failed to initialize a server at index : "+str(i))
		servers.append(server)
		connections.append(false)

## Function to update the array of connected servers
func update_connection(server: Server):
	for i in range(len(servers)):
		if servers[i].PORT == server.PORT:
			connections[i] = server.connected
			break


## Generates random spawn points for the {number} of players
func create_spawns(number: int) -> Array[Array]:
	var ret: Array[Array] = []
	for player in range(number):
		var player_spawn: Array = []
		var initial_x: int
		var initial_y: int
		var direction: int
		var magnitude: int

		# Loop until a valid spawn is generated
		for i in range(50):
			if i == 49:
				print("[WARNING] No spawn points found, are there too many players")
			player_spawn.clear()
			initial_x = randi_range(player_length + 1, number_cell_x - 2 - player_length)
			initial_y = randi_range(player_length + 1, number_cell_y - 2 - player_length)
			direction = randi_range(0, 1)  # 0 || 1
			magnitude = (2 * randi_range(0, 1)) - 1  # from 0 || 1 to -1 || 1
			# if direction = 0, abs(direction-1) = 1 and only the x gets moved in the magnitude direction
			# if direction = 1, abs(direction-1) = 0 and only the y gets moved in the magnitude direction
			# we go from -player_length/2 to ... to use the facte that the player_length can be used as a bounding box
			for point in range(-player_length/2 ,1 + player_length/2, 1):
				var x = initial_x + (point * magnitude) * abs(direction - 1)
				var y = initial_y + (point * magnitude) * abs(direction)
				player_spawn.append(Vector2(x, y))


			if not is_in_spawn_region(Vector2(initial_x, initial_y), ret, player_length):
				break  # Exit the loop if the spawn is valid


		ret.append(player_spawn)
	return ret

## A helper function to determine if the pos in 2 block away from a player, it is optimised by taking profit of the fact that snake are colinear and adjacent
func is_in_spawn_region(pos: Vector2, used_spawns: Array, distance: int) -> bool:
	for spawn in used_spawns:
		if pos in spawn:
			return true
		var start = spawn[0]
		var end = spawn[-1]
		if end.x == start.x and end.y == start.y:
			print("[WARNING] seems like a snake is of length one or as conflicting head and tail, might create error in spawn box")

		var min_x = min(start.x, end.x) - distance
		var max_x = max(start.x, end.x) + distance
		var min_y = min(start.y, end.y) - distance
		var max_y = max(start.y, end.y) + distance

		if pos.x >= min_x and pos.x <= max_x and pos.y >= min_y and pos.y <= max_y:
			return true
	return false


## Handles the death of any player
func handle_death_player(player: Player):
	print("[INFO] Player died : "+player.name)
	player.display_dead_body(map)
	
