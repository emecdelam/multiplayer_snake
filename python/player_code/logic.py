import random
import numpy as np

# simple script to play randomly
def pick_a_move(input: str):
    input = input.strip()
    parsed = []
    for col in input.split(",;"):
        line = []
        for ele in col.split(","):
            line.append(ele)
        parsed.append(line)
    map = np.array(parsed)

    coordinates = np.where(map == 'a')

    head = (coordinates[0][0], coordinates[1][0])
    x, y = head
    directions = {
        "UP": (x - 1, y),
        "DOWN": (x + 1, y),
        "LEFT": (x, y - 1),
        "RIGHT": (x, y + 1)
    }
    # check for fruit
    for direction, (new_x, new_y) in directions.items():
        if 0 <= new_x < map.shape[0] and 0 <= new_y < map.shape[1]:
            if map[new_x, new_y] == '1':
                return direction
    # check for available paths
    direction_items = list(directions.items())
    random.shuffle(direction_items)
    for direction, (new_x, new_y) in direction_items:
        if 0 <= new_x < map.shape[0] and 0 <= new_y < map.shape[1]:
            if map[new_x, new_y] == '0':
                return direction
    return "UP"
# unused
def random_move():
    direction = random.randint(0, 1)  # 0 || 1
    magnitude = (2 * random.randint(0, 1)) - 1  # from 0 || 1 to -1 || 1
    return (magnitude * abs(direction - 1), # if direction = 0, abs(direction-1) = 1 and only the x gets moved in the magnitude direction
            magnitude * abs(direction))     # if direction = 1, abs(direction-1) = 0 and only the y gets moved in the magnitude direction