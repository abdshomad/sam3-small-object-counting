# Issue #005: Hugging Face Authentication

## Problem
SAM 3 checkpoints are stored on Hugging Face and require authentication to download. The installation process needs a way to authenticate with Hugging Face using a token stored in the `.env` file.

## Root Cause
- SAM 3 checkpoints are hosted on Hugging Face at https://huggingface.co/facebook/sam3
- Access to checkpoints requires authentication with a Hugging Face token
- The token needs to be securely stored and used for authentication

## Solution
Created a helper script `scripts/auth_huggingface.sh` that:
1. Loads the `HF_TOKEN` from the `.env` file in the project root
2. Activates the virtual environment
3. Uses the Hugging Face Python API to authenticate
4. Saves the token to the Hugging Face cache for persistent authentication
5. Verifies access to the SAM 3 repository

## Usage

1. **Create `.env` file** in the project root:
   ```bash
   echo "HF_TOKEN=your_huggingface_token_here" > .env
   ```

2. **Run the authentication script**:
   ```bash
   ./scripts/auth_huggingface.sh
   ```

   Or manually authenticate:
   ```bash
   source .venv/bin/activate
   source .env
   python -c "from huggingface_hub import login; login(token='$HF_TOKEN')"
   ```

## Resolution
**Status:** RESOLVED

- Created `scripts/auth_huggingface.sh` for easy authentication
- Successfully authenticated with Hugging Face as user: `abdshomad`
- Token saved to Hugging Face cache for persistent authentication
- Verified access to `facebook/sam3` repository

## Next Steps
After authentication, you can:
1. Download SAM 3 checkpoints using the Hugging Face API
2. Use SAM 3 models in your code without authentication errors
3. The token is now saved in `~/.cache/huggingface/token` for future use

