import json
import os
from datetime import datetime
from typing import Dict, Any
from .rag_service import RagService
from .text_preprocessor import TTSPreprocessor

class InstructionsService:
    """Service class for managing assistant instructions and prompts."""
    
    def __init__(self):
        self._default_instructions = (
            "You are a voice assistant created by LiveKit. Your interface with users will be voice. "
            "You should use short and concise responses, and avoiding usage of unpronouncable punctuation. "
            "You were created as a demo to showcase the capabilities of LiveKit's agents framework."
        )
        
        self._greeting_instructions = "Hey, how can I help you today?"
        self._week_prompts = self._load_week_prompts()
        self._rag_service = self._initialize_rag_service()
        self._prompt_postprocessor = TTSPreprocessor()
    
    def _initialize_rag_service(self) -> RagService:
        """Initialize the RAG service."""
        try:
            return RagService()
        except Exception as e:
            print(f"Warning: Failed to initialize RAG service: {e}")
            return None
    
    def _load_week_prompts(self) -> Dict[str, Any]:
        """Load week prompts from JSON file."""
        try:
            # Try to load from src/data/ first, then src/config/
            for path in ["src/data/week-prompt.json", "src/config/week-prompt.json"]:
                if os.path.exists(path):
                    with open(path, 'r') as file:
                        return json.load(file)
            
            # If file not found, return empty dict and use default instructions
            print("Warning: week-prompt.json not found, using default instructions")
            return {}
        except Exception as e:
            print(f"Error loading week prompts: {e}")
            return {}
    
    def _get_time_period(self, hour: int) -> str:
        """Determine time period based on hour (24-hour format)."""
        if 6 <= hour < 12:
            return "morning"
        elif 12 <= hour < 17:  # 12:00 PM to 5:00 PM
            return "noon"
        else:
            return "afternoon"
    
    def _get_current_prompt(self) -> str:
        """Get the current raw prompt based on day and time (without processing)."""
        if not self._week_prompts:
            return self._default_instructions
        
        now = datetime.now()
        day_name = now.strftime("%A").lower()  # Get day name (monday, tuesday, etc.)
        time_period = self._get_time_period(now.hour)
        
        try:
            base_prompt = self._week_prompts[day_name][time_period]['prompt']
            
            # If RAG service is available, enhance the prompt with book extracts
            if self._rag_service:
                try:
                    query = self._week_prompts[day_name][time_period]['query']
                    rag_results = self._rag_service.search_by_text(query, limit=2)
                    
                    # Format the enhanced prompt
                    enhanced_prompt = base_prompt
                    
                    if rag_results:
                        # Extract text content from RAG results
                        book_extracts = []
                        for result in rag_results:
                            # Assuming the text content is in a field called 'text' or 'content'
                            content = result.get('text') or result.get('content') or str(result.get('entity', {}))
                            if content and content.strip():
                                book_extracts.append(content.strip())
                        
                        if book_extracts:
                            enhanced_prompt += f"\n\n{'='*50}\nRELEVANT BOOK EXTRACTS:\n{'='*50}\n\n"
                            for i, extract in enumerate(book_extracts, 1):
                                enhanced_prompt += f"Extract {i}:\n{extract}\n\n"
                            enhanced_prompt += f"{'='*50}\n"
                    
                    return enhanced_prompt
                    
                except Exception as e:
                    print(f"Warning: RAG service error, using base prompt: {e}")
                    return base_prompt
            
            return base_prompt
            
        except KeyError:
            print(f"Warning: No prompt found for {day_name} {time_period}, using default")
            return self._default_instructions
    
    def get_system_instructions(self) -> str:
        """Get the system instructions for the assistant based on current time."""
        raw_prompt = self._get_current_prompt()
        response = self._prompt_postprocessor.replace_book_title(raw_prompt)
        print("Instruction : ", response)
        return response
    
    def get_greeting_instructions(self) -> str:
        return "Hello, let's begin the lesson"