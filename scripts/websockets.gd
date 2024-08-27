extends Node
class_name __WebSockets

var socket
var url
var port

func _init(port:int):
	print("[DEBUG] Starting socket class at port "+str(port))
	url = "ws://localhost:"+str(port)
	socket = WebSocketPeer.new()

func start():
	var err = self.socket.connect_to_url(self.url)
	if err != OK:
		print("[DEBUG] Unable to connect to the url : "+self.url)
		set_process(false)
	else:
		await get_tree().create_timer(2).timeout
		self.socket.send_text("[START]")


func listen():
	self.socket.poll()
	var state = self.socket.get_ready_state()
	print("[DEBUG] listening sockets "+ str(state))
	# WebSocketPeer.STATE_OPEN means the socket is connected and ready
	# to send and receive data.
	if state == WebSocketPeer.STATE_OPEN:
		while self.socket.get_available_packet_count():
			print("Got data from server: ", self.socket.get_packet().get_string_from_utf8())
			return self.socket.get_packet().get_string_from_utf8()

	# WebSocketPeer.STATE_CLOSING means the socket is closing.
	# It is important to keep polling for a clean close.
	elif state == WebSocketPeer.STATE_CLOSING:
		pass

	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = self.socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		set_process(false) # Stop processing.
	
	return null

func send(output:String):
	self.socket.poll()
	self.socket.send_text(output)