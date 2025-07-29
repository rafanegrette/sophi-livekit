#!/usr/bin/env python3
"""
Test script to verify real-time text processing with proper spacing.
This simulates how chunked text from an LLM would be processed while maintaining streaming.
"""
import asyncio
from typing import AsyncIterable

class RealTimeTextProcessor:
    def __init__(self):
        pass
    
    async def simulate_llm_chunks(self, full_text: str) -> AsyncIterable[str]:
        """
        Simulate how text might come in chunks from an LLM, including the problematic patterns.
        """
        # Simulate the problematic chunking pattern that causes concatenation
        chunks = [
            "No", "prob", "lem!", "Let's", "simp", "lify.", 
            "Today's", "word", "-", "Glit", "ch", "(noun)", 
            "-", "Mean", "ing:", "A", "small", "tech", "prob", "lem."
        ]
        
        for chunk in chunks:
            yield chunk
            await asyncio.sleep(0.1)  # Simulate streaming delay

    async def process_with_spacing_fix(self, text_stream: AsyncIterable[str]) -> AsyncIterable[str]:
        """
        Process chunked text with real-time spacing fixes - similar to the new tts_node logic.
        """
        last_chunk_ended_with_space = True  # Start assuming we're at word boundary
        
        async for text_chunk in text_stream:
            if not text_chunk:
                continue
            
            print(f"Received chunk: '{text_chunk}'")
            
            # Check if we need to add a space before this chunk
            chunk_starts_with_space = text_chunk.startswith(' ')
            chunk_ends_with_space = text_chunk.endswith(' ')
            
            # If the last chunk didn't end with space and this chunk doesn't start with space,
            # we likely have a word boundary issue - add a space
            if not last_chunk_ended_with_space and not chunk_starts_with_space:
                # But be smart about it - don't add space if the chunk starts with punctuation
                if not text_chunk[0] in '.,!?;:)]}"\'-':
                    text_chunk = ' ' + text_chunk
                    print(f"  -> Added space: '{text_chunk}'")
            
            # Update state for next iteration
            last_chunk_ended_with_space = chunk_ends_with_space or text_chunk.endswith(' ')
            
            # Yield the processed chunk immediately for real-time streaming
            yield text_chunk

    async def test_real_time_processing(self):
        """Test the real-time processing approach."""
        print("=" * 70)
        print("Real-time text processing with spacing fixes")
        print("=" * 70)
        
        # Simulate the LLM text stream
        llm_stream = self.simulate_llm_chunks("dummy")  # The actual text is in simulate_llm_chunks
        
        # Process with spacing fixes
        processed_stream = self.process_with_spacing_fix(llm_stream)
        
        # Collect and display results in real-time
        result = ""
        async for chunk in processed_stream:
            result += chunk
            print(f"Real-time output so far: '{result}'")
        
        print(f"\nFinal result: '{result}'")
        
        # Compare with what we'd get without spacing fixes
        print("\n" + "-" * 70)
        print("Without spacing fixes (original problem):")
        no_fix_result = "NoproblemLet'ssimplifyToday'sword-Glitch(noun)-MeaningAsmalltech problem"
        print(f"Would be: '{no_fix_result}'")

async def main():
    processor = RealTimeTextProcessor()
    await processor.test_real_time_processing()

if __name__ == "__main__":
    asyncio.run(main())
