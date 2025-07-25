import logging
from typing import Optional, Dict, Any
from pymilvus import connections, Collection, MilvusException
from src.config.settings import Settings

logger = logging.getLogger(__name__)


class MilvusConnectionManager:
    """Manages connections to Milvus vector database with optimized connection handling."""
    
    def __init__(self, settings: Optional[Settings] = None):
        """Initialize the connection manager with Milvus configuration.
        
        Args:
            settings: Settings object containing Milvus configuration.
                     If None, will create a new Settings instance.
        """
        self.settings = settings or Settings()
        self._collection = None
        self._connected = False
        
        # Validate required configuration
        if not all([self.settings.milvus_host, self.settings.milvus_token, 
                   self.settings.milvus_collection_name]):
            raise ValueError("Missing required Milvus configuration: host, token, or collection_name")
    
    def connect(self) -> bool:
        """Connect to Milvus database with optimized connection management.
        
        Returns:
            bool: True if connection successful, False otherwise.
        """
        # Check if already connected and collection is loaded
        if self._connected and self._collection is not None:
            try:
                # Validate existing connection by checking collection status
                self._collection.describe()
                logger.debug("Already connected to Milvus - reusing existing connection")
                return True
            except Exception:
                # Connection is stale, need to reconnect
                logger.warning("Existing connection is stale, reconnecting...")
                self._cleanup_connection()
        
        try:
            # Check if connection with this alias already exists
            try:
                connections.get_connection("default")
                logger.debug("Reusing existing Milvus connection")
            except Exception:
                # Create new connection with timeout
                logger.info(f"Creating new connection to Milvus host: {self.settings.milvus_host}")
                connections.connect(
                    alias="default",
                    host=self.settings.milvus_host,
                    token=self.settings.milvus_token,
                    timeout=30  # 30 second timeout
                )
            
            # Initialize and load collection
            logger.info(f"Initializing collection: {self.settings.milvus_collection_name}")
            self._collection = Collection(self.settings.milvus_collection_name)
            
            # Check if collection exists and has data
            if self._collection.num_entities == 0:
                logger.warning(f"Collection '{self.settings.milvus_collection_name}' is empty")
            
            # Load collection into memory for fast search
            if not self._collection.has_index():
                logger.warning(f"Collection '{self.settings.milvus_collection_name}' has no index - searches may be slow")
            
            self._collection.load(timeout=60)  # 60 second timeout for loading
            logger.info(f"Collection loaded successfully. Entities: {self._collection.num_entities}")
            
            # Validate connection by performing a quick describe operation
            collection_info = self._collection.describe()
            logger.debug(f"Collection schema validated: {len(collection_info['fields'])} fields")
            
            self._connected = True
            logger.info(f"Successfully connected to Milvus collection: {self.settings.milvus_collection_name}")
            return True
            
        except MilvusException as e:
            logger.error(f"Milvus-specific error during connection: {e}")
            self._cleanup_connection()
            return False
        except ConnectionError as e:
            logger.error(f"Network connection error to Milvus: {e}")
            self._cleanup_connection()
            return False
        except TimeoutError as e:
            logger.error(f"Connection timeout to Milvus: {e}")
            self._cleanup_connection()
            return False
        except Exception as e:
            logger.error(f"Unexpected error connecting to Milvus: {e}")
            self._cleanup_connection()
            return False
    
    def disconnect(self):
        """Disconnect from Milvus database with proper resource cleanup."""
        if not self._connected and self._collection is None:
            logger.debug("Already disconnected from Milvus")
            return
        
        try:
            logger.info("Disconnecting from Milvus...")
            
            # Release collection resources first
            if self._collection is not None:
                try:
                    # Release collection from memory
                    self._collection.release()
                    logger.debug("Collection released from memory")
                except Exception as e:
                    logger.warning(f"Error releasing collection: {e}")
                finally:
                    self._collection = None
            
            # Disconnect from Milvus server
            try:
                connections.disconnect("default")
                logger.debug("Disconnected from Milvus server")
            except Exception as e:
                logger.warning(f"Error disconnecting from server: {e}")
            
            self._connected = False
            logger.info("Successfully disconnected from Milvus")
            
        except Exception as e:
            logger.error(f"Error during Milvus disconnection: {e}")
            # Force cleanup even if errors occurred
            self._collection = None
            self._connected = False
    
    def _cleanup_connection(self):
        """Internal method to cleanup connection state after failures."""
        try:
            if self._collection is not None:
                self._collection.release()
        except Exception:
            pass  # Ignore cleanup errors
        
        try:
            connections.disconnect("default")
        except Exception:
            pass  # Ignore cleanup errors
        
        self._collection = None
        self._connected = False
        logger.debug("Connection state cleaned up")
    
    def is_connected(self) -> bool:
        """Check if the service is properly connected to Milvus.
        
        Returns:
            bool: True if connected and collection is accessible, False otherwise.
        """
        if not self._connected or self._collection is None:
            return False
        
        try:
            # Test connection by performing a lightweight operation
            self._collection.describe()
            return True
        except Exception:
            # Connection is broken, update state
            self._connected = False
            return False
    
    def get_collection_stats(self) -> Dict[str, Any]:
        """Get collection statistics and health information.
        
        Returns:
            Dict containing collection statistics or error information.
        """
        if not self.is_connected():
            return {"error": "Not connected to Milvus"}
        
        try:
            stats = {
                "collection_name": self.settings.milvus_collection_name,
                "num_entities": self._collection.num_entities,
                "has_index": self._collection.has_index(),
                "is_loaded": True,  # If we can access it, it's loaded
                "schema_fields": len(self._collection.describe()['fields'])
            }
            
            # Add index information if available
            if self._collection.has_index():
                try:
                    indexes = self._collection.indexes
                    stats["indexes"] = [{"field": idx.field_name, "type": idx.index_type} for idx in indexes]
                except Exception:
                    stats["indexes"] = "Unable to retrieve index details"
            
            return stats
        except Exception as e:
            return {"error": f"Failed to get collection stats: {e}"}
    
    def ensure_connected(self) -> bool:
        """Ensure connection is active, reconnect if necessary.
        
        Returns:
            bool: True if connected successfully, False otherwise.
        """
        if self.is_connected():
            return True
        
        logger.info("Connection lost, attempting to reconnect...")
        return self.connect()
    
    @property
    def collection(self) -> Optional[Collection]:
        """Get the current collection instance.
        
        Returns:
            Collection instance if connected, None otherwise.
        """
        return self._collection if self.is_connected() else None
    
    def __enter__(self):
        """Context manager entry with connection validation."""
        if not self.connect():
            raise RuntimeError("Failed to establish connection to Milvus database")
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Context manager exit with guaranteed cleanup."""
        try:
            self.disconnect()
        except Exception as e:
            logger.error(f"Error during context manager cleanup: {e}")
        
        # Return None (falsy) to propagate any exceptions that occurred in the with block
        return False
