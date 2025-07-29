#!/usr/bin/env python3
"""
Test script to verify text buffering and sentence tokenization logic.
This simulates how chunked text from an LLM would be processed.
"""
import asyncio
import re
from typing import AsyncIterable

class TextBufferTester:
    def __init__(self):
        # Sentence boundary detection pattern
        self.sentence_pattern = re.compile(r'([.!?]+\s*)')
    
    def _split_into_sentences(self, text: str) -> list[str]:
        """
        Split text into sentences, preserving sentence boundaries.
        """
        if not text.strip():
            return []
        
        # Split by sentence boundaries but keep the delimiters
        parts = self.sentence_pattern.split(text)
        sentences = []
        current_sentence = ""
        
        for part in parts:
            current_sentence += part
            if self.sentence_pattern.match(part):
                # This part is a sentence ending, so we have a complete sentence
                if current_sentence.strip():
                    sentences.append(current_sentence.strip())
                current_sentence = ""
        
        # Add any remaining text as a sentence
        if current_sentence.strip():
            sentences.append(current_sentence.strip())
        
        return sentences

    async def simulate_chunked_text(self, full_text: str) -> AsyncIterable[str]:
        """
        Simulate how text might come in chunks from an LLM.
        """
        # Split the text into small chunks to simulate streaming
        chunk_size = 5  # Very small chunks to demonstrate the issue
        for i in range(0, len(full_text), chunk_size):
            chunk = full_text[i:i+chunk_size]
            yield chunk
            await asyncio.sleep(0.01)  # Small delay to simulate streaming

    async def process_text_with_buffering(self, text_stream: AsyncIterable[str]) -> list[str]:
        """
        Process chunked text with proper buffering.
        """
        buffer = ""
        processed_chunks = []
        
        async for text_chunk in text_stream:
            # Add the chunk to our buffer
            buffer += text_chunk
            print(f"Added chunk: '{text_chunk}' -> Buffer: '{buffer}'")
            
            # Split the buffer into sentences
            sentences = self._split_into_sentences(buffer)
            print(f"Sentences found: {sentences}")
            
            # If we have multiple sentences, process all but the last one
            if len(sentences) > 1:
                # Process complete sentences
                for sentence in sentences[:-1]:
                    if sentence.strip():
                        processed_chunks.append(sentence)
                        print(f"Processed: '{sentence}'")
                
                # Keep the last (potentially incomplete) sentence in the buffer
                buffer = sentences[-1] if sentences else ""
                print(f"Remaining buffer: '{buffer}'")
            
            # Safety mechanism: if buffer gets too large without sentence endings
            elif len(buffer) > 50:  # Lower threshold for testing
                if buffer.strip():
                    processed_chunks.append(buffer.strip())
                    print(f"Force processed (too long): '{buffer.strip()}'")
                buffer = ""
        
        # Process any remaining text in buffer
        if buffer.strip():
            processed_chunks.append(buffer.strip())
            print(f"Final processed: '{buffer.strip()}'")
        
        return processed_chunks

    async def test_problematic_text(self):
        """Test with the problematic text pattern mentioned in the issue."""
        # Original problematic text (concatenated without spaces)
        problematic = "Nopromble!Let'ssimplify.Today'sword-Glich(noun)-MeaningAsmalltechproblem"
        
        # What it should look like (with proper spacing)
        proper_text = "No problem! Let's simplify. Today's word - Glitch (noun) - Meaning: A small tech problem."
        
        print("=" * 60)
        print("Testing with problematic concatenated text:")
        print(f"Input: {problematic}")
        print("-" * 60)
        
        # Simulate chunked input
        chunked = self.simulate_chunked_text(problematic)
        results = await self.process_text_with_buffering(chunked)
        
        print(f"Results: {results}")
        print(f"Joined: {''.join(results)}")
        
        print("\n" + "=" * 60)
        print("Testing with proper spaced text:")
        print(f"Input: {proper_text}")
        print("-" * 60)
        
        # Simulate chunked input with proper text
        chunked = self.simulate_chunked_text(proper_text)
        results = await self.process_text_with_buffering(chunked)
        
        print(f"Results: {results}")
        print(f"Joined: {' '.join(results)}")

async def main():
    tester = TextBufferTester()
    await tester.test_problematic_text()

if __name__ == "__main__":
    asyncio.run(main())
