from livekit.agents import Agent
from livekit.plugins import (
    cartesia,
    openai,
    deepgram,
)
from livekit.plugins.turn_detector.multilingual import MultilingualModel

from services.instructions_service import InstructionsService


class Assistant(Agent):
    def __init__(self, instructions_service: InstructionsService) -> None:
        # This project is configured to use Deepgram STT, OpenAI LLM and Cartesia TTS plugins
        # Other great providers exist like Cerebras, ElevenLabs, Groq, Play.ht, Rime, and more
        # Learn more and pick the best one for your app:
        # https://docs.livekit.io/agents/plugins
        self.instructions_service = instructions_service
        
        super().__init__(
            instructions=self.instructions_service.get_system_instructions(),
            stt=deepgram.STT(),
            llm=openai.LLM.with_deepseek(model="deepseek-chat"),
            tts=cartesia.TTS(),
            # use LiveKit's transformer-based turn detector
            turn_detection=MultilingualModel(),
        )

    async def on_enter(self):
        # The agent should be polite and greet the user when it joins :)
        self.session.generate_reply(
            instructions=self.instructions_service.get_greeting_instructions(), 
            allow_interruptions=True
        )