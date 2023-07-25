import asyncio
import websockets
import json

from amazon_transcribe.client import TranscribeStreamingClient
from amazon_transcribe.handlers import TranscriptResultStreamHandler
from amazon_transcribe.model import TranscriptEvent


class MyEventHandler(TranscriptResultStreamHandler):

    def __init__(self, output_stream, websocket):
        super().__init__(output_stream)
        self.websocket = websocket

    async def handle_transcript_event(self, transcript_event: TranscriptEvent):
        results = transcript_event.transcript.results
        for result in results:
            for alt in result.alternatives:
                # Convert the transcript to JSON format
                transcript_json = {"transcript": alt.transcript}
                await self.websocket.send(json.dumps(transcript_json))



async def mic_stream(websocket):
    input_queue = asyncio.Queue()

    async def receive_audio():
        async for message in websocket:
            await input_queue.put(message)

    asyncio.create_task(receive_audio())

    while True:
        indata = await input_queue.get()
        yield indata



async def write_chunks(stream, websocket):
    
    async for chunk in mic_stream(websocket):
        await stream.input_stream.send_audio_event(audio_chunk=chunk)
    await stream.input_stream.end_stream()


async def handler(websocket, path):

    client_host, client_port = websocket.remote_address
    print(f"Client connected from {client_host}:{client_port}")

    client = TranscribeStreamingClient(region="us-east-1")
    stream = await client.start_stream_transcription(
        language_code="en-US",
        media_sample_rate_hz=16000,
        media_encoding="pcm"
    )
    handler = MyEventHandler(stream.output_stream, websocket)
    await asyncio.gather(write_chunks(stream, websocket), handler.handle_events())

start_server = websockets.serve(handler, "localhost", 8080)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()
