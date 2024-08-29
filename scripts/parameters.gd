class_name Parameters

@export var number_of_players = 5


@export var player_colors = [
    [Color("#72DF5C"), Color("#145815")],   # Light Green and Dark Green
    [Color("#60ABDA"), Color("#294486")],   # Light Blue and Dark Blue
    [Color("#EEBC77"), Color("#FF760D")],   # Soft Yellow and Orange
    [Color("#B983FF"), Color("#7A4EB6")],   # Light Purple and Dark Purple
    [Color("#FF7AA2"), Color("#C34D6D")]    # Light Pink and Dark Pink
]


@export var player_names = ["alpha", "beta", "gamma", "delta", "epsilon"]

@export var empty_cell_color = Color("#1a1a1a")
@export var wall_cell_color = Color("#373737")
@export var fruit_cell_color = Color("#AD3D17")

## commmand and arguments for the execution
@export var player_exec := [["python3", ["python/player_code/main.py"]],
                            ["python3", ["python/player_code/main.py"]],
                            ["python3", ["python/player_code/main.py"]],
                            ["python3", ["python/player_code/main.py"]],
                            ["python3", ["python/player_code/main.py"]]]