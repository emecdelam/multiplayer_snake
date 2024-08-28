extends Node

## The port the server will listen on.
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const PORT = 9400

var tcp_server := TCPServer.new()
var socket := WebSocketPeer.new()
var state 
# Array to store log messages
var log_entries := []


func log_message(message: String) -> void:
	var time := "[%s] : %s\n" % [Time.get_time_string_from_system(), message]
	log_entries.append(time)

	if log_entries.size() > 15:
		log_entries.remove_at(0)
	%TextServer.text = "".join(log_entries)

func send_message(str: String):
	socket.send_text(str)

func _ready() -> void:
	if tcp_server.listen(PORT) != OK:
		log_message("Unable to start server.")
		set_process(false)
	


func _process(_delta: float) -> void:
	while tcp_server.is_connection_available():
		var conn: StreamPeerTCP = tcp_server.take_connection()
		assert(conn != null)
		socket.accept_stream(conn)

	socket.poll()
	
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			log_message(socket.get_packet().get_string_from_ascii())
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false) # Stop processing.
func _exit_tree() -> void:
	socket.close()
	tcp_server.stop()
