class_name Parameters

@export var number_of_players = 3 


@export var player_colors = [
    [Color("#72DF5C"), Color("#145815")],
    [Color("#60ABDA"), Color("#294486")],
    [Color("#EEBC77"), Color("#E5933F")] 
]


@export var player_names = ["alpha", "beta", "gamma"]

@export var empty_cell_color = Color("#1a1a1a")
@export var wall_cell_color = Color("#373737")
@export var fruit_cell_color = Color("#AD3D17")

## commmand and arguments for the execution
@export var player_exec := [["python3", ["python/player_code/main.py"]],["python3", ["python/player_code/main.py"]],["python3", ["python/player_code/main.py"]]]