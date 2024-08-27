extends Node

class_name Player

func _init(id:int, port:int, exec_path:String):
	self.id = id
	self.port = port
	self.path = exec_path


@onready var body:Array = []
@onready var length:int = 0
@onready var alive:bool = true
var is_running: bool = false
var out:Array = []
var socket:__WebSockets


func initialize_websockets():
	socket = __WebSockets.new(self.port)

	
func listen():
	if socket == null:
		return null
	return socket.listen()

func send_output(output):
	if socket == null:
		return
	socket.send(output)

func create_process():
	OS.execute(self.path, [str(self.port)],out,true,true)
	return out