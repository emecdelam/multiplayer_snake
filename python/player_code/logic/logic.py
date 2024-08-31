import random
import numpy as np
import re


def pick_a_move(msg: str):
    """
    The function returning a direction based on the map
    :param msg:
    :return:
    """
    msg = msg.strip().split("|")

    input_map = msg[0]
    heads = parse_heads(msg[1])


    parsed = []
    for col in input_map.split(";"):
        line = []
        for ele in col.split(","):
            line.append(ele)
        parsed.append(line)
    np_parsed = np.array(parsed)

    coordinates = np.where(np_parsed == '*')

    if len(coordinates[0]) == 0 or len(coordinates[1]) == 0: # happens on death
        return 
    head = (coordinates[0][0], coordinates[1][0])
    x, y = head
    directions = {
        "UP": (x - 1, y),
        "DOWN": (x + 1, y),
        "LEFT": (x, y - 1),
        "RIGHT": (x, y + 1)
    }
    # check for fruit next
    for direction, (new_x, new_y) in directions.items():
        if 0 <= new_x < np_parsed.shape[0] and 0 <= new_y < np_parsed.shape[1]:
            if np_parsed[new_x, new_y] == '1':
                return direction
    # check for random available paths
    direction_items = list(directions.items())
    random.shuffle(direction_items)
    for direction, (new_x, new_y) in direction_items:
        if 0 <= new_x < np_parsed.shape[0] and 0 <= new_y < np_parsed.shape[1]:
            if np_parsed[new_x, new_y] == '0':
                return direction
    return "UP"


def parse_heads(input_string):
    """
    Parses "(12, 18)(26, 8)(22, 11)(15, 9)(7, 10)" to [(12, 18), (26, 8), (22, 11), (15, 9), (7, 10)]
    :param input_string: the output from the websocket
    :return: a list of tuples
    """
    matches = re.findall(r'\((\d+), (\d+)\)', input_string)
    tuple_list = [(int(x), int(y)) for x, y in matches]
    return tuple_list


# unused
def random_move():
    direction = random.randint(0, 1)  # 0 || 1
    magnitude = (2 * random.randint(0, 1)) - 1  # from 0 || 1 to -1 || 1
    return (magnitude * abs(direction - 1), # if direction = 0, abs(direction-1) = 1 and only the x gets moved in the magnitude direction
            magnitude * abs(direction))     # if direction = 1, abs(direction-1) = 0 and only the y gets moved in the magnitude direction