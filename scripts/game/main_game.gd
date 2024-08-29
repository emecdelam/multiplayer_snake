extends Node2D

class_name Game
#--------------------------------------
# EXPORTS
#--------------------------------------
@export var cell_size: Vector2 = Vector2(20, 20)
@export var border_size: Vector2 = Vector2(5, 5)
@export var number_cell_x: int = 35
@export var number_cell_y: int = 25

@export var number_fruits: int = 25
@export var number_walls: int = 100
@export var player_length: int = 3
#--------------------------------------
# ONREADY
#--------------------------------------
@onready var panel_position: Vector2 = position
@onready var cell: Resource = preload("res://scenes/cell.tscn")
@onready var player_display = preload("res://scenes/player_display.tscn")
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
var dead_count: int = 0
#--------------------------------------
# Default functions
#--------------------------------------
func _init():
	pass

func _ready():
	# Initialize display
	create_score_displays()

	# Game related starts
	spawns = create_spawns(param.number_of_players)
	create_map()
	create_player()
	timer  = get_parent().get_node("timer")
	map.generate_walls(number_walls, spawns)
	# Connection related starts
	create_servers()
	start_threads()
	

	


func _process(_delta):
	if param.number_of_players < 1:
		print("[WARNING] No player found")
		return

	if not timer.is_stopped(): # Check for game ticks
		return

	if dead_count == param.number_of_players:
		return

	if dead_count == param.number_of_players -1 and param.number_of_players > 1: # 1 winner
		dead_count += 1
		clean_game() # killing the last player
		return

	if connections.count(false) != dead_count: # players not connected but game initialized
		return

	
	for player in players:
		player.move_snake(map, self)

		
	for i in range(len(servers)):
		servers[i].send_message(map.dump_map_state(players[i], players))
		#print(map.dump_map_state(players[i],players))
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


## Create the displays for the players
func create_score_displays():
	for i in range(param.number_of_players):
		var display = player_display.instantiate()
		var player_name = display.get_node("player_margin/player_v_container/name")
		player_name.text = param.player_names[i]
		player_name.add_theme_color_override("font_color",param.player_colors[i][0])
		var score = display.get_node("player_margin/player_v_container/score")
		score.add_to_group("score_labels")
		score.add_theme_color_override("font_color",param.player_colors[i][0])
		%display_v_container.add_child(display)

	

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

## Function to create the porcesses related to the threads
func start_threads():
	for i in range(param.number_of_players):
		var args = param.player_exec[i][1]
		args.append(servers[i].PORT)
		thread_manager.execute(i, param.player_exec[i][0], args)



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
	dead_count += 1
	print("[INFO] Player died : "+player.name)
	for server in servers:
		if server.player == player:
			server.log_message("[STOP] Stopped connection")
			server._exit_tree()
			update_connection(server)

	



## Function called when there is only one survivir
func clean_game():
	for i in range(len(servers)):
		if servers[i].connected:
			servers[i].log_message("[STOP] Stopped connection")
			servers[i].log_message("[INFO] Winner is : "+ str(servers[i].player.name))
			servers[i]._exit_tree()

	thread_manager.dump_outputs()#.wait_to_finish() # wait for the background thread to clean the other threads, it is done to avoid blocking the main thread
	print("[INFO] game cleaned")