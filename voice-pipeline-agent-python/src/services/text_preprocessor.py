class TTSPreprocessor:
    """Service class for preprocessing text for TTS (Text-to-Speech) using Cartesia guidelines."""
    
    def __init__(self):
        """Initialize the TTS preprocessor with default configurations."""
        import re
        
        # Regular expressions for various patterns
        self.date_pattern = re.compile(r'\b(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})\b')
        self.time_pattern = re.compile(r'\b(\d{1,2}):(\d{2})\s*(AM|PM|A\.M\.|P\.M\.)\b', re.IGNORECASE)
        self.time_simple_pattern = re.compile(r'\b(\d{1,2})\s*(AM|PM|A\.M\.|P\.M\.)\b', re.IGNORECASE)
        self.url_pattern = re.compile(r'(https?://)?([a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(?:/[^\s]*)?)')
        self.email_pattern = re.compile(r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b')
        self.single_question_pattern = re.compile(r'([^?])\?(\s|$)')
        self.email_url_question_pattern = re.compile(r'(@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}|\.ai|\.com|\.org|\.net)\?')
        
        # Custom pronunciation mappings
        self.custom_pronunciations = {
            'API': 'A P I',
            'URL': 'U R L',
            'HTTP': 'H T T P',
            'HTTPS': 'H T T P S',
            'AI': 'A I',
            'ML': 'M L',
            'UI': 'U I',
            'UX': 'U X'
        }
        
        # Markdown patterns
        self.markdown_patterns = [
            (re.compile(r'\*\*(.*?)\*\*'), r'\1'),  # Bold **text**
            (re.compile(r'\*(.*?)\*'), r'\1'),       # Italic *text*
            (re.compile(r'`(.*?)`'), r'\1'),         # Inline code `text`
            (re.compile(r'```.*?\n(.*?)```', re.DOTALL), r'\1'),  # Code blocks
            (re.compile(r'^#{1,6}\s+(.*)$', re.MULTILINE), r'\1'),  # Headers
            (re.compile(r'^\s*[-*+]\s+(.*)$', re.MULTILINE), r'\1'),  # Bullet points
            (re.compile(r'^\s*\d+\.\s+(.*)$', re.MULTILINE), r'\1'),  # Numbered lists
            (re.compile(r'\[([^\]]+)\]\([^)]+\)'), r'\1'),  # Links [text](url)
        ]
    
    def process_for_tts(self, text: str, is_markdown: bool = False) -> str:
        """
        Process text for TTS following Cartesia guidelines.
        
        Args:
            text (str): The input text to process
            is_markdown (bool): Whether the input text is in Markdown format
            
        Returns:
            str: The processed text optimized for TTS
        """
        if not isinstance(text, str):
            return str(text) if text is not None else ""
        
        processed_text = text
        
        # Step 1: Convert markdown to plain text if needed
        processed_text = self._convert_markdown_to_plain(processed_text)
        
        # Step 2: Apply TTS-specific transformations
        processed_text = self._replace_book_title(processed_text)
        processed_text = self._remove_stars(processed_text)
        processed_text = self._handle_forward_slashes(processed_text)
        processed_text = self._normalize_dates(processed_text)
        processed_text = self._normalize_times(processed_text)
        processed_text = self._handle_urls_and_emails(processed_text)
        #print('phase 1: ', processed_text)
        processed_text = self._emphasize_questions(processed_text)
        processed_text = self._remove_quotation_marks(processed_text)
        processed_text = self._handle_colons(processed_text)
        processed_text = self._apply_custom_pronunciations(processed_text)
        #processed_text = self._add_appropriate_punctuation(processed_text)
        #print('phase 2: ', processed_text)
        processed_text = self._handle_url_email_questions(processed_text)
        processed_text = self._handle_double_dots(processed_text)
        processed_text = self._handle_newlines(processed_text)
        #print('phase 3: ', processed_text)
        return processed_text.strip()
    
    def _convert_markdown_to_plain(self, text: str) -> str:
        """Convert Markdown text to plain text."""
        processed = text
        
        for pattern, replacement in self.markdown_patterns:
            processed = pattern.sub(replacement, processed)
        
        return processed
    
    def _remove_stars(self, text: str) -> str:
        processed = text
        processed = processed.replace("*", "")
        return processed
    
    def _replace_book_title(self, text: str) -> str:
        processed = text
        processed = processed.replace("[LITERATURE_BOOK]", "Neuromancer")
        return processed
    
    def _handle_forward_slashes(self, text: str) -> str:
        """Remove forward slashes (/) from the text."""
        #return text.replace('/', ' ')
        date_matches = []
        temp_text = text

        for match in self.date_pattern.finditer(text):
            placeholder = f"__DATE_PLACEHOLDER_{len(date_matches)}__"
            date_matches.append(match.group(0))
            temp_text = temp_text.replace(match.group(0), placeholder, 1)

        temp_text = temp_text.replace('/', '-')

        for i, date_match in enumerate(date_matches):
            placeholder = f"__DATE_PLACEHOLDER_{i}__"
            temp_text = temp_text.replace(placeholder, date_match)

        return temp_text
    
    def _normalize_dates(self, text: str) -> str:
        """Convert dates to MM/DD/YYYY format."""
        def format_date(match):
            month, day, year = match.groups()
            return f"{month.zfill(2)}/{day.zfill(2)}/{year}"
        
        return self.date_pattern.sub(format_date, text)
    
    def _normalize_times(self, text: str) -> str:
        """Add spaces between time and AM/PM."""
        def format_time_with_minutes(match):
            hour, minute, period = match.groups()
            # Normalize period format
            period_clean = period.upper().replace('.', '')
            return f"{hour}:{minute} {period_clean}"
        
        def format_time_simple(match):
            hour, period = match.groups()
            # Normalize period format
            period_clean = period.upper().replace('.', '')
            return f"{hour} {period_clean}"
        
        # Handle times with minutes first
        text = self.time_pattern.sub(format_time_with_minutes, text)
        # Then handle simple times (just hour + AM/PM)
        text = self.time_simple_pattern.sub(format_time_simple, text)
        
        return text
    
    def _handle_urls_and_emails(self, text: str) -> str:
        """Replace dots in URLs with 'dot' for better pronunciation."""
        def replace_url_dots(match):
            protocol, domain_path = match.groups()
            protocol_part = protocol if protocol else ""
            # Replace dots with ' dot '
            domain_path_spoken = domain_path.replace('.', ' dot ')
            return f"{protocol_part}{domain_path_spoken}"
        
        def replace_email_dots(match):
            email = match.group(0)
            # Replace dots with ' dot '
            return email.replace('.', ' dot ')
        
        # Handle URLs first
        text = self.url_pattern.sub(replace_url_dots, text)
        # Handle emails
        text = self.email_pattern.sub(replace_email_dots, text)
        
        return text
    
    def _emphasize_questions(self, text: str) -> str:
        """Use two question marks to emphasize questions."""
        return self.single_question_pattern.sub(r'\1??\2', text)
    
    def _remove_quotation_marks(self, text: str) -> str:
        """Remove quotation marks unless they're intentional quotes."""
        # Remove smart quotes and regular quotes that appear to be formatting
        text = text.replace('"', '').replace('"', '').replace('"', '')
        text = text.replace("'", '').replace("'", '').replace("'", '')
        return text
    
    def _handle_colons(self, text: str) -> str:
        text = text.replace(":", '-')
        return text
    
    def _apply_custom_pronunciations(self, text: str) -> str:
        """Apply custom pronunciations for domain-specific words."""
        import re
        
        processed = text
        for word, pronunciation in self.custom_pronunciations.items():
            # Use word boundaries to avoid partial matches
            pattern = re.compile(r'\b' + re.escape(word) + r'\b', re.IGNORECASE)
            processed = pattern.sub(pronunciation, processed)
        return processed
    
    def _add_appropriate_punctuation(self, text: str) -> str:
        """Add punctuation where appropriate."""
        import re
        
        # Split into sentences
        sentences = re.split(r'[.!?]+', text)
        processed_sentences = []
        
        for sentence in sentences:
            sentence = sentence.strip()
            if sentence:
                # If sentence doesn't end with punctuation, add a period
                if not sentence.endswith(('.', '!', '?')):
                    sentence += '.'
                processed_sentences.append(sentence)
        
        return ' '.join(processed_sentences)
    
    def _handle_url_email_questions(self, text: str) -> str:
        """Add space between URLs/emails and question marks."""
        return self.email_url_question_pattern.sub(r'\1 ?', text)
    
    def _handle_double_dots(self, text: str) -> str:
        """Replace double dots (..) with a pause dash (-)."""
        return text.replace('..', '-')
    
    def _handle_newlines(self, text: str) -> str:
        """Replace newline characters (\\n) with break tags."""
        return text.replace('\n', '<break time="1s"/>')
    
    def add_pause(self, text: str, position: int = None) -> str:
        """
        Add a pause to the text using a dash.
        
        Args:
            text (str): The text to modify
            position (int): Position to insert pause. If None, adds at the end
            
        Returns:
            str: Text with pause added
        """
        if position is None:
            return text + "-"
        else:
            return text[:position] + "-" + text[position:]
    
    def add_break_tag(self, text: str, position: int = None, duration: str = "1s") -> str:
        """
        Add a break tag for pauses.
        
        Args:
            text (str): The text to modify
            position (int): Position to insert break. If None, adds at the end
            duration (str): Duration of the break
            
        Returns:
            str: Text with break tag added
        """
        break_tag = f'<break time="{duration}"/>'
        if position is None:
            return text + break_tag
        else:
            return text[:position] + break_tag + text[position:]
    
    def add_custom_pronunciation(self, word: str, pronunciation: str) -> None:
        """
        Add a custom pronunciation mapping.
        
        Args:
            word (str): The word to replace
            pronunciation (str): The pronunciation to use
        """
        self.custom_pronunciations[word] = pronunciation
    
    def remove_custom_pronunciation(self, word: str) -> None:
        """
        Remove a custom pronunciation mapping.
        
        Args:
            word (str): The word to remove from pronunciations
        """
        self.custom_pronunciations.pop(word, None)
