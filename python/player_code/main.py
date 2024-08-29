import sys
import asyncio
import websockets
from logic.logic import pick_a_move


# main loop
async def client(uri):
    try:
        # attempt a connection
        async with websockets.connect(uri) as websocket:
            # optionally you can use asyncio.create_task() to create a background task like chunking to make the logic function faster
            await websocket.send(f"[START] Connection established with kiwi at : {port}")
            try:
                async for message in websocket:
                    if "[STOP]" in message: # close the program to allow for clean threads close
                        sys.exit(0)
                    await move(websocket, message)

            finally:
                print("Connection closed")
                # cancel here the task
                # - hello_task.cancel()
    except Exception as e:
        print(f"Error: {e}")

async def move(websocket, message):
    # ============= your code for moving here =============
    direction = pick_a_move(message)
    # =====================================================
    await websocket.send(f"[MOVE] {direction}") # you should return a move

if __name__ == "__main__":
    print("Program started")
    # port is given as the first argument
    port = int(sys.argv[1]) if len(sys.argv) else print("No port given as argument")
    asyncio.run(client(f"ws://localhost:{port}"))