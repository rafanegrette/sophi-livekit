#!/bin/bash
# Download files at runtime when env vars are available
python src/main.py download-files
# Start the application
exec python src/main.py start