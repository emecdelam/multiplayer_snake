class_name Parameters

@export var number_of_players = 5


# head, tail color
@export var player_colors = [
    [Color("#72DF5C"), Color("#145815")],   # green
    [Color("#60ABDA"), Color("#294486")],   # blue
    [Color("#EEBC77"), Color("#FF760D")],   # orange
    [Color("#E09D9F"), Color("#D0406D")],   # pink
    [Color("#DAB6FF"), Color("#8A28A4")]    # purple
]


@export var player_names = ["alpha", "beta", "gamma", "delta", "epsilon"]

@export var empty_cell_color = Color("#1a1a1a")
@export var wall_cell_color = Color("#373737")
@export var fruit_cell_color = Color("#C85A2F")

## commmand and arguments for the execution
@export var player_exec := [["python3", ["python/player_code/main.py"]],
                            ["python3", ["python/player_code/main.py"]],
                            ["python3", ["python/player_code/main.py"]],
                            ["python3", ["python/player_code/main.py"]],
                            ["python3", ["python/player_code/main.py"]]]