#!/bin/bash
# Script to authenticate with Hugging Face using HF_TOKEN from .env file

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo "ERROR: .env file not found in project root"
    echo "Please create .env file with HF_TOKEN=your_token"
    exit 1
fi

# Load .env file
source .env

# Check if HF_TOKEN is set
if [ -z "$HF_TOKEN" ]; then
    echo "ERROR: HF_TOKEN not found in .env file"
    echo "Please add HF_TOKEN=your_token to .env file"
    exit 1
fi

# Activate virtual environment if it exists
if [ -d ".venv" ]; then
    source .venv/bin/activate
fi

echo "Authenticating with Hugging Face..."
echo "Token loaded (length: ${#HF_TOKEN})"

# Authenticate using Python API
python -c "
from huggingface_hub import login, whoami
import sys

try:
    login(token='$HF_TOKEN')
    user_info = whoami(token='$HF_TOKEN')
    username = user_info.get('name', 'Unknown')
    print(f'✓ Authenticated with Hugging Face as: {username}')
    
    # Test access to SAM 3 repository
    from huggingface_hub import HfApi
    api = HfApi(token='$HF_TOKEN')
    repo_info = api.repo_info('facebook/sam3', repo_type='model')
    print(f'✓ Successfully accessed facebook/sam3 repository')
    print(f'  Repository: {repo_info.id}')
    print(f'  Private: {repo_info.private}')
    
except Exception as e:
    print(f'✗ Authentication failed: {e}', file=sys.stderr)
    sys.exit(1)
"

echo ""
echo "Authentication complete! Token saved to Hugging Face cache."
echo ""
echo "You can now download SAM 3 checkpoints from:"
echo "  https://huggingface.co/facebook/sam3"
echo ""

