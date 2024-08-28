import sys
import asyncio
import websockets

# Function to connect to the WebSocket server and send "Hello" every second
async def client(uri):
    try:
        async with websockets.connect(uri) as websocket:
            # Send "Hello" every second
            async def send_hello():
                while True:
                    await asyncio.sleep(1)
                    await websocket.send("Hello")
                    print("Sent: Hello")

            # Start sending "Hello" in the background
            hello_task = asyncio.create_task(send_hello())

            # Handle incoming messages
            try:
                async for message in websocket:
                    print(f"Received: {message}")
            finally:
                print("Connection closed")
                hello_task.cancel()  # Stop sending "Hello" when the connection is closed
    except Exception as e:
        print(f"Error: {e}")

# Entry point of the script
if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 9400
    uri = f"ws://localhost:{port}"
    asyncio.run(client(uri))