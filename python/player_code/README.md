# Creating an ai snake


## Connection

The program has to start by taking one argument : the port number

it then has to connect to this port and send any message containing `"[START]"`

if your program has to crash because it doesn't work properly, you can send a message containing `"[STOP]"`

and if your program has any other relevant info, for example not enough calculation time, you can send a message containing `"[INFO]"`

there is a fully working ai in [python](main.py) (moves semi-randomly) 

## Inputs

Every game update (by default 0.15s) the websockets send to each player a custom map with special characters :


> [!NOTE] : sending websockets takes time, it would be better if the response function was only taking 0.12 secs max
> which can be done by using a background task to minimize the search area, since the snake only moves one cell at a time, 
> there is a lower bound to the number of cell relevant to search for, this bound can be calculated while waiting for the new input from the game

- First part : map

`0` : empty cell

`1` : a fruit

`2` : a wall

`-` : a segment from the <ins>player</ins> body

`*` : the head of the player

`_` : a segment from an enemy snake

`,` : a char to separate x coordinates

`;` : a char to separate y coordinates ( they go from top to bottom in a list manner)

`|` : a char to separate the map from the second part

- Second part : heads (after `|`)

This part might not serve your AI, it contains the player heads position in this format

`(12, 18)(26, 8)(22, 11)(15, 9)(7, 10)`


where 18 is the index in the map ie: `map[18]` and 12 is the index of the element in that row ie `map[18][12]`

example of code parsing the map this :
```python
msg = "..."
input_map = msg.strip().split("|")[0]
parsed = []
for col in input_map.split(";"):
    line = []
    for ele in col.split(","):
        line.append(ele)
    parsed.append(line)
```

example of code parsing the heads
```python
import re
def parse_heads(input_string):
    matches = re.findall(r'\((\d+), (\d+)\)', input_string)
    tuple_list = [(int(x), int(y)) for x, y in matches]
    return tuple_list
```



examples of inputs can be found in the [example](examples/) folder, there are real game data



## Outputs

On every calculation, the script should return one of the four string :

- `"UP"`
- `"DOWN"`
- `"RIGHT"`
- `"LEFT"`

and the message sent to the websocket <ins>__has to__</ins> start with `"[MOVE] "`, without the tag the message will be ignored, the spacing is important


## Global notes

The game only starts one every player has sent a `"[START]"` tag and, each script is running on a thread, if a new input is not submitted in time, it will be the last one that will count