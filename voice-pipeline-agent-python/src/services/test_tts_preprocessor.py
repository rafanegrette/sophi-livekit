#!/usr/bin/env python3
"""
Test script for the TTSPreprocessor class to demonstrate Cartesia TTS optimization.
"""

from prompt_postprocessor import TTSPreprocessor


def test_tts_preprocessor():
    """Test the TTSPreprocessor with various text examples."""
    
    tts_processor = TTSPreprocessor()
    
    # Test cases
    test_cases = [
        {
            "name": "Markdown with various elements",
            "text": """# Meeting Summary
**Important:** The meeting is scheduled for 4/20/2023 at 3:30PM.
- Check the API documentation at https://cartesia.ai
- Send confirmation to support@cartesia.ai
- *Remember* to bring the `config.json` file
Are you ready?""",
            "is_markdown": True
        },
        {
            "name": "Plain text with dates and times",
            "text": "The event is on 12/25/2023 at 7:00PM. Contact us at info@example.com if you have questions?",
            "is_markdown": False
        },
        {
            "name": "Text with URLs and emails",
            "text": 'Visit our website at https://cartesia.ai for more info. Email us at support@cartesia.ai?',
            "is_markdown": False
        },
        {
            "name": "Text with technical terms",
            "text": "The API uses HTTP and HTTPS protocols. The UI/UX team will handle the ML models.",
            "is_markdown": False
        },
        {
            "name": "Questions that need emphasis",
            "text": "Are you coming to the party? Will you be there on time? Can you help us?",
            "is_markdown": False
        },
        {
            "name": "Text with double dots and newlines",
            "text": "Wait.. let me think about this.\nThis is a new line.\nAnother line here.. with more dots.",
            "is_markdown": False
        },
        {
            "name": "Text with forward slashes",
            "text": "The pronunciation is /th/ and /sh/ sounds. Also /example/ word.",
            "is_markdown": False
        }
    ]
    
    print("TTS Preprocessor Test Results")
    print("=" * 50)
    
    for i, test_case in enumerate(test_cases, 1):
        print(f"\n{i}. {test_case['name']}")
        print("-" * 30)
        print(f"Original: {test_case['text']}")
        
        processed = tts_processor.process_for_tts(
            test_case['text'], 
            is_markdown=test_case['is_markdown']
        )
        
        print(f"Processed: {processed}")
    
    # Test pause functionality
    print(f"\n{len(test_cases) + 1}. Testing pause functionality")
    print("-" * 30)
    
    sample_text = "Hello there"
    with_dash_pause = tts_processor.add_pause(sample_text)
    with_break_tag = tts_processor.add_break_tag(sample_text, duration="2s")
    
    print(f"Original: {sample_text}")
    print(f"With dash pause: {with_dash_pause}")
    print(f"With break tag: {with_break_tag}")
    
    # Test custom pronunciations
    print(f"\n{len(test_cases) + 2}. Testing custom pronunciations")
    print("-" * 30)
    
    tts_processor.add_custom_pronunciation("Cartesia", "Car-TEE-see-ah")
    custom_text = "Cartesia is an AI company."
    processed_custom = tts_processor.process_for_tts(custom_text)
    
    print(f"Original: {custom_text}")
    print(f"With custom pronunciation: {processed_custom}")


if __name__ == "__main__":
    test_tts_preprocessor()
