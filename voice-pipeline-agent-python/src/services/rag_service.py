import logging
from typing import List, Dict, Any, Optional
from sentence_transformers import SentenceTransformer
from config.settings import Settings
from .milvus_connection import MilvusConnectionManager

logger = logging.getLogger(__name__)


class RagService:
    """Service class for Retrieval-Augmented Generation focusing on embeddings and search."""
    
    def __init__(self, connection_manager: Optional[MilvusConnectionManager] = None, 
                 settings: Optional[Settings] = None):
        """Initialize the RAG service with connection manager and embedding model.
        
        Args:
            connection_manager: MilvusConnectionManager instance for database operations.
                              If None, will create a new instance using settings.
            settings: Settings object containing configuration.
                     If None, will create a new Settings instance.
        """
        self.settings = settings or Settings()
        self.connection_manager = connection_manager or MilvusConnectionManager(self.settings)
        self._embedding_model = None
        
        # Initialize embedding model (same as Java LangChain4j AllMiniLmL6V2EmbeddingModel)
        try:
            self._embedding_model = SentenceTransformer('all-MiniLM-L6-v2')
            logger.info("Loaded all-MiniLM-L6-v2 embedding model")
        except Exception as e:
            logger.error(f"Failed to load embedding model: {e}")
            raise
    
    def generate_embedding(self, text: str) -> List[float]:
        """Generate embedding for the given text using all-MiniLM-L6-v2 model.
        
        Args:
            text: The text to embed
            
        Returns:
            List of floats representing the embedding vector (384 dimensions)
        """
        if self._embedding_model is None:
            raise RuntimeError("Embedding model not initialized")
        
        try:
            # Generate embedding - returns numpy array, convert to list
            embedding = self._embedding_model.encode(text, convert_to_tensor=False)
            return embedding.tolist()
        except Exception as e:
            logger.error(f"Error generating embedding: {e}")
            raise
    
    def search_by_text(self, query_text: str, limit: int = 1, 
                      output_fields: Optional[List[str]] = None,
                      score_threshold: float = 0.0) -> List[Dict[str, Any]]:
        """Search for documents by text content using semantic embedding search.
        
        This method embeds the query text using the same all-MiniLM-L6-v2 model
        that was used in the Java application, then performs vector similarity search.
        
        Args:
            query_text: The text to search for
            limit: Maximum number of results to return
            output_fields: List of fields to include in results. If None, returns all fields.
            score_threshold: Minimum similarity score to include in results
            
        Returns:
            List of dictionaries containing search results with scores and metadata.
        """
        # Ensure connection is active, reconnect if necessary
        if not self.connection_manager.ensure_connected():
            raise RuntimeError("Unable to establish connection to Milvus. Check connection configuration.")
        
        # Get the collection from connection manager
        collection = self.connection_manager.collection
        if collection is None:
            raise RuntimeError("Collection is not available. Connection may have failed.")
        
        try:
            # Generate embedding for the query text
            query_embedding = self.generate_embedding(query_text)
            logger.info(f"Generated embedding for query: '{query_text[:50]}{'...' if len(query_text) > 50 else ''}'")
            
            # Default output fields if not specified
            if output_fields is None:
                output_fields = ["*"]
            
            # Perform vector search
            search_params = {
                "metric_type": "COSINE",  # or "L2", "IP" depending on your setup
                "params": {"nprobe": 10}
            }
            
            results = collection.search(
                data=[query_embedding],
                anns_field="vector",  # Assuming your vector field is named "vector"
                param=search_params,
                limit=limit,
                output_fields=output_fields
            )
            
            # Format results
            formatted_results = []
            for hit in results[0]:
                result = {
                    "id": hit.id,
                    "score": hit.score,
                    "distance": hit.distance
                }
                # Add entity fields
                if hasattr(hit, 'entity'):
                    for field_name in output_fields:
                        if field_name != "*" and hasattr(hit.entity, field_name):
                            result[field_name] = getattr(hit.entity, field_name)
                
                formatted_results.append(result)
            
            # Filter by score threshold if specified
            if score_threshold > 0.0:
                filtered_results = [r for r in formatted_results if r.get('score', 0.0) >= score_threshold]
                logger.info(f"Filtered {len(formatted_results)} to {len(filtered_results)} results using threshold {score_threshold}")
                return filtered_results
            
            logger.info(f"Found {len(formatted_results)} similar vectors")
            return formatted_results
            
        except Exception as e:
            logger.error(f"Error in semantic text search: {e}")
            raise
    
    # Convenience methods to access connection manager functionality
    def connect(self) -> bool:
        """Connect to Milvus database. Delegates to connection manager."""
        return self.connection_manager.connect()
    
    def disconnect(self):
        """Disconnect from Milvus database. Delegates to connection manager."""
        self.connection_manager.disconnect()
    
    def is_connected(self) -> bool:
        """Check if connected to Milvus. Delegates to connection manager."""
        return self.connection_manager.is_connected()
    
    def get_collection_stats(self) -> Dict[str, Any]:
        """Get collection statistics. Delegates to connection manager."""
        return self.connection_manager.get_collection_stats()
    
    def __enter__(self):
        """Context manager entry with connection validation."""
        if not self.connection_manager.connect():
            raise RuntimeError("Failed to establish connection to Milvus database")
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit with guaranteed cleanup."""
        try:
            self.connection_manager.disconnect()
        except Exception as e:
            logger.error(f"Error during context manager cleanup: {e}")
        
        # Return None (falsy) to propagate any exceptions that occurred in the with block
        return False
