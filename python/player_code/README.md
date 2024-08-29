# Creating an ai pyton snake


## Connection

The program has to start by taking one argument : the port number

it then has to connect to this port and send any message containing `"[START]"`

if your program has to crash because it doesn't work properly, you can send a message containing `"[STOP]"`

and if your program has any other relevant info, for example not enough calculation time, you can send a message containing `"[INFO]"`


## Inputs

Every game update (by default 0.15s) the websockets send to each player a custom map with special characters :

- First part

`0` : empty cell

`1` : a fruit

`2` : a wall

`-` : a segment from the <ins>player</ins> body

`*` : the head of the player

`_` : a segment from an enemy snake

`,` : a char to separate x coordinates

`;` : a char to separate y coordinates ( they go from top to bottom in a list manner)

`|` : a char to separate the map from the second part

- Second part (after `|`)

This part might not serve your AI, it contains the player heads position in this format

`(12, 18)(26, 8)(22, 11)(15, 9)(7, 10)`

where 18 is the index in the map ie: `map[18]` and 12 is the index of the element in that row ie `map[18][12]`

example of code doing this :
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


examples of inputs can be found in the [example](example_input.txt) file, it is data from a single player game of a 10x10 grid



## Outputs

On every calculation, the script should return one of the four string :

- `"UP"`
- `"DOWN"`
- `"RIGHT"`
- `"LEFT"`

and the message sent to the websocket <ins>__has to__</ins> start with `"[MOVE] "`, without the tag the message will be ignored, the spacing is important


## Global notes

The game only starts one every player has sent a `"[START]"` tag and, each script is running on a thread, if a new input is not submitted in time, it will be the last one that will count