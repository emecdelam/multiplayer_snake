extends Node

class_name Player

func _init(id:int, port:int):
	self.id = id
	self.port = port


@onready var body:Array = []
@onready var length:int = 0
@onready var alive:bool = true
var is_running: bool = false
var out:Array = []
var socket:__WebSockets


func initialize_websockets():
	socket = __WebSockets.new(self.port)


func listen():
	if socket != null:
		return socket.listen()
	return null