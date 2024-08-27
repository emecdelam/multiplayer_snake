extends Node

class_name Player

var player_id: int
var port: int
var exec_path: String
var arguments: Array

func _init(id:int, port:int, exec_path:String, argument:Array):
	self.player_id = id
	self.port = port
	self.exec_path = exec_path
	self.arguments = argument
	self.arguments.append(port)


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
	print("[DEBUG] creating a process : "+self.exec_path + " : "+str(self.arguments))
	OS.execute(self.exec_path, self.arguments,out,true,true)
	print("[DEBUG] out : "+str(out))
	return out

func kill():
	send_output("[STOP]")