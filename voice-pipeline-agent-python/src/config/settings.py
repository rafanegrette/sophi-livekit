import os
from typing import Optional


class Settings:
    """Application settings and configuration."""
    
    def __init__(self):
        self.livekit_url: Optional[str] = os.getenv("LIVEKIT_URL")
        self.livekit_api_key: Optional[str] = os.getenv("LIVEKIT_API_KEY")
        self.livekit_api_secret: Optional[str] = os.getenv("LIVEKIT_API_SECRET")
        self.openai_api_key: Optional[str] = os.getenv("OPENAI_API_KEY")
        self.deepgram_api_key: Optional[str] = os.getenv("DEEPGRAM_API_KEY")
        self.cartesia_api_key: Optional[str] = os.getenv("CARTESIA_API_KEY")
        
        # Milvus configuration
        self.milvus_host: Optional[str] = os.getenv("MILVUS_HOST")
        self.milvus_token: Optional[str] = os.getenv("MILVUS_TOKEN")
        self.milvus_collection_name: str = "Neuromancer"
        
        # Agent configuration
        self.min_endpointing_delay: float = 0.5
        self.max_endpointing_delay: float = 5.0