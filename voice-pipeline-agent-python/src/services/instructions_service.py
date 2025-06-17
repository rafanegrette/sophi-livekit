import json
import os
from datetime import datetime
from typing import Dict, Any

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
        """Get the current prompt based on day and time."""
        if not self._week_prompts:
            return self._default_instructions
        
        now = datetime.now()
        day_name = now.strftime("%A").lower()  # Get day name (monday, tuesday, etc.)
        time_period = self._get_time_period(now.hour)
        
        try:
            return self._week_prompts[day_name][time_period]
        except KeyError:
            print(f"Warning: No prompt found for {day_name} {time_period}, using default")
            return self._default_instructions
    
    def get_system_instructions(self) -> str:
        """Get the system instructions for the assistant based on current time."""
        return self._get_current_prompt()
    
    def get_greeting_instructions(self) -> str:
        return "Hello, let's begin the lesson"