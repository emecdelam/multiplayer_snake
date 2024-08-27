import sys
from enum import Enum
import asyncio
import websockets


class Instructions(Enum):
    START = "[START]"
    STOP = "[STOP]"
    UP = "[UP]"
    DOWN = "[DOWN]"
    RIGHT = "[RIGHT]"
    LEFT = "[LEFT]"
    MOVE = "[MOVE] "
    IGNORED =["[DEBUG]","[ERROR]"]


async def echo(websocket):
    async for message in websocket:
        print(f"Received from client: {message}")
        response = f"Echo: {message}"
        await websocket.send(response)


async def main(port_id):
    async with websockets.serve(echo, "localhost", port_id):
        print(f"WebSocket server started on ws://localhost:{port_id}")
        await asyncio.Future()  # Run forever


if __name__ == "__main__":
    if len(sys.argv) > 1:
        port = sys.argv[1]
        print(port)
        asyncio.run(main(port))
    else:
        asyncio.run(main(8765))