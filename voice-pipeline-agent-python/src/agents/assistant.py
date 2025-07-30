from livekit.agents import Agent, ModelSettings
from livekit.plugins import (
    cartesia,
    openai,
    deepgram,
)
from livekit.plugins.turn_detector.multilingual import MultilingualModel
from livekit import rtc
from typing import AsyncIterable
import re

from services.instructions_service import InstructionsService
from services.text_preprocessor import TTSPreprocessor


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
            tts=cartesia.TTS(model="sonic-2"),
            # use LiveKit's transformer-based turn detector
            turn_detection=MultilingualModel(),
        )

    async def on_enter(self):
        # The agent should be polite and greet the user when it joins :)
        self.session.generate_reply(
            instructions=self.instructions_service.get_greeting_instructions(), 
            allow_interruptions=True
        )

    #async def llm_node(
    #    self, chat_ctx, tools, model_settings
    #) -> AsyncIterable[str]:
    #    """
    #    Override the LLM node to apply prompt postprocessing to LLM output 
    #    before it goes downstream to TTS. This implementation ensures proper
    #    spacing between chunks while maintaining real-time streaming.
    #    """
    #    # First get the LLM output using the default implementation
    #    llm_output = Agent.default.llm_node(self, chat_ctx, tools, model_settings)
    #            
    #    async for chunk in llm_output:
    #        if not chunk:
    #            continue
    #        
    #        if hasattr(chunk, 'delta') and chunk.delta:
    #            delta = chunk.delta
    #            if hasattr(delta, 'content'):
    #                text_content = delta.content
    #                if text_content:
    #                    processed_content = self.prompt_postprocessor.process_for_tts(text_content)
    #               
    #                delta.content = processed_content
    #                print("Process Content : ", processed_content)
    #        print("Chunk: ", chunk)
    #        yield chunk

    async def tts_node (
            self, text: AsyncIterable[str], model_settings: ModelSettings
    ) -> AsyncIterable[rtc.AudioFrame]:
        
        async def processed_text():
            async for text_chunk in text:
                processed_chunk = self.prompt_postprocessor.process_for_tts(text_chunk)
                yield processed_chunk
        
        async for audio_frame in Agent.default.tts_node(self, processed_text(), model_settings) :
            yield audio_frame
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
    #        print("transcription: ", text_chunk)
            yield text_chunk