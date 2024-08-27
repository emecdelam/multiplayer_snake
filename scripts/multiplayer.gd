extends Node
class_name __Multiplayer


var last_input_a = null
var last_input_b = null
func _init(player_a:Player, player_b:Player):
	self.player_a = player_a
	self.player_b = player_b

func send_output(game_state):
	self.player_a.send_output(game_state)
	self.player_b.send_output(game_state)

func create_two_players():
	self.player_a.initialize_websockets()
	self.player_b.initialize_websockets()
	await self.player_a.create_process()
	await self.player_b.create_process()

func listen_for_inputs():
	var listen_a = self.player_a.listen()
	var listen_b = self.player_b.listen()
	if listen_a == null and listen_b == null:
		return null
	if listen_a != null and listen_b == null:
		last_input_a = listen_a
	elif listen_a == null and listen_b != null:
		last_input_b = listen_b
	if last_input_a != null and last_input_b != null:
		var returned = [last_input_a,last_input_b]
		last_input_a = null
		last_input_b = null
		return returned
	return null

