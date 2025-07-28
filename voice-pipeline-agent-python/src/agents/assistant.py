from livekit.agents import Agent, ModelSettings
from livekit.plugins import (
    cartesia,
    openai,
    deepgram,
)
from livekit.plugins.turn_detector.multilingual import MultilingualModel
from livekit import rtc
from typing import AsyncIterable

from services.instructions_service import InstructionsService
from src.services.text_preprocessor import TTSPreprocessor


class Assistant(Agent):
    def __init__(self, instructions_service: InstructionsService) -> None:
        # This project is configured to use Deepgram STT, OpenAI LLM and Cartesia TTS plugins
        # Other great providers exist like Cerebras, ElevenLabs, Groq, Play.ht, Rime, and more
        # Learn more and pick the best one for your app:
        # https://docs.livekit.io/agents/plugins
        self.instructions_service = instructions_service
        self.prompt_postprocessor = TTSPreprocessor()
        
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

    async def tts_node(
        self, text: AsyncIterable[str], model_settings: ModelSettings
    ) -> AsyncIterable[rtc.AudioFrame]:
        """
        Override the TTS node to apply prompt postprocessing to LLM output 
        before it goes to TTS synthesis.
        """
        async def processed_text():
            async for text_chunk in text:
                # Apply prompt postprocessing to each text chunk from the LLM
                processed_chunk = self.prompt_postprocessor.process_prompt(text_chunk)
                yield processed_chunk
        
        # Use the default TTS node implementation with our processed text
        async for frame in Agent.default.tts_node(self, processed_text(), model_settings):
            yield frame

    async def transcription_node(
        self, text: AsyncIterable[str], model_settings: ModelSettings
    ) -> AsyncIterable[str]:
        """
        Override the transcription node to send original, unprocessed text to transcriptions.
        This ensures that transcriptions show the original LLM output while TTS gets 
        the processed text for better pronunciation.
        """
        # Pass through the original text without any preprocessing
        async for text_chunk in text:
            yield text_chunk