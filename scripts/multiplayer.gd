extends Node
class_name Multiplayer


var last_input_a = null
var last_input_b = null
var player_a : Player
var player_b : Player
var thread_a = Thread.new()
var thread_b = Thread.new()
func _init(p_a:Player, p_b:Player):
	self.player_a = p_a
	self.player_b = p_b

func send_output(game_state):
	self.player_a.send_output(game_state)
	self.player_b.send_output(game_state)

func create_two_players():
	print("[DEBUG] starting player_a coroutine")
	if thread_a.start(self.player_a.create_process) != OK:
		print("[ERROR] thread A failed")
	print("[DEBUG] starting player_b coroutine")
	if thread_b.start(self.player_b.create_process) != OK:
		print("[ERROR thread B failed")
	



func listen_for_inputs():
	self.player_a.initialize_websockets()
	self.player_b.initialize_websockets()
	var listen_a = self.player_a.listen()
	var listen_b = self.player_b.listen()
	if listen_a == null and listen_b == null:
		return null
	if listen_a != null and listen_b == null:
		last_input_a = listen_a
	elif listen_a == null and listen_b != null:
		last_input_b = listen_b
	if last_input_a != null and last_input_b != null:
		var returned = [[self.player_a,last_input_a],[self.player_b,last_input_b]]
		last_input_a = null
		last_input_b = null
		return returned
	return null

func kill_both_players():
	print("[DEBUG] killing both trhreads")
	self.player_a.kill()
	thread_a.wait_to_finish()
	self.player_b.kill()
	thread_b.wait_to_finish()