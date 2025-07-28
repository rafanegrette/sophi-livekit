class PromptPostprocessor:
    """Service class for postprocessing prompts by cleaning and replacing specific patterns."""
    
    def __init__(self):
        """Initialize the prompt postprocessor with default replacement mappings."""
        self._replacements = {
            '[LITERATURE_BOOK]': 'Neuromance'
        }
        self._characters_to_remove = ['/', '*', '=']
    
    def process_prompt(self, prompt: str) -> str:
        """
        Process a prompt by applying all cleaning and replacement operations.
        
        Args:
            prompt (str): The input prompt string to process
            
        Returns:
            str: The processed prompt string
        """
        if not isinstance(prompt, str):
            return str(prompt) if prompt is not None else ""
        
        processed_prompt = prompt
        
        # Remove unwanted characters
        processed_prompt = self._remove_characters(processed_prompt)
        
        # Apply replacements
        processed_prompt = self._apply_replacements(processed_prompt)
        
        # Handle newline sequences
        processed_prompt = self._process_newlines(processed_prompt)
        
        return processed_prompt
    
    def _remove_characters(self, text: str) -> str:
        """
        Remove specified characters from the text.
        
        Args:
            text (str): Input text
            
        Returns:
            str: Text with specified characters removed
        """
        for char in self._characters_to_remove:
            text = text.replace(char, '')
        return text
    
    def _apply_replacements(self, text: str) -> str:
        """
        Apply replacement mappings to the text.
        
        Args:
            text (str): Input text
            
        Returns:
            str: Text with replacements applied
        """
        for old_value, new_value in self._replacements.items():
            text = text.replace(old_value, new_value)
        return text
    
    def _process_newlines(self, text: str) -> str:
        """
        Process newline sequences in the text.
        Converts \\n\\n (literal backslash-n sequences) to actual line breaks.
        
        Args:
            text (str): Input text
            
        Returns:
            str: Text with newline sequences processed
        """
        # Replace literal \n\n with actual newlines
        text = text.replace('\\n\\n', '\n\n')
        # Also handle single \n if needed
        text = text.replace('\\n', '\n')
        return text
    
    def add_replacement(self, old_value: str, new_value: str) -> None:
        """
        Add a new replacement mapping.
        
        Args:
            old_value (str): The string to be replaced
            new_value (str): The replacement string
        """
        self._replacements[old_value] = new_value
    
    def remove_replacement(self, old_value: str) -> None:
        """
        Remove a replacement mapping.
        
        Args:
            old_value (str): The replacement key to remove
        """
        self._replacements.pop(old_value, None)
    
    def add_character_to_remove(self, char: str) -> None:
        """
        Add a character to the removal list.
        
        Args:
            char (str): Character to add to removal list
        """
        if char not in self._characters_to_remove:
            self._characters_to_remove.append(char)
    
    def remove_character_from_removal(self, char: str) -> None:
        """
        Remove a character from the removal list.
        
        Args:
            char (str): Character to remove from removal list
        """
        if char in self._characters_to_remove:
            self._characters_to_remove.remove(char)
