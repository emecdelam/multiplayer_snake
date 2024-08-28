import sys
import asyncio
import websockets

# main loop
async def client(uri):
    try:
        # attempt a connection
        async with websockets.connect(uri) as websocket:
            # creates a background task
            # - hello_task = asyncio.create_task(send_hello(websocket))
            await websocket.send(f"[START] Connection established with kiwi at : {uri.split(':')[2]}") # can be replaced by send_hello()
            try:
                async for message in websocket:
                    await move(websocket, message)
                    print(f"Received: {message}")
            finally:
                print("Connection closed")
                # cancel here the task
                # - hello_task.cancel()
    except Exception as e:
        print(f"Error: {e}")

async def move(websocket, message):
    # ============= your code for moving here =============
    # process etc
    await websocket.send(f"I received : {message}") # you should return a move

if __name__ == "__main__":
    print("Program started")
    # port is given as the first argument
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 34100
    uri = f"ws://localhost:{port}"
    asyncio.run(client(uri))