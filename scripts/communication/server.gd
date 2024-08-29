extends Node


class_name Server



#--------------------------------------
# GLOBAL VAR
#--------------------------------------


## The port the server will listen on.
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
var PORT = 34100

var tcp_server := TCPServer.new()
var socket := WebSocketPeer.new()
var player: Player
var connected: bool = false
var id: int
var console: ServerConsole
#--------------------------------------
# Default functions
#--------------------------------------




func _process(_delta: float) -> void:
	
	while tcp_server.is_connection_available():
		var conn: StreamPeerTCP = tcp_server.take_connection()
		assert(conn != null)
		socket.accept_stream(conn)

	socket.poll()

	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			handle_message(socket.get_packet().get_string_from_ascii().strip_edges(true,true))

	#elif socket.get_ready_state() == WebSocketPeer.STATE_CLOSED:
	#	print("[INFO] WebSocket closed")

func _exit_tree() -> void:
	send_message("[STOP]")
	socket.close()
	tcp_server.stop()



#--------------------------------------
# Custom functions
#--------------------------------------
func initialize_server(port: int, node:Node, server_player:Player, cons: ServerConsole) -> bool:
	PORT = port
	player = server_player
	console = cons
	if tcp_server.listen(PORT) != OK:
		log_message("[INFO] Unable to start server.")
		set_process(false)
		return false
	node.add_child(self)
	print("[INFO] initialized server at port : " + str(PORT))
	return true

func log_message(message: String) -> void:
	console.add_message("[%s]  (%s) : %s\n" % [Time.get_time_string_from_system(), PORT, message], player.color)

func send_message(message: String) -> void:
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.send_text(message)


## A function to remove the '[...] ' from a msg
func formatted_message(msg: String) -> String:
	var splitted = msg.split(" ")
	splitted.remove_at(0)
	return "".join(splitted)


func handle_message(message: String) -> void:
	if message.contains("[START]"):
		connected = true
		get_parent().update_connection(self)
		log_message(message)
	elif message.contains("[STOP]"):
		connected = false
		get_parent().update_connection(self)
		log_message(message)
	elif message.begins_with("[INFO]"):
		log_message(formatted_message(message))
	elif message.begins_with("[MOVE]"):
		player.update_direction(player.match_string_direction(formatted_message(message)))
	else:
		print("[WARNING] message without tag : "+ message)

