"""
Example usage of the refactored RagService and MilvusConnectionManager.

This example demonstrates how to use the separated concerns:
- MilvusConnectionManager handles all connection logic
- RagService focuses only on embeddings and search operations
"""

from src.services import RagService, MilvusConnectionManager
from src.config.settings import Settings


def example_usage():
    """Example of using the refactored RAG service."""
    
    # Option 1: Use RagService with automatic connection management
    print("=== Option 1: RagService with automatic connection management ===")
    try:
        with RagService() as rag:
            # Search for documents
            results = rag.search_by_text(
                query_text="machine learning fundamentals",
                limit=3,
                score_threshold=0.7
            )
            print(f"Found {len(results)} results")
            for result in results:
                print(f"- ID: {result['id']}, Score: {result['score']:.3f}")
    except Exception as e:
        print(f"Error: {e}")
    
    print("\n=== Option 2: Manual connection management ===")
    # Option 2: Manual connection management for more control
    try:
        settings = Settings()
        connection_manager = MilvusConnectionManager(settings)
        rag = RagService(connection_manager=connection_manager)
        
        # Connect manually
        if connection_manager.connect():
            print("Connected successfully!")
            
            # Get collection stats
            stats = connection_manager.get_collection_stats()
            print(f"Collection stats: {stats}")
            
            # Generate embedding only
            embedding = rag.generate_embedding("test query")
            print(f"Generated embedding with {len(embedding)} dimensions")
            
            # Search
            results = rag.search_by_text("artificial intelligence")
            print(f"Search found {len(results)} results")
            
            # Disconnect manually
            connection_manager.disconnect()
            print("Disconnected successfully!")
        else:
            print("Failed to connect to Milvus")
            
    except Exception as e:
        print(f"Error: {e}")
    
    print("\n=== Option 3: Reusing connection manager ===")
    # Option 3: Reuse connection manager across multiple RAG services
    try:
        shared_connection = MilvusConnectionManager()
        
        # Create multiple RAG services sharing the same connection
        rag1 = RagService(connection_manager=shared_connection)
        rag2 = RagService(connection_manager=shared_connection)
        
        if shared_connection.connect():
            # Both services use the same connection
            embedding1 = rag1.generate_embedding("first query")
            embedding2 = rag2.generate_embedding("second query")
            
            print(f"Service 1 embedding: {len(embedding1)} dimensions")
            print(f"Service 2 embedding: {len(embedding2)} dimensions")
            
            # Search with both services
            results1 = rag1.search_by_text("query one", limit=2)
            results2 = rag2.search_by_text("query two", limit=2)
            
            print(f"Service 1 found {len(results1)} results")
            print(f"Service 2 found {len(results2)} results")
            
            shared_connection.disconnect()
        
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    example_usage()
