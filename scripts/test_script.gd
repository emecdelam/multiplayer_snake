extends Node

var player_a : Player
var player_b : Player
var multi : Multiplayer
func _ready():
	print("[DEBUG] starting players")
	player_a = Player.new(1, 8765, "python3", ["python/player_code/main.py"])	
	player_b = Player.new(2, 8766, "python3", ["python/player_code/main.py"])
	print("[DEBUG] creating multi")
	multi = Multiplayer.new(player_a, player_b)
	multi.create_two_players()
	
var time_elapsed = 0.0
var interval = 1.0  # Interval in seconds
var count = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if count == 5:
		multi.kill_both_players()
		count += 1
	if count > 5:
		return
	time_elapsed += delta
	if time_elapsed >= interval:
		count += 1
		time_elapsed = 0.0
		_on_timer_timeout()

func _on_timer_timeout():


	print("[DEBUG] sending packets")
	multi.send_output("test packet")
	var ret = multi.listen_for_inputs()
	print("[DEBUG] listening")
	print(ret)


